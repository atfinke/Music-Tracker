//
//  ViewController+Music.swift
//  Music Tracker
//
//  Created by Andrew Finke on 4/2/18.
//  Copyright © 2018 Andrew Finke. All rights reserved.
//

import Foundation
import MediaPlayer
import CoreData

extension ViewController {

    func configureMusic()  {
        let player = MPMusicPlayerController.systemMusicPlayer
        player.beginGeneratingPlaybackNotifications()

        let nowPlayingName = NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange
        NotificationCenter.default.addObserver(forName: nowPlayingName, object: nil, queue: nil) { _ in

            print("Now Playing Notification")

            guard let item = player.nowPlayingItem,
                let song = self.fetchSong(for: item) else { return }

            self.createPlaybackRecord(song: song)
        }

        let volumeName = NSNotification.Name.MPMusicPlayerControllerVolumeDidChange
        NotificationCenter.default.addObserver(forName: volumeName, object: nil, queue: nil) { _ in

            print("Volume Notification")

            guard let item = player.nowPlayingItem,
                let song = self.fetchSong(for: item) else { return }

            self.updateLastPlaybackRecord(for: song)
        }

        let playbackName = NSNotification.Name.MPMusicPlayerControllerPlaybackStateDidChange
        NotificationCenter.default.addObserver(forName: playbackName, object: nil, queue: nil) { _ in
            print("Playback Notification")

            guard let item = player.nowPlayingItem,
                let song = self.fetchSong(for: item) else { return }

            self.updateLastPlaybackRecord(for: song)
        }
    }

    func fetchSong(for mediaItem: MPMediaItem) -> Song? {
        let songFetch = NSFetchRequest<Song>(entityName: "Song")
        songFetch.fetchLimit = 1
        songFetch.predicate = NSPredicate(format: "persistentID = %@", mediaItem.persistentID.description)
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

    func createPlaybackRecord(song: Song) {
        self.healthManager.measure { heartRate in
            DispatchQueue.main.async {
                let volume = self.volume()
                let location = self.locationManager.location?.coordinate

                guard let record = PlaybackRecord(volume: volume,
                                                  location: location,
                                                  heartRate: heartRate,
                                                  song: song,
                                                  context: self.managedContext) else {
                                                    return
                }

                do {
                    try self.managedContext.save()
                    self.updateUI(song: song, record: record)
                } catch let error as NSError {
                    fatalError("Could not save song. \(error), \(error.userInfo)")
                }
            }
        }
    }

    func updateLastPlaybackRecord(for song: Song)  {
        if let lastPlaybackRecord = lastPlaybackRecord(for: song) {
            DispatchQueue.main.async {
                lastPlaybackRecord.update(volume: self.volume())
                do {
                    try self.managedContext.save()
                    self.updateUI(song: song, record: lastPlaybackRecord)
                } catch let error as NSError {
                    fatalError(#function + "Could not update record. \(error), \(error.userInfo)")
                }
            }
        } else {
            DispatchQueue.main.async {
                self.createPlaybackRecord(song: song)
                do {
                    try self.managedContext.save()
                } catch let error as NSError {
                    fatalError(#function + " Could not save new record. \(error), \(error.userInfo)")
                }
            }
        }
    }

    func lastPlaybackRecord(for song: Song) -> PlaybackRecord?  {
        let playbackRecordFetch = NSFetchRequest<PlaybackRecord>(entityName: "PlaybackRecord")
        playbackRecordFetch.sortDescriptors = [NSSortDescriptor(key: "initalDate", ascending: false)]
        playbackRecordFetch.fetchLimit = 1

        do {
            if let record = try managedContext.fetch(playbackRecordFetch).first  {
                if record.song == song {
                    return record
                } else {
                    print("Last record has different song")
                    print("Last record song: " + (record.song.title ?? "N/A"))
                    print("Current song: " + (song.title ?? "N/A"))
                }
            }
        } catch {
            fatalError(error.localizedDescription)
        }
        return nil
    }

    func updateUI(song: Song, record: PlaybackRecord) {
        var string = "Current Song:\n\n"
        for key in song.entity.attributesByName.keys.sorted() {
            if let value = song.value(forKey: key) {
                string += "\(key): \(value)\n"
            }
        }
        string += "\n===============\n\nCurrent PlaybackRecord:\n\n"
        for key in record.entity.attributesByName.keys.sorted() {
            if let value = record.value(forKey: key) {
                string += "\(key): \(value)\n"
            }
        }
        textView.text = string
    }
}
