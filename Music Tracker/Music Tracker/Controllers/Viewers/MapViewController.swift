//
//  MapViewController.swift
//  Music Tracker
//
//  Created by Andrew Finke on 4/2/18.
//  Copyright © 2018 Andrew Finke. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class RecordAnnotation: MKPointAnnotation {

    let record: PlaybackRecord
    init(record: PlaybackRecord) {
        self.record = record
        super.init()
        self.title = record.song.title
    }
}

class MapViewController: UIViewController, MKMapViewDelegate {

    lazy var managedContext: NSManagedObjectContext = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        return appDelegate.persistentContainer.viewContext
    }()
    
    private let mapView = MKMapView()

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)

        let constraints = [
            mapView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            mapView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        mapView.removeAnnotations(mapView.annotations)

        let mapSpan = MKCoordinateSpan(latitudeDelta: 0.10, longitudeDelta: 0.10)
        let mapCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 42.0604942, longitude: -87.6757036), span: mapSpan)
        mapView.region = mapCoordinateRegion

        let playbackRecordFetch = NSFetchRequest<PlaybackRecord>(entityName: "PlaybackRecord")
        playbackRecordFetch.sortDescriptors = [NSSortDescriptor(key: "initalDate", ascending: false)]
//        playbackRecordFetch.fetchLimit = 5

        do {
            let records = try managedContext.fetch(playbackRecordFetch)
            for record in records {
                if let lat = record.initalLatitude?.doubleValue,
                    let lon = record.initalLongitude?.doubleValue {
                    let pointAnnotation = RecordAnnotation(record: record)
                    pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    mapView.addAnnotation(pointAnnotation)
                }
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)

        let calloutButton = UIButton(type: .detailDisclosure)
        pinView.rightCalloutAccessoryView = calloutButton
        pinView.sizeToFit()

        pinView.canShowCallout = true
        pinView.clusteringIdentifier = "k"
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation as? MKClusterAnnotation {
            guard let annotations = annotation.memberAnnotations as? [RecordAnnotation] else {
                return
            }

            let records = annotations.map { $0.record }
            let controller = GenericTableViewController(style: .grouped)
            controller.sections = GenericTableViewController.sections(for: records)

            let nav = UINavigationController(rootViewController: controller)
            present(nav, animated: true, completion: nil)
        }
    }

}
