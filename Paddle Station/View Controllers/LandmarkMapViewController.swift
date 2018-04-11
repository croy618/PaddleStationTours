//
//  LandmarkMapViewController.swift
//  Paddle Station
//
//  Created by Pat Sluth on 2017-12-01.
//  Copyright © 2017 Pat Sluth. All rights reserved.
//

import UIKit
import MapKit




class LandmarkMapViewController: LandmarkViewController
{
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let initialLocation = CLLocation(latitude: 51.058161, longitude: -114.1564088)
        zoomMapOn(location: initialLocation)
        
        let sample1 = Venue(title: "St. Patrick's Island Park", content: "At this park, one can find beautiful views of the Calgary skyline while nestled within nature. The park has been restored and upgraded since the flood of June 2013, and is now home to many picnic areas equipped with charcoal grills.", coordinate: CLLocationCoordinate2D(latitude: 51.0465941, longitude: -114.0415645))
        mapView.addAnnotation(sample1)
        
        let sample2 = Venue(title: "Shouldice Park", content: "Shouldice  Park is a major public park, used for both athletics and recreation. It was named after James Shouldice, an early pioneer who donated the land to the city of Calgary on the condition that it become a park.", coordinate: CLLocationCoordinate2D(latitude: 51.0760522, longitude: -114.1726361))
        mapView.addAnnotation(sample2)
        
        let sample3 = Venue(title: "Bow River Pathway", content: "1220 9 Ave SW, Calgary, AB T2P 2C4", coordinate: CLLocationCoordinate2D(latitude: 51.0451926, longitude: -114.0990171))
        mapView.addAnnotation(sample3)
        
        let sample4 = Venue(title: "Peace Bridge", content: "This beautiful bridge was designed by Spanish architect Santiago Calatrava and is a popular destination for Calgary photographers.", coordinate: CLLocationCoordinate2D(latitude: 51.0524812, longitude: -114.0835983))
        mapView.addAnnotation(sample4)
        
        let sample5 = Venue(title: "Prince's Island Park", content: "This highly-used park in downtown Calgary hosts many large events including the Calgary Folk Festival and the Canada Day celebration. The park was named after a lumberman from Quebec, Peter Anthony Price, who came to Calgary in 1886 and founded the Eau Claire Lumber Mill.", coordinate: CLLocationCoordinate2D(latitude: 51.0529519, longitude: -114.0746587))
        mapView.addAnnotation(sample5)
        
        mapView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkLocationServiceAuthenticationStatus()
    }
    
    
    private let regionRadius: CLLocationDistance = 1000 //1km ~ 1mile = 1.6km
    
    func zoomMapOn(location: CLLocation){
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    // - Current Location
    
    var locationManager = CLLocationManager()
    
    func checkLocationServiceAuthenticationStatus(){
        locationManager.delegate = self
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse{
            mapView.showsUserLocation = true
            locationManager.startUpdatingLocation()
        }else {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            
        }
    }
}

extension LandmarkMapViewController : CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        self.mapView.showsUserLocation = true
        zoomMapOn(location: location)
    }
    
}

extension LandmarkMapViewController : MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? Venue {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            }else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
            }
            
            return view
        }
        
        return nil
    }
    

}



