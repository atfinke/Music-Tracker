//
//  RecentRecordsViewController.swift
//  Music Tracker
//
//  Created by Andrew Finke on 4/3/18.
//  Copyright © 2018 Andrew Finke. All rights reserved.
//

import UIKit
import CoreData

class RecentRecordsViewController: GenericTableViewController {

    lazy var managedContext: NSManagedObjectContext = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        return appDelegate.persistentContainer.viewContext
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = nil
        self.update()

        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSManagedObjectContextDidSave, object: nil, queue: nil) { _ in
            DispatchQueue.main.async {
                self.update()
            }
        }
    }

    func update() {
        let playbackRecordFetch = NSFetchRequest<PlaybackRecord>(entityName: "PlaybackRecord")
        playbackRecordFetch.sortDescriptors = [NSSortDescriptor(key: "initalDate", ascending: false)]
        playbackRecordFetch.fetchLimit = 10

        do {
            let records = try managedContext.fetch(playbackRecordFetch)
            sections = GenericTableViewController.sections(for: records)
            tableView.reloadData()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
