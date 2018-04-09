//
//  GenericTableViewController.swift
//  Music Tracker
//
//  Created by Andrew Finke on 4/3/18.
//  Copyright © 2018 Andrew Finke. All rights reserved.
//

import UIKit
import CoreData

struct GenericSection {
    let title: String
    let items: [GenericTableItem]
}

struct GenericTableItem {
    var song: Song?
    var record: PlaybackRecord?
    var records: [PlaybackRecord]?

    let text: String
    let subtext: String

    init(text: String, subtext: String) {
        self.text = text
        self.subtext = subtext
    }
}

class GenericTableViewController: UITableViewController {

    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()

    var sections = [GenericSection]()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")

        _ = UIBarButtonItem(barButtonSystemItem: .done,
                                            target: self,
                                            action: #selector(donePressed(_:)))
        // navigationItem.rightBarButtonItem = barButtonItem

        NotificationCenter.default.addObserver(forName: MusicManager.MusicManagerCreateNotificationName, object: nil, queue: nil) { _ in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    @objc
    func donePressed(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // this is wrong
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "reuseIdentifier")

        let item = sections[indexPath.section].items[indexPath.row]
        cell.textLabel?.text = item.text
        cell.detailTextLabel?.text = item.subtext
        cell.detailTextLabel?.numberOfLines = 0

        if item.song != nil || item.records != nil || item.record != nil {
            cell.selectionStyle = .default
            cell.accessoryType = .disclosureIndicator
        } else {
            cell.selectionStyle = .none
            cell.accessoryType = .none
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = sections[indexPath.section].items[indexPath.row]

        let controller = GenericTableViewController(style: .grouped)

        var newSections = [GenericSection]()
        if let song = item.song {
            newSections = GenericTableViewController.sections(for: song)
            controller.title = song.title
        } else if let records = item.records {
            newSections = GenericTableViewController.sections(for: records)
            controller.title = "Records"
        } else if let record = item.record {
            newSections = GenericTableViewController.sections(for: record)
            controller.title = "Record"
        } else {
            return
        }

        controller.sections = newSections
        navigationController?.pushViewController(controller, animated: true)
    }

    static func sections(for song: Song) -> [GenericSection] {
        guard let set = song.records else { return [] }

        let sortedRecords = Array(set).sorted(by: { (lhs, rhs) -> Bool in
            return (lhs.initalDate as Date) > (rhs.initalDate as Date)
        })

        let items: [GenericTableItem] = sortedRecords.map { record in
            var item = GenericTableItem(text: record.initalDate.description, subtext: "")
            item.record = record
            return item
        }

        var keyItems = [GenericTableItem]()
        for key in song.entity.attributesByName.keys.sorted() where key != "artworkData" {
            if let value = song.value(forKey: key) {
                keyItems.append(GenericTableItem(text: key, subtext: "\(value)"))
            }
        }

        return [
            GenericSection(title: "\(items.count) Records", items: items),
            GenericSection(title: "Keys", items: keyItems)
        ]
    }

    static func sections(for record: PlaybackRecord) -> [GenericSection] {
        let song = record.song
        var songItem = GenericTableItem(text: song.title ?? "N/A", subtext: song.artist ?? "N/A")
        songItem.song = song

        var keyItems = [GenericTableItem]()
        for key in record.entity.attributesByName.keys.sorted() {
            if let value = record.value(forKey: key) as? [Double: Any] {
                var string = ""
                for k in value.keys.sorted() {
                    if let v = value[k] {
                         string += k.description + ": \(v)\n"
                    }
                }
                 keyItems.append(GenericTableItem(text: key, subtext: string))
            } else if let value = record.value(forKey: key) {
                keyItems.append(GenericTableItem(text: key, subtext: "\(value)"))
            }
        }

        return [
            GenericSection(title: "Song", items: [songItem]),
            GenericSection(title: "Keys", items: keyItems)
        ]
    }

    static func sections(for records: [PlaybackRecord]) -> [GenericSection] {
        let items: [GenericTableItem] = records
            .sorted { $0.initalDate as Date > $1.initalDate as Date }
            .map {
                var item = GenericTableItem(text: $0.song.title ?? "N/A",
                                     subtext: formatter.string(from: $0.initalDate as Date))
                item.record = $0
                return item
        }
        return [GenericSection(title: "Records", items: items)]
    }

}

