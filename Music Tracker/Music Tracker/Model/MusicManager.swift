//
//  MusicManager.swift
//  Music Tracker
//
//  Created by Andrew Finke on 4/7/18.
//  Copyright © 2018 Andrew Finke. All rights reserved.
//

import CoreData
import CoreLocation
import MediaPlayer

class MusicManager: NSObject {

    private var images = NSCache<NSString,UIImage>()

    let volumeView = MPVolumeView()

    let healthManager = HealthManager()
    let locationManager = CLLocationManager()

    static let shared = MusicManager()
    static let MusicManagerCreateNotificationName = Notification.Name(rawValue: "MusicManagerCreateNotificationName")

    private(set) lazy var managedContext: NSManagedObjectContext = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        return appDelegate.persistentContainer.viewContext
    }()

    func start() {
        print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true))

        configureUI()
        configureLocationManager()
        configureMusic()

        healthManager.authorize { (_, _) in }
    }

    func configureUI() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let window = appDelegate.window else { fatalError() }

        volumeView.translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(volumeView)

        let constraints = [
            volumeView.leftAnchor.constraint(equalTo: window.safeAreaLayoutGuide.leftAnchor),
            volumeView.rightAnchor.constraint(equalTo: window.safeAreaLayoutGuide.rightAnchor),
            volumeView.bottomAnchor.constraint(equalTo: window.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    // MARK: - Helpers

    func volume() -> Float {
        for view in volumeView.subviews where view.isKind(of: UISlider.self) {
            guard let slider = view as? UISlider else { continue }
            return slider.value
        }
        fatalError()
    }

    func image(for song: Song) -> UIImage? {
        let key = song.albumPersistentID as NSString
        if let image = images.object(forKey: key) {
            return image
        } else if let data = song.artworkData, let image = UIImage(data: data) {
            images.setObject(image, forKey: key)
            return image
        }
        return nil
    }

//    func fetchLastVolumeLevels() {
//        let playbackRecordFetch = NSFetchRequest<PlaybackRecord>(entityName: "PlaybackRecord")
//        playbackRecordFetch.sortDescriptors = [NSSortDescriptor(key: "initalDate", ascending: false)]
//        playbackRecordFetch.fetchLimit = 5
//
//        do {
//            let records = try managedContext.fetch(playbackRecordFetch)
//            for record in records {
//                print(record.song.title as Any)
//                for time in record.volumeLevels.keys.sorted() {
//                    if let volumeLevels = record.volumeLevels[time], let volume = volumeLevels["Volume"] as? Float {
//                        print(Int(time).description + ": " + volume.description)
//                    } else {
//                        print(Int(time).description + ": N/A")
//                    }
//                }
//                print("-")
//            }
//        } catch {
//            fatalError(error.localizedDescription)
//        }
//    }


}
