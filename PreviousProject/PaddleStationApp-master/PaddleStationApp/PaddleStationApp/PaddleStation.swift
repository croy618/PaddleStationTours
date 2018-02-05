//
//  PaddleStation.swift
//  PaddleStationApp
//
//  Created by Jamie Mills on 2017-11-20.
//  Copyright © 2017 PaddleStation. All rights reserved.
//

import Foundation
import MapKit

class PaddleStation: NSObject, MKAnnotation {
    let title: String?
    let locationName: String
    let type: String
    let coordinate: CLLocationCoordinate2D
    
    //To temporarily handle availability - TODO: Find a solution such that availability will be consistent accross devices
    let kayakInventory: Int
    let raftInventory: Int
    
    var kayaksAvailable: Int
    var raftsAvailable: Int
    
    init(title: String, locationName: String, type: String, coordinate: CLLocationCoordinate2D, numKayaks: Int, numRafts: Int) {
        self.title = title
        self.locationName = locationName
        self.type = type
        self.coordinate = coordinate
        self.kayakInventory = numKayaks
        self.raftInventory = numRafts
        self.kayaksAvailable = kayakInventory
        self.raftsAvailable = raftInventory
    }
}
