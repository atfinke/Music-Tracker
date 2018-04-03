//
//  ViewController+Fetching.swift
//  Music Tracker
//
//  Created by Andrew Finke on 4/2/18.
//  Copyright © 2018 Andrew Finke. All rights reserved.
//

import Foundation
import CoreData

extension ViewController {

    func fetchLastVolumeLevels() {
        let playbackRecordFetch = NSFetchRequest<PlaybackRecord>(entityName: "PlaybackRecord")
        playbackRecordFetch.sortDescriptors = [NSSortDescriptor(key: "initalDate", ascending: false)]
        playbackRecordFetch.fetchLimit = 5

        do {
            let records = try managedContext.fetch(playbackRecordFetch)
            for record in records {
                print(record.song.title as Any)
                for time in record.volumeLevels.keys.sorted() {
                    if let volumeLevels = record.volumeLevels[time], let volume = volumeLevels["Volume"] as? Float {
                        print(Int(time).description + ": " + volume.description)
                    } else {
                        print(Int(time).description + ": N/A")
                    }
                }
                print("-")
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
}
