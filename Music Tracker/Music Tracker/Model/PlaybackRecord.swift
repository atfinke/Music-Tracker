//
//  PlaybackRecord+CoreDataClass.swift
//  Music Tracker
//
//  Created by Andrew Finke on 4/1/18.
//  Copyright © 2018 Andrew Finke. All rights reserved.
//
//

import Foundation
import CoreData
import MediaPlayer
import CoreLocation

@objc(PlaybackRecord)
public class PlaybackRecord: NSManagedObject {

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init?(date: NSDate,
          volume: Float,
          location: CLLocationCoordinate2D?,
          heartRate: Int?,
          song: Song,
          context: NSManagedObjectContext) {
        
        guard let entity = NSEntityDescription.entity(forEntityName: "PlaybackRecord", in: context) else {
            fatalError()
        }
        super.init(entity: entity, insertInto: context)

        self.initalDate = date

        if let lat = location?.latitude {
            self.initalLatitude = NSNumber(value: lat)
        }
        if let lon = location?.longitude {
            self.initalLongitude = NSNumber(value: lon)
        }

        let player = MPMusicPlayerController.systemMusicPlayer
        self.initalVolume = volume
        self.volumeLevels = [
            player.currentPlaybackTime: [
                "Date": date,
                "Volume": self.initalVolume
            ]
        ]

        self.initalPlaybackTime = player.currentPlaybackTime
        self.initalShuffleMode = Int16(player.shuffleMode.rawValue)
        self.initalRepeatMode = Int16(player.repeatMode.rawValue)

        self.initalPlaybackState = Int16(player.playbackState.rawValue)
        self.playbackStates = [
            player.currentPlaybackTime: [
                "Date": date,
                "PlaybackState": self.initalPlaybackState
            ]
        ]

        if let heart = heartRate {
            self.initalHeartRateLastHour = NSNumber(value: heart)
        }
        self.song = song
    }

    func update(volume: Float?) {
        let date = Date()
        let player = MPMusicPlayerController.systemMusicPlayer

        if let volume = volume {
            self.volumeLevels[player.currentPlaybackTime] = [
                "Date": date,
                "Volume": volume
            ]
        } else {
            self.playbackStates[player.currentPlaybackTime] = [
                "Date": date,
                "PlaybackState": player.playbackState.rawValue
            ]
        }

    }


}
