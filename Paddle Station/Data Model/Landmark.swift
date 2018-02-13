//
//  Landmark.swift
//  Paddle Station
//
//  Created by Pat Sluth on 2018-01-24.
//  Copyright © 2018 Pat Sluth. All rights reserved.
//

import Foundation
import CoreLocation

import AFNetworking





typealias Landmarks = [Landmark]





protocol LandmarkConsumer: class
{
	func updateFor(landmarks: Landmarks)
}





final class Landmark: Codable, Equatable
{
	enum CodingKeys: String, CodingKey
	{
		case name
		case description
		case altitude
		case latitude
		case longitude
		case type
		case url
	}
	
	
	
	
	
	let name: String
	let description: String
	let location: CLLocation
	let type: String?
	let url: URL?
	
	internal static let dummyLandmarks = [
		Landmark(name: "MacEwan Hall Concerts",
				 description: "Concerts",
				 altitude: 1111.0,
				 latitude: 51.078866,
				 longitude: -114.130038,
				 type: "Default",
				 url: URL(string: "https://www.google.ca")),
		Landmark(name: "EEEL",
				 description: "EEEL",
				 altitude: 1115.0,
				 latitude: 51.081251,
				 longitude: -114.129400,
				 type: "Default",
				 url: URL(string: "https://www.google.ca")),
		Landmark(name: "ICT",
				 description: "ICT",
				 altitude: 1116.0,
				 latitude: 51.080222,
				 longitude: -114.130430,
				 type: "Default",
				 url: URL(string: "https://www.google.ca")),
		Landmark(name: "UCalgary Prarie Chicken",
				 description: "UCalgary Prarie Chicken",
				 altitude: 1108.0,
				 latitude: 51.078490,
				 longitude: -114.128182,
				 type: "Default",
				 url: URL(string: "https://www.google.ca")),
		Landmark(name: "Village Ice Cream",
				 description: "",
				 altitude: 1121.0,
				 latitude: 51.023775,
				 longitude: -114.114708,
				 type: "Default",
				 url: URL(string: "https://www.google.ca")),
		Landmark(name: "Phil & Sebastion",
				 description: "Coffee",
				 altitude: 1109.0,
				 latitude: 51.024050,
				 longitude: -114.108646,
				 type: "Default",
				 url: URL(string: "https://www.google.ca")),
		Landmark(name: "Original Joes",
				 description: "Bar",
				 altitude: 1106.0,
				 latitude: 51.023385,
				 longitude: -114.108989,
				 type: "Default",
				 url: URL(string: "https://www.google.ca")),
		Landmark(name: "Cor.fit",
				 description: "Gym",
				 altitude: 1041.0,
				 latitude: 51.000490,
				 longitude: -113.986376,
				 type: "Default",
				 url: URL(string: "https://www.google.ca")),
	]
	
	
	
	
	
	fileprivate init(name: String,
					 description: String,
					 altitude: CLLocationDistance,
					 latitude: CLLocationDegrees,
					 longitude: CLLocationDegrees,
					 type: String?,
					 url: URL?)
	{
		self.name = name
		self.description = description
		self.location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
								   altitude: altitude,
								   horizontalAccuracy: 0.0,
								   verticalAccuracy: 0.0,
								   timestamp: Date())
		self.type = type
		self.url = url
	}
	
	public required init(from decoder: Decoder) throws
	{
		let values = try decoder.container(keyedBy: CodingKeys.self)
		
		
		
		self.name = try values.decode(String.self, forKey: CodingKeys.name)
		self.description = try values.decode(String.self, forKey: CodingKeys.description)
		let altitude = try values.decode(CLLocationDistance.self, forKey: CodingKeys.altitude)
		let latitude = try values.decode(CLLocationDegrees.self, forKey: CodingKeys.latitude)
		let longitude = try values.decode(CLLocationDegrees.self, forKey: CodingKeys.longitude)
		self.location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
								   altitude: altitude,
								   horizontalAccuracy: 0.0,
								   verticalAccuracy: 0.0,
								   timestamp: Date())
		self.type = try values.decode(String?.self, forKey: CodingKeys.type)
		if let urlString = try values.decode(String?.self, forKey: CodingKeys.url) {
			self.url = URL(string: urlString)
		} else {
			self.url = nil
		}
	}
	
	func encode(to encoder: Encoder) throws
	{
		var container = encoder.container(keyedBy: CodingKeys.self)
		
		
		
		try container.encode(self.name, forKey: CodingKeys.name)
		try container.encode(self.description, forKey: CodingKeys.description)
		try container.encode(self.location.altitude, forKey: CodingKeys.altitude)
		try container.encode(self.location.coordinate.latitude, forKey: CodingKeys.latitude)
		try container.encode(self.location.coordinate.longitude, forKey: CodingKeys.longitude)
		try container.encode(self.type, forKey: CodingKeys.type)
		try container.encode(self.url, forKey: CodingKeys.url)
	}
	
	
	
	
	
	static public func ==(lhs: Landmark, rhs: Landmark) -> Bool
	{
		return (lhs.name == rhs.name &&
			lhs.location.altitude == rhs.location.altitude &&
			lhs.location.coordinate.latitude == rhs.location.coordinate.latitude &&
			lhs.location.coordinate.longitude == rhs.location.coordinate.longitude)
	}
}





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




