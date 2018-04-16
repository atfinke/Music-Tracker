//
//  ArtworkCollectionViewController.swift
//  Music Tracker
//
//  Created by Andrew Finke on 4/7/18.
//  Copyright © 2018 Andrew Finke. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class ArtworkCell: UICollectionViewCell {
    let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)

        let constraints = [
            imageView.leftAnchor.constraint(equalTo: leftAnchor),
            imageView.rightAnchor.constraint(equalTo: rightAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class TopSongsArtworkCollectionViewController: ArtworkCollectionViewController {
    override func update() {
        self.songs = MusicManager.shared.fetchAllTopSongs()
        collectionView?.reloadSections(IndexSet(integer: 0))
    }
}

class RecentRecordsArtworkCollectionViewController: ArtworkCollectionViewController {

    @IBAction func scrobbleAll(_ sender: Any) {
        MusicManager.shared.scrobbleAll()
    }

    override func update() {
        self.records = MusicManager.shared.fetchAllRecentRecords()
        collectionView?.reloadSections(IndexSet(integer: 0))
    }
}

class ArtworkCollectionViewController: UICollectionViewController {

    var songs: [Song]?
    var records: [PlaybackRecord]?

    override func viewDidLoad() {
        super.viewDidLoad()

        let layout = UICollectionViewFlowLayout()
        let size = view.frame.width / 4
        layout.itemSize = CGSize(width: size, height: size)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView?.setCollectionViewLayout(layout, animated: false)

        self.collectionView!.register(ArtworkCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.update()

        NotificationCenter.default.addObserver(forName: MusicManager.MusicManagerCreateNotificationName, object: nil, queue: nil) { _ in
            DispatchQueue.main.async {
                self.update()
            }
        }

        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh,
                                            target: self,
                                            action: #selector(update))
        navigationItem.rightBarButtonItem = barButtonItem
    }

    @objc
    func update() {}

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = songs?.count {
            return count
        } else if let count = records?.count {
            return count
        } else {
            return 0
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? ArtworkCell else {
            fatalError()
        }

        var song: Song?

        defer {
            if let song = song {
                DispatchQueue.global(qos: .userInteractive).async {
                    let image = MusicManager.shared.image(for: song)
                    DispatchQueue.main.async {
                        cell.imageView.image = image
                    }
                }
            }
        }

        if let songs = songs {
            song = songs[indexPath.row]
        } else if let records = records {
            song = records[indexPath.row].song
        }

        cell.imageView.image = nil
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = GenericTableViewController(style: .grouped)
        if let songs = songs {
            let song = songs[indexPath.row]
            controller.sections = GenericTableViewController.sections(for: song)
            controller.title = song.title
        } else if let records = records {
            let record = records[indexPath.row]
            controller.sections = GenericTableViewController.sections(for: record)
            controller.title = "Record"
        }
        navigationController?.pushViewController(controller, animated: true)
    }

}
