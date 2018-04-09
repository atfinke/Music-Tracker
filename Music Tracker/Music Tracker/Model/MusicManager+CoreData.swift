//
//  MusicManager+CoreData.swift
//  Music Tracker
//
//  Created by Andrew Finke on 4/7/18.
//  Copyright © 2018 Andrew Finke. All rights reserved.
//

import Foundation
import CoreData
import MediaPlayer

extension MusicManager {

    // MARK: - Music Updates

    func fetchSong(for mediaItem: MPMediaItem) -> Song? {
        let songFetch = NSFetchRequest<Song>(entityName: "Song")
        songFetch.fetchLimit = 1
        songFetch.predicate = NSPredicate(format: "playbackStoreID = %@", mediaItem.playbackStoreID.description)
        do {
            if let song = try managedContext.fetch(songFetch).first  {
                return song
            } else {
                return Song(mediaItem: mediaItem, context: managedContext)
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func fetchLastPlaybackRecord() -> PlaybackRecord?  {
        let playbackRecordFetch = NSFetchRequest<PlaybackRecord>(entityName: "PlaybackRecord")
        playbackRecordFetch.sortDescriptors = [NSSortDescriptor(key: "initalDate", ascending: false)]
        playbackRecordFetch.fetchLimit = 1

        do {
            return try managedContext.fetch(playbackRecordFetch).first
        } catch {
            fatalError(error.localizedDescription)
        }
        return nil
    }

    func createPlaybackRecord(song: Song, date: NSDate) {
        self.healthManager.measure { heartRate in
            DispatchQueue.main.async {
                let volume = self.volume()
                let location = self.locationManager.location?.coordinate

                guard let _ = PlaybackRecord(date: date,
                                                  volume: volume,
                                                  location: location,
                                                  heartRate: heartRate,
                                                  song: song,
                                                  context: self.managedContext) else {
                                                    return
                }

                do {
                    try self.managedContext.save()
                    NotificationCenter.default.post(name: MusicManager.MusicManagerCreateNotificationName, object: nil)
                } catch let error as NSError {
                    fatalError("Could not save song. \(error), \(error.userInfo)")
                }
            }
        }
    }

    func updateLastPlaybackRecord(for song: Song, volume: Float?)  {
        guard Thread.isMainThread else { fatalError() }

        let lastPlaybackRecord = fetchLastPlaybackRecord()
        if let record = lastPlaybackRecord, record.song == song {
            record.update(volume: volume)
            do {
                try self.managedContext.save()
            } catch let error as NSError {
                fatalError(#function + "Could not update record. \(error), \(error.userInfo)")
            }
        } else {
            self.createPlaybackRecord(song: song, date: NSDate())
            do {
                try self.managedContext.save()
            } catch let error as NSError {
                fatalError(#function + " Could not save new record. \(error), \(error.userInfo)")
            }
        }
    }

    // MARK: - Data Viewing

    func fetchAllRecentRecords() -> [PlaybackRecord] {
        let playbackRecordFetch = NSFetchRequest<PlaybackRecord>(entityName: "PlaybackRecord")
        playbackRecordFetch.sortDescriptors = [NSSortDescriptor(key: "initalDate", ascending: false)]

        do {
            return try managedContext.fetch(playbackRecordFetch)
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func fetchAllTopSongs() -> [Song] {
        let songFetch = NSFetchRequest<Song>(entityName: "Song")

        do {
            let results = try managedContext.fetch(songFetch)
            return results.sorted(by: { (lhs, rhs) -> Bool in
                return lhs.records?.count ?? 0 > rhs.records?.count ?? 0
            })
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
}
