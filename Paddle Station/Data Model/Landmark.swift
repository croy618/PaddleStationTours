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





final class Landmark: Decodable
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
	let altitude: CLLocationDistance
	let latitude: CLLocationDegrees
	let longitude: CLLocationDegrees
	let type: String?
	let url: URL?
	
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
		self.altitude = altitude
		self.latitude = latitude
		self.longitude = longitude
		self.type = type
		self.url = url
	}
	
	fileprivate static let dummyLandmarks = [Landmark(name: "Phil & Sebastion",
													  description: "Coffee",
													  altitude: 100.0,
													  latitude: 51.024050,
													  longitude: 114.108646,
													  type: "Default",
													  url: URL(string: "www.google.ca"))]
	
	
	
	
	
	class func requestLandmarksFor(landmarkRequest: LandmarkRequest, completion: @escaping (_ requestedLandmarks: [Landmark]?) -> Void)
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
					parameters: try? landmarkRequest.encodeDictionary(),
					progress: nil,
					success: success,
					failure: failure)
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




