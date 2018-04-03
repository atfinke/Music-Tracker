//
//  PlaybackRecord+CoreDataProperties.swift
//  Music Tracker
//
//  Created by Andrew Finke on 4/1/18.
//  Copyright © 2018 Andrew Finke. All rights reserved.
//
//

import Foundation
import CoreData

extension PlaybackRecord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlaybackRecord> {
        return NSFetchRequest<PlaybackRecord>(entityName: "PlaybackRecord")
    }

    @NSManaged public var initalDate: NSDate
    @NSManaged public var initalLatitude: NSNumber?
    @NSManaged public var initalLongitude: NSNumber?
    @NSManaged public var initalVolume: Float
    @NSManaged public var initalPlaybackTime: Double
    @NSManaged public var initalShuffleMode: Int16
    @NSManaged public var initalRepeatMode: Int16
    @NSManaged public var initalPlaybackState: Int16
    @NSManaged public var initalHeartRateLastHour: NSNumber?

    /*
     playbackTime: {
     date: Date,
     volume: Float
     }
     */
    @NSManaged public var volumeLevels: [Double: [String: Any]]

    /*
     playbackTime: {
     date: Date,
     volume: Float
     }
     */
    @NSManaged public var playbackStates: [Double: [String: Any]]

    // start date of next item
    @NSManaged public var nextPlaybackInitalDate: NSDate

    @NSManaged public var song: Song

}
