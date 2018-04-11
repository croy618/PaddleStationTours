//
//  Venue.swift
//  Paddle Station
//
//  Created by Nantong Dai on 2018-04-11.
//  Copyright © 2018 Pat Sluth. All rights reserved.
//

import MapKit
import AddressBook

class Venue: NSObject, MKAnnotation{
    let title: String?
    let content: String?
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, content: String?, coordinate: CLLocationCoordinate2D){
        self.title = title
        self.content = content
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String?{
        return content
    }
}
