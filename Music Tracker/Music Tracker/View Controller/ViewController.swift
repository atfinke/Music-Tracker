//
//  ViewController.swift
//  Music Tracker
//
//  Created by Andrew Finke on 4/1/18.
//  Copyright © 2018 Andrew Finke. All rights reserved.
//

import UIKit
import CoreLocation
import MediaPlayer
import CoreData

class ViewController: UIViewController  {

    private let volumeView = MPVolumeView()

    lazy var managedContext: NSManagedObjectContext = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        return appDelegate.persistentContainer.viewContext
    }()

    let textView = UITextView()
    let healthManager = HealthManager()
    let locationManager = CLLocationManager()

    override func viewDidLoad() {

        fetchLastVolumeLevels()

        configureUI()
        configureLocationManager()
        configureMusic()

        healthManager.authorize { (_, _) in }
    }

    // MARK: - Helpers

    func volume() -> Float {
        for view in volumeView.subviews where view.isKind(of: UISlider.self) {
            guard let slider = view as? UISlider else { continue }
            return slider.value
        }
        fatalError()
    }

    func configureUI() {
        textView.isUserInteractionEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)

        volumeView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(volumeView)

        let constraints = [
            textView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            textView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            volumeView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            volumeView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            volumeView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}

