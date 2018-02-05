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





final class Landmark: Decodable, Equatable
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
	
	fileprivate static let dummyLandmarks = [
//		Landmark(name: "MacEwan Hall Concerts",
//				 description: "Concerts",
//				 altitude: 0.0,
//				 latitude: 51.078866,
//				 longitude: -114.130038,
//				 type: "Default",
//				 url: URL(string: "machallconcerts.com")),
//		Landmark(name: "EEEL",
//				 description: "EEEL",
//				 altitude: 25.0,
//				 latitude: 51.081251,
//				 longitude: -114.129400,
//				 type: "Default",
//				 url: URL(string: "www.google.ca")),
//		Landmark(name: "ICT",
//				 description: "ICT",
//				 altitude: 50.0,
//				 latitude: 51.080222,
//				 longitude: -114.130430,
//				 type: "Default",
//				 url: URL(string: "www.google.ca")),
//		Landmark(name: "UCalgary Prarie Chicken",
//				 description: "UCalgary Prarie Chicken",
//				 altitude: 50.0,
//				 latitude: 51.078490,
//				 longitude: -114.128182,
//				 type: "Default",
//				 url: URL(string: "www.google.ca")),
		Landmark(name: "Village Ice Cream",
				 description: "",
				 altitude: 50.0,
				 latitude: 51.023775,
				 longitude: -114.114708,
				 type: "Default",
				 url: URL(string: "www.google.ca")),
//		Landmark(name: "Phil & Sebastion",
//				 description: "Coffee",
//				 altitude: 100.0,
//				 latitude: 51.024050,
//				 longitude: -114.108646,
//				 type: "Default",
//				 url: URL(string: "www.google.ca")),
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
	
	class func requestLandmarksFor(landmarkRequest: LandmarkRequest, completion: @escaping (_ landmarks: [Landmark]?) -> Void)
	{
		let urlString = "TODO"
		
		let manager: AFHTTPSessionManager = {
			let manager = AFHTTPSessionManager()
			
			manager.requestSerializer = AFJSONRequestSerializer()
			manager.requestSerializer.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
			
			return manager
		}()
		
		let success = { (dataTask: URLSessionDataTask, responseObject: Any?) in
			
			guard let responseJsonDictionary = responseObject as? [AnyHashable: Any] else {
				completion(nil)
				return
			}
			
			completion(try? [Landmark].decode(jsonDictionary: responseJsonDictionary))
		}
		
		let failure = { (dataTask: URLSessionDataTask?, error: Error) -> Void in
			let error = error as NSError
			print(error.code, error.localizedDescription)
			
			completion(self.dummyLandmarks)
		}
		
		manager.get(urlString,
					parameters: try? landmarkRequest.encodeDictionary(AnyHashable.self, Any.self),
					progress: nil,
					success: success,
					failure: failure)
	}
	
	
	
	
	
	static public func == (lhs: Landmark, rhs: Landmark) -> Bool
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
	
	
	
	
	
	let altitude: CLLocationDistance
	let latitude: CLLocationDegrees
	let longitude: CLLocationDegrees
	let radius: CLLocationDistance
	
	
	
	
	
	init(altitude: CLLocationDistance,
		 latitude: CLLocationDegrees,
		 longitude: CLLocationDegrees,
		 radius: CLLocationDistance)
	{
		self.altitude = altitude
		self.latitude = latitude
		self.longitude = longitude
		self.radius = radius
	}
}




