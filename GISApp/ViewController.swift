//
//  ViewController.swift
//  GISApp
//
//  Created by McGrath, Daniel - Student on 1/31/23.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    @IBOutlet weak var mapview: MKMapView!
    
    let locationManager = CLLocationManager()
    
    var currentLocation: CLLocation!
    var originalZoom: MKCoordinateRegion!
    var parks: [MKMapItem] = []
    var zoomed = false
}

extension ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        mapview.showsUserLocation = true
        mapview.delegate = self
        originalZoom = mapview.region
    }
    
    @IBAction func whenZoomPressed(_ sender: UIBarButtonItem) {
        let coordinateSpan = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        let center = currentLocation.coordinate
        let region = MKCoordinateRegion(center: center, span: coordinateSpan)
        mapview.setRegion(zoomed ? originalZoom : region, animated: true)
        
        zoomed = !zoomed
    }
    
    @IBAction func whenSearchPressed(_ sender: UIBarButtonItem) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Pizza Places"
        let coordinateSpan = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        request.region = MKCoordinateRegion(center: currentLocation.coordinate, span: coordinateSpan)
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard let response = response else { return }
            for mapItem in response.mapItems {
                self.parks.append(mapItem)
                let annotation = MKPointAnnotation()
                annotation.coordinate = mapItem.placemark.coordinate
                annotation.title = mapItem.name
                annotation.subtitle = mapItem.phoneNumber
                
//                let placemark = mapItem.placemark
//                if let streetNum = placemark.subThoroughfare, let streetName = placemark.thoroughfare {
//                    let address = streetNum + " " + streetName
//                    annotation.subtitle! += " " + address
//                }
                self.mapview.addAnnotation(annotation)
            }
        }
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var currentMapItem = MKMapItem()
        let coordinate = annotation.coordinate
        for mapitem in parks {
            if mapitem.placemark.coordinate.latitude == coordinate.latitude &&
                mapitem.placemark.coordinate.longitude == coordinate.longitude {
                currentMapItem = mapitem
            }
        }
        let placemark = currentMapItem.placemark
        print(currentMapItem)
        
        let alert: UIAlertController!
        if let parkName = placemark.name, let streetNumber = placemark.subThoroughfare, let streetName = placemark.thoroughfare {
            let streetAddress = streetNumber + " " + streetName
            alert = UIAlertController(title: parkName, message: streetAddress, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
        
        if annotation.isEqual(mapview.userLocation) {
            return nil
        }
        
        let pin = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
        let pinImage = UIImage(named: "Pizza")
        let size = CGSize(width: 50, height: 50)
        UIGraphicsBeginImageContext(size)
        pinImage!.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        pin.image = UIGraphicsGetImageFromCurrentImageContext()
        pin.canShowCallout = true
        let button = UIButton(type: .close)
        button.addAction(UIAlertAction(title: "OK", style: .default, handler: nil), for: .touchUpInside)
        button.addTarget(self, action: #selector(onClosePressed), for: .touchUpInside)
        pin.rightCalloutAccessoryView = button
        return pin
    }
    
    @IBAction
    func onClosePressed(_ sender: UIButton) {
        print("hello world")
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations[0]
    }
}
