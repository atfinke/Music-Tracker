//
//  Song+CoreDataProperties.swift
//  Music Tracker
//
//  Created by Andrew Finke on 4/1/18.
//  Copyright © 2018 Andrew Finke. All rights reserved.
//
//

import Foundation
import CoreData

extension Song {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Song> {
        return NSFetchRequest<Song>(entityName: "Song")
    }

    @NSManaged public var title: String?
    @NSManaged public var playbackStoreID: String
    @NSManaged public var persistentID: String
    @NSManaged public var skipCount: Int64
    @NSManaged public var playCount: Int64
    @NSManaged public var beatsPerMinute: Int64
    @NSManaged public var releaseDate: NSDate?
    @NSManaged public var isExplicitItem: Bool
    @NSManaged public var albumTrackCount: Int64
    @NSManaged public var albumTrackNumber: Int64
    @NSManaged public var playbackDuration: Double
    @NSManaged public var composer: String?
    @NSManaged public var composerPersistentID: String
    @NSManaged public var genrePersistentID: String
    @NSManaged public var genre: String?
    @NSManaged public var albumArtistPersistentID: String
    @NSManaged public var albumArtist: String?
    @NSManaged public var artistPersistentID: String
    @NSManaged public var artist: String?
    @NSManaged public var albumPersistentID: String
    @NSManaged public var albumTitle: String?
    @NSManaged public var artworkData: Data?
    @NSManaged public var records: NSSet?

}

// MARK: Generated accessors for records
extension Song {

    @objc(addRecordsObject:)
    @NSManaged public func addToRecords(_ value: PlaybackRecord)

    @objc(removeRecordsObject:)
    @NSManaged public func removeFromRecords(_ value: PlaybackRecord)

    @objc(addRecords:)
    @NSManaged public func addToRecords(_ values: NSSet)

    @objc(removeRecords:)
    @NSManaged public func removeFromRecords(_ values: NSSet)

}
