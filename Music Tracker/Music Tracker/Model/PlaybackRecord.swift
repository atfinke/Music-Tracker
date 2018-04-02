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
    
    init?(volume: Float,
          location: CLLocationCoordinate2D?,
          heartRate: Int?,
          song: Song,
          context: NSManagedObjectContext) {
        
        guard let entity = NSEntityDescription.entity(forEntityName: "PlaybackRecord", in: context) else {
            fatalError()
        }
        super.init(entity: entity, insertInto: context)

        self.initalDate = NSDate()
        self.lastUpdateDate = self.initalDate

        if let lat = location?.latitude {
            self.initalLatitude = NSNumber(value: lat)
        }
        if let lon = location?.longitude {
            self.initalLongitude = NSNumber(value: lon)
        }

        let player = MPMusicPlayerController.systemMusicPlayer

        self.initalVolume = volume
        self.volumeLevels = [player.currentPlaybackTime: self.initalVolume]

        self.initalPlaybackTime = player.currentPlaybackTime
        self.initalShuffleMode = Int16(player.shuffleMode.rawValue)
        self.initalRepeatMode = Int16(player.repeatMode.rawValue)

        self.initalPlaybackState = Int16(player.playbackState.rawValue)
        self.lastPlaybackState = self.initalPlaybackState

        if let heart = heartRate {
            self.initalHeartRateLastHour = NSNumber(value: heart)
        }
        self.song = song
    }

    func update(volume: Float) {
        self.lastUpdateDate = NSDate()
        let player = MPMusicPlayerController.systemMusicPlayer
        self.volumeLevels[player.currentPlaybackTime] = volume
        self.lastPlaybackState = Int16(player.playbackState.rawValue)
    }


}
