//
//  LandmarkRequest.swift
//  Paddle Station
//
//  Created by Pat Sluth on 2018-01-24.
//  Copyright © 2018 Pat Sluth. All rights reserved.
//

import Foundation
import CoreLocation





class LandmarkRequest: Encodable
{
	enum CodingKeys: String, CodingKey
	{
		case altitude
		case latitude
		case longitude
		case radius
	}
	
	
	
	
	
	let location: CLLocation
	let radius: CLLocationDistance
	
	
	
	
	
	init(location: CLLocation, radius: CLLocationDistance)
	{
		self.location = location
		self.radius = radius
	}
	
	func encode(to encoder: Encoder) throws
	{
		var container = encoder.container(keyedBy: CodingKeys.self)
		
		
		
		try container.encode(self.location.altitude, forKey: CodingKeys.altitude)
		try container.encode(self.location.coordinate.latitude, forKey: CodingKeys.latitude)
		try container.encode(self.location.coordinate.longitude, forKey: CodingKeys.longitude)
		try container.encode(self.radius, forKey: CodingKeys.radius)
	}
}




