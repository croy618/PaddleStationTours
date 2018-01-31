//
//  LocationManager.swift
//  Paddle Station
//
//  Created by Pat Sluth on 2018-01-24.
//  Copyright © 2018 Pat Sluth. All rights reserved.
//

import Foundation
import CoreLocation





protocol LocationManagerNotificationDelegate: class
{
	func locationManager(_ manager: LocationManager, didUpdateCurrentLocation currentLocation: CLLocation)
	func locationManager(_ manager: LocationManager, didUpdateCurrentHeading currentHeading: CLHeading)
}





final class LocationManager: NSObject
{
	static let shared: LocationManager = {
		let locationManager = LocationManager()
		return locationManager
	}()
	
	fileprivate lazy var clLocationManager: CLLocationManager = {
		let clLocationManager = CLLocationManager()
		clLocationManager.delegate = self
		clLocationManager.desiredAccuracy = kCLLocationAccuracyBest
		return clLocationManager
	}()
	
	fileprivate(set) var currentLocation: CLLocation? = nil {
		didSet
		{
			guard let currentLocation = self.currentLocation else { return }
			
			Broadcaster.notify(LocationManagerNotificationDelegate.self) {
				$0.locationManager(self, didUpdateCurrentLocation: currentLocation)
			}
		}
	}
	
	fileprivate(set) var currentHeading: CLHeading? = nil {
		didSet
		{
			guard let currentHeading = self.currentHeading else { return }
			
			Broadcaster.notify(LocationManagerNotificationDelegate.self) {
				$0.locationManager(self, didUpdateCurrentHeading: currentHeading)
			}
		}
	}
	
	
	
	
	
	fileprivate override init()
	{
		super.init()
		
		self.locationManager(self.clLocationManager, didChangeAuthorization: CLLocationManager.authorizationStatus())
	}
	
	func requestLocation()
	{
		self.clLocationManager.requestLocation()
	}
}





extension LocationManager: CLLocationManagerDelegate
{
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
	{
		switch status {
		case CLAuthorizationStatus.authorizedAlways, CLAuthorizationStatus.authorizedWhenInUse:
			self.clLocationManager.startUpdatingLocation()
			self.clLocationManager.startUpdatingHeading()
			break
		case CLAuthorizationStatus.denied:
			break
		case CLAuthorizationStatus.notDetermined, CLAuthorizationStatus.restricted:
			self.clLocationManager.requestWhenInUseAuthorization()
			break
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
	{
		self.currentLocation = locations.last
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading)
	{
		self.currentHeading = newHeading
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
	{
		print(error.localizedDescription)
	}
}




