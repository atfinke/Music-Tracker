//
//  Song+CoreDataClass.swift
//  Music Tracker
//
//  Created by Andrew Finke on 4/1/18.
//  Copyright © 2018 Andrew Finke. All rights reserved.
//
//

import Foundation
import CoreData
import MediaPlayer

@objc(Song)
public class Song: NSManagedObject {

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    init?(mediaItem: MPMediaItem, context: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entity(forEntityName: "Song", in: context) else {
            fatalError()
        }
        guard mediaItem.mediaType == .music else {
            return nil
        }
        super.init(entity: entity, insertInto: context)

        self.title = mediaItem.title
        self.playbackStoreID = mediaItem.playbackStoreID
        self.persistentID = mediaItem.persistentID.description

        self.artist = mediaItem.artist
        self.artistPersistentID = mediaItem.artistPersistentID.description

        self.composer = mediaItem.composer
        self.composerPersistentID = mediaItem.composerPersistentID.description

        self.genre = mediaItem.genre
        self.genrePersistentID = mediaItem.genrePersistentID.description

        self.albumTitle = mediaItem.albumTitle
        self.albumPersistentID = mediaItem.albumPersistentID.description
        self.albumArtist = mediaItem.albumArtist
        self.albumArtistPersistentID = mediaItem.albumArtistPersistentID.description

        self.albumTrackCount = Int64(mediaItem.albumTrackCount)
        self.albumTrackNumber = Int64(mediaItem.albumTrackNumber)

        self.playbackDuration = mediaItem.playbackDuration
        self.beatsPerMinute = Int64(mediaItem.beatsPerMinute)
        self.skipCount = Int64(mediaItem.skipCount)
        self.playCount = Int64(mediaItem.playCount)

        self.releaseDate = mediaItem.releaseDate as NSDate?
        self.isExplicitItem = mediaItem.isExplicitItem

        if let artwork = mediaItem.artwork, let image = artwork.image(at: artwork.bounds.size) {
            self.artworkData = UIImageJPEGRepresentation(image, 0.7)
        }
    }

    func update(with mediaItem: MPMediaItem) {
        self.skipCount = Int64(mediaItem.skipCount)
        self.playCount = Int64(mediaItem.playCount)
    }
}
