//
//  FindKayaksViewController.swift
//  PaddleStationApp
//
//  Created by Jamie Mills on 2017-11-20.
//  Copyright © 2017 PaddleStation. All rights reserved.
//

import UIKit
import MapKit

class FindKayaksViewController: UIViewController {
    var bookingDetails: Booking!
    var availability: Int = 0
    @IBOutlet weak var mapView: MKMapView!
    
    public func setAvailability (_ available: Int) {
        availability = available
        
        //refresh annotations with updated availability
        mapView.removeAnnotations(mapView.annotations)
        viewDidLoad()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let initialLocation = CLLocationCoordinate2D(latitude: 51.072306, longitude: -114.172000)
        let initialRadius: CLLocationDistance = 5000
        
        centerMapOnLocation(location: initialLocation, radius: initialRadius)
        //print("Availability: "+String(availability))
        let paddleStation1 = PaddleStation(title: "The Shouldice Station\nAvailability: " + String(availability), locationName: "Shouldice Park", type: "Station", coordinate: CLLocationCoordinate2D(latitude: 51.072306, longitude: -114.172000), numKayaks: 50, numRafts: 5)
        
        mapView.addAnnotation(paddleStation1)
        
        mapView.delegate = self
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func centerMapOnLocation(location: CLLocationCoordinate2D, radius: CLLocationDistance) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location, radius, radius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? BookKayaksViewController {
            destinationViewController.bookingDetails = self.bookingDetails
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}

extension FindKayaksViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? PaddleStation else {
            return nil
        }
        
        let identifier = "marker"
        var view: MKMarkerAnnotationView
        
        if let viewToReturn = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            viewToReturn.annotation = annotation
            view = viewToReturn
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            
            view.calloutOffset = CGPoint(x: 5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            
            /* var rightButton: AnyObject! = UIButton(type: UIButtonType.roundedRect)
            rightButton.setTitle("BOOK", for: .normal)
            
            view.calloutOffset = CGPoint(x: 5, y: 5)
            view.rightCalloutAccessoryView = rightButton as! UIView
 */
        }
        
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            performSegue(withIdentifier: "showBooking", sender: view)
        }
    }
}

extension FindKayaksViewController {
    @IBAction func closeToFilterScreenController(_ segue: UIStoryboardSegue) {
        
    }
}
