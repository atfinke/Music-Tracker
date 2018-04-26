//
//  LastFM.swift
//  Music Tracker
//
//  Created by Andrew Finke on 4/15/18.
//  Copyright © 2018 Andrew Finke. All rights reserved.
//

import Foundation

struct LastFM {

    static func scrobble(_ record: PlaybackRecord, completion: ((Bool) -> Void)? = nil) {
        // Requirements: https://www.last.fm/api/scrobbling
        let songDuration = record.song.playbackDuration
        guard !record.uploadedToLastFM,
            songDuration > 30,
            let finalDate = record.nextPlaybackInitalDate,
            finalDate.timeIntervalSince(record.initalDate as Date) > songDuration / 2,
            let request = urlRequest(for: record, method: "track.scrobble") else {
                completion?(false)
                return
        }

        let task = URLSession.shared.dataTask(with: request) { (_, response, _) in
            if (response as? HTTPURLResponse)?.statusCode == 200 {
                record.uploadedToLastFM = true
                completion?(true)
            } else {
                completion?(false)
            }
        }
        task.resume()
    }

    static func updateNowPlaying(for record: PlaybackRecord) {
        guard let request = urlRequest(for: record, method: "track.updateNowPlaying") else {
            return
        }

        let task = URLSession.shared.dataTask(with: request)
        task.resume()
    }

    private static func urlRequest(for record: PlaybackRecord, method: String) -> URLRequest? {
        let songDuration = record.song.playbackDuration
        guard let track = record.song.title,
            let artist = record.song.artist,
            let album = record.song.albumTitle else {
                return nil
        }

        let properties: [String: Any] = [
            "track": track,
            "artist": artist,
            "album": album,
            "duration": Int(songDuration),

            "timestamp": Int(record.initalDate.timeIntervalSince1970),

            "method": method,
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
                    return nil
            }

            signature += key + "\(value)"
            httpBody += "\(key)=\(encoded)&"
        }

        signature += Secrets.lastFMSecret
        httpBody += "api_sig=\(signature.utf8.md5.description)"

        guard let data = httpBody.data(using: .utf8) else { return nil }

        let url = URL(string: "https://ws.audioscrobbler.com/2.0/")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = data

        return urlRequest
    }
}
