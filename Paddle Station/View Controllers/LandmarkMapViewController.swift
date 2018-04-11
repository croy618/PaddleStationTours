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
        
        let sample3 = Venue(title: "Bow River Pathway", content: "The Bow River Pathway is a network of paths used for pedestrians and cyclists that was created in 1975. The paths are connected with a system that extends along the Elbow River and other areas of the city.", coordinate: CLLocationCoordinate2D(latitude: 51.0433379, longitude: -114.1190892))
        mapView.addAnnotation(sample3)
        
        let sample4 = Venue(title: "Peace Bridge", content: "This beautiful bridge was designed by Spanish architect Santiago Calatrava and is a popular destination for Calgary photographers.", coordinate: CLLocationCoordinate2D(latitude: 51.0524812, longitude: -114.0835983))
        mapView.addAnnotation(sample4)
        
        let sample5 = Venue(title: "Prince's Island Park", content: "This highly-used park in downtown Calgary hosts many large events including the Calgary Folk Festival and the Canada Day celebration. The park was named after a lumberman from Quebec, Peter Anthony Price, who came to Calgary in 1886 and founded the Eau Claire Lumber Mill.", coordinate: CLLocationCoordinate2D(latitude: 51.0529519, longitude: -114.0746587))
        mapView.addAnnotation(sample5)
        
        let sample6 = Venue(title: "Angel's Cappuccino & Ice Cream", content: "Angel’s is a great café to grab a refreshment and enjoy views of the Bow River from either its patio or its indoor seating area.", coordinate: CLLocationCoordinate2D(latitude: 51.064688, longitude: -114.1551157))
        mapView.addAnnotation(sample6)
        
        let sample7 = Venue(title: "Parkdale Plaza", content: "The Parkdale Plaza is a vibrant public space for people to sit, take in the view, and reflect. The Outflow Sculpture is designed by Brian Tolle and is an inverted replica of Mount Peechee in Banff National Park. The sculpture is seen as interactive as you can walk through it.", coordinate: CLLocationCoordinate2D(latitude: 51.0566537, longitude: -114.1408263))
        mapView.addAnnotation(sample7)
        
        let sample8 = Venue(title: "Quarry Road Trail", content: "Quarry Road Trail is a popular commuter trail where Calgarians can walk and enjoy nature. The trail is the last major pathway connection in the city with a soft gravel-like surface. The trail has historical significance, as it was once used as a hail road during the late 1800s and early 1900s.", coordinate: CLLocationCoordinate2D(latitude: 51.0487161, longitude: -114.1281731))
        mapView.addAnnotation(sample8)
        
        let sample9 = Venue(title: "The Pumphouse Theatre", content: "The Pumphouse Theatre is a vibrant facility that supports the presentation of all art forms. It got its name from the fact that before it was a community performing arts space, it was a derelict No. 2 water pumping station-turned City of Calgary storage facility.", coordinate: CLLocationCoordinate2D(latitude: 51.0463187, longitude: -114.1121862))
        mapView.addAnnotation(sample9)
        
        let sample10 = Venue(title: "Old Firehall #6", content: "This Historical Landmark was constructed in 1906 and served as a fire station until 1967. Some say Firehall #6 is haunted, due mainly to the reports of residents hearing ringing bells and whining horses in the distance.", coordinate: CLLocationCoordinate2D(latitude: 51.0515338, longitude: -114.0886525))
        mapView.addAnnotation(sample10)
        
        let sample11 = Venue(title: "River Café", content: "This award-winning restaurant started out as a small full service café, and has since established itself as providing one of the finest dining experiences in Calgary.", coordinate: CLLocationCoordinate2D(latitude: 51.0548386, longitude: -114.0738256))
        mapView.addAnnotation(sample11)
        
        let sample12 = Venue(title: "Memorial Drive", content: "This historical landmark exhibits an annual display of over 3400 white crosses, from November 1st – 11th, to memorialize Southern Alberta soldiers who lost their lives fighting for Canada.", coordinate: CLLocationCoordinate2D(latitude: 51.0480174, longitude: -113.9956302))
        mapView.addAnnotation(sample12)
        
        let sample13 = Venue(title: "Reconciliation Bridge", content: "This bridge, which was originally named Langevin Bridge for Sir Hector-Louis Langevin, one of the Fathers of Canadian Confederation, was opened in 1910. It’s now referred to as the Reconciliation Bridge and connects Downtown Calgary with north-central Calgary communities.", coordinate: CLLocationCoordinate2D(latitude: 51.0499114, longitude: -114.0545118))
        mapView.addAnnotation(sample13)
        
        let sample14 = Venue(title: "Simmons Building", content: "What was once the site of a mattress factory warehouse is now home to Phil & Sebastian, Charbar, and Sidewalk Citizen which has led to its reputation as a must-visit food destination.", coordinate: CLLocationCoordinate2D(latitude: 51.0479477, longitude: -114.0519331))
        mapView.addAnnotation(sample14)
        
        let sample15 = Venue(title: "Riverwalk Calgary", content: "Riverwalk provides Calgary with an opportune location for walking, running, and cycling along the Bow and Elbow River. This award-winning pathway boasts dedicated pedestrian and cycle lanes and benches to rest.", coordinate: CLLocationCoordinate2D(latitude: 51.0479474, longitude: -114.0584992))
        mapView.addAnnotation(sample15)
        
        let sample16 = Venue(title: "Trout Beach Waterpark", content: "This park is perfect for families to attend one of the many events, take in the wildlife, have a picnic, or simply play.", coordinate: CLLocationCoordinate2D(latitude: 51.0479883, longitude: -114.0475378))
        mapView.addAnnotation(sample16)
        
        let sample17 = Venue(title: "Fort Calgary", content: "This site is the birthplace of Calgary, and therefore a must-see historical point of interest. The location was initially where the North West Mounted Police built a fort at the confluence of the Bow and Elbow Rivers and maintains its role in cross-cultural sharing between both indigenous and non-indigenous ancestors.", coordinate: CLLocationCoordinate2D(latitude: 51.044625, longitude: -114.0462187))
        mapView.addAnnotation(sample17)
        
        let sample18 = Venue(title: "Hunt House", content: "The Hunt House is the oldest Calgary building on its original site, and part of the historic heart of Calgary. It was built when the grassland was home to wild bison and settlers were establishing communities throughout the west.", coordinate: CLLocationCoordinate2D(latitude: 51.043875, longitude: -114.0439401))
        mapView.addAnnotation(sample18)
        
        
        
        
        
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
            
            view.sizeToFit()
            return view
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! Venue
        let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
        location.mapItem().openInMaps(launchOptions: launchOptions)
    }
    
}



