//
//  MapViewController.swift
//  Music Tracker
//
//  Created by Andrew Finke on 4/2/18.
//  Copyright © 2018 Andrew Finke. All rights reserved.
//

import UIKit
import MapKit

class RecordAnnotation: MKPointAnnotation {
    let record: PlaybackRecord
    init(record: PlaybackRecord) {
        self.record = record
        super.init()
        self.title = record.song.title
    }
}

class MapViewController: UIViewController, MKMapViewDelegate {

    private let mapView = MKMapView()

    override func viewDidLoad() {
        super.viewDidLoad()

        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh,
                                            target: self,
                                            action: #selector(reload))
        navigationItem.rightBarButtonItem = barButtonItem

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

        reload()

        NotificationCenter.default.addObserver(forName: MusicManager.MusicManagerCreateNotificationName, object: nil, queue: nil) { _ in
            DispatchQueue.main.async {
                self.reload()
            }
        }
    }

    @objc
    func reload() {
        mapView.removeAnnotations(mapView.annotations)

        let mapSpan = MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015)
        let mapCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 42.055, longitude: -87.6758036), span: mapSpan)
        mapView.region = mapCoordinateRegion

        for record in MusicManager.shared.fetchAllRecentRecords() {
            if let lat = record.initalLatitude?.doubleValue,
                let lon = record.initalLongitude?.doubleValue {
                let pointAnnotation = RecordAnnotation(record: record)
                pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                mapView.addAnnotation(pointAnnotation)
            }
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

        let controller = GenericTableViewController(style: .grouped)
        var sections = [GenericSection]()

        if let annotation = view.annotation as? MKClusterAnnotation, let annotations = annotation.memberAnnotations as? [RecordAnnotation] {
            let records = annotations.map { $0.record }
            sections = GenericTableViewController.sections(for: records)
            controller.title = "Records"
        } else if let annotation = view.annotation as? RecordAnnotation {
            sections = GenericTableViewController.sections(for: annotation.record)
            controller.title = "Record"
        }

        controller.sections = sections
        navigationController?.pushViewController(controller, animated: true)
    }

}
