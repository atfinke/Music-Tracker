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
            if let record = self.fetchLastPlaybackRecord() {
                record.nextPlaybackInitalDate = date
                self.attemptUploadToLastFM(record)
            }

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

    func attemptUploadToLastFM(_ record: PlaybackRecord) {
        if record.uploadedToLastFM {
            return
        }

//        A track should only be scrobbled when the following conditions have been met:
//
//        The track must be longer than 30 seconds.
//        And the track has been played for at least half its duration, or for 4 minutes (whichever occurs earlier.)
        let songDuration = record.song.playbackDuration
        guard songDuration > 30,
            let finalDate = record.nextPlaybackInitalDate,
            finalDate.timeIntervalSince(record.initalDate as Date) > songDuration / 2,
            let track = record.song.title,
            let artist = record.song.artist,
            let album = record.song.albumTitle else {
            return
        }

        let properties: [String: Any] = [
            "track": track,
            "artist": artist,
            "album": album,
            "duration": Int(songDuration),

            "timestamp": Int(record.initalDate.timeIntervalSince1970),

            "method": "track.scrobble",
            "sk": Secrets.lastFMSK,
            "api_key": Secrets.lastFMAPIKey,

            "username": "andrewfinke"
        ]

        var httpBody = ""
        var signature = ""

        var allowedQueryParamAndKey =  NSCharacterSet.urlQueryAllowed
        allowedQueryParamAndKey.remove(charactersIn: "!*'();:@&=+$,/?%#[]")

        for key in properties.keys.sorted() {
            guard let value = properties[key],
                let encoded = "\(value)".addingPercentEncoding(withAllowedCharacters: allowedQueryParamAndKey) else {
                    return
            }

            signature += key + "\(value)"
            httpBody += "\(key)=\(encoded)&"
        }

        signature += Secrets.lastFMSecret
        httpBody += "api_sig=\(signature.utf8.md5.description)"

        guard let data = httpBody.data(using: .utf8) else { fatalError() }

        let url = URL(string: "https://ws.audioscrobbler.com/2.0/")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = data

        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if (response as? HTTPURLResponse)?.statusCode == 200 {
                record.uploadedToLastFM = true
            }
        }
        task.resume()
    }
    
}
