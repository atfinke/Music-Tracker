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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        navigationItem.rightBarButtonItem = nil

        let playbackRecordFetch = NSFetchRequest<PlaybackRecord>(entityName: "PlaybackRecord")
        playbackRecordFetch.sortDescriptors = [NSSortDescriptor(key: "initalDate", ascending: false)]
        playbackRecordFetch.fetchLimit = 10

        do {
            let records = try managedContext.fetch(playbackRecordFetch)
            self.sections = GenericTableViewController.sections(for: records)
            self.tableView.reloadData()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
//
//class TopSongsViewController: GenericTableViewController {
//
//    lazy var managedContext: NSManagedObjectContext = {
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
//        return appDelegate.persistentContainer.viewContext
//    }()
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//
//        let songsFetch = NSFetchRequest<Song>(entityName: "Song")
//        playbackRecordFetch.sortDescriptors = [NSSortDescriptor(key: "initalDate", ascending: false)]
//        playbackRecordFetch.fetchLimit = 10
//
//        do {
//            let records = try managedContext.fetch(playbackRecordFetch)
//            self.sections = GenericTableViewController.sections(for: records)
//        } catch {
//            fatalError(error.localizedDescription)
//        }
//    }
//}

