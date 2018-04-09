//
//  MusicManager+Music.swift
//  Music Tracker
//
//  Created by Andrew Finke on 4/7/18.
//  Copyright © 2018 Andrew Finke. All rights reserved.
//

import MediaPlayer

extension MusicManager {

    func configureMusic() {
        let player = MPMusicPlayerController.systemMusicPlayer
        player.beginGeneratingPlaybackNotifications()

        let nowPlayingName = NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange
        NotificationCenter.default.addObserver(forName: nowPlayingName, object: nil, queue: nil) { _ in

            print("Now Playing Notification")

            let date = NSDate()
            self.fetchLastPlaybackRecord()?.nextPlaybackInitalDate = date

            guard let item = player.nowPlayingItem,
                let song = self.fetchSong(for: item) else { return }

            self.createPlaybackRecord(song: song, date: date)
        }

        let volumeName = NSNotification.Name.MPMusicPlayerControllerVolumeDidChange
        NotificationCenter.default.addObserver(forName: volumeName, object: nil, queue: nil) { _ in

            print("Volume Notification")

            guard let item = player.nowPlayingItem,
                let song = self.fetchSong(for: item) else { return }

            DispatchQueue.main.async {
                self.updateLastPlaybackRecord(for: song, volume: self.volume())
            }
        }

        let playbackName = NSNotification.Name.MPMusicPlayerControllerPlaybackStateDidChange
        NotificationCenter.default.addObserver(forName: playbackName, object: nil, queue: nil) { _ in
            print("Playback Notification")

            guard let item = player.nowPlayingItem,
                let song = self.fetchSong(for: item) else { return }

            DispatchQueue.main.async {
                self.updateLastPlaybackRecord(for: song, volume: nil)
            }
        }
    }
    
}
