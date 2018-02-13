//
//  LandmarkARViewController.swift
//  Paddle Station
//
//  Created by Pat Sluth on 2017-12-01.
//  Copyright © 2017 Pat Sluth. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import CoreLocation
import SafariServices

import Alertift





class LandmarkARViewController: LandmarkViewController
{
	@IBOutlet fileprivate var sceneView: ARSCNView!
	fileprivate var session: ARSession {
		return self.sceneView.session
	}
	
	@IBOutlet fileprivate var debugLabel: UILabel!
	
	fileprivate let landmarkRequestDeltaDistance: SCNFloat = 10.0 // metres
	fileprivate var landmarkRequestWorldPosition: simd_float3?
	fileprivate var confirmedLocations = [CLLocation: simd_float3]()
	
	fileprivate var landmarkNodes = [LandmarkNode]()
	
	
	
	
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		self.sceneView.delegate = self
		self.sceneView.session.delegate = self
		self.sceneView.automaticallyUpdatesLighting = true
//		self.sceneView.debugOptions = Settings.sharedInstance.debugOptions
		
		self.setupCamera()
	}
	
	override func viewWillAppear(_ animated: Bool)
	{
		super.viewWillAppear(animated)
		
		self.resetTracking()
		
		Broadcaster.register(LocationManagerNotificationDelegate.self, observer: self)
		LocationManager.shared.requestLocation()
	}
	
	override func viewDidAppear(_ animated: Bool)
	{
		super.viewDidAppear(animated)
		
		self.resetTracking()
	}
	
	override func viewWillDisappear(_ animated: Bool)
	{
		super.viewWillDisappear(animated)
		
		Broadcaster.unregister(LocationManagerNotificationDelegate.self, observer: self)
	}
	
	override func viewDidDisappear(_ animated: Bool)
	{
		super.viewDidDisappear(animated)
		
		self.resetScene()
		self.session.pause()
		self.landmarkRequestWorldPosition = nil
	}
	
//	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
//	{
//		print(#function)
//		guard let landmark = self.landmarkNodes.first?.landmark else { return }
//		print(landmark.url)
//		guard let landmarkURL = landmark.url else { return }
//		
//		print(landmarkURL, self.navigationController)
//		let safariViewController = SFSafariViewController(url: landmarkURL)
//		self.present(safariViewController, animated: true, completion: nil)
//	}
	
	@IBAction fileprivate func resetButtonClicked(_ sender: UIButton)
	{
		sender.isEnabled = false
		
		self.resetScene()
		self.resetTracking()
		
		// Disable restart for a while in order to give the session time to restart.
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5.0) {
			sender.isEnabled = true
		}
	}
}





fileprivate extension LandmarkARViewController
{
	fileprivate func setupCamera()
	{
		guard let camera = self.sceneView.pointOfView?.camera else {
			fatalError("Expected a valid `pointOfView` from the scene.")
		}
		
		/*
		Enable HDR camera settings for the most realistic appearance
		with environmental lighting and physically based materials.
		*/
		camera.wantsHDR = true
		camera.exposureOffset = -1
		camera.minimumExposure = -1
		camera.maximumExposure = 3
	}
	
	fileprivate func resetTracking()
	{
		let configuration = ARWorldTrackingConfiguration()
		configuration.worldAlignment = ARConfiguration.WorldAlignment.gravityAndHeading
		configuration.planeDetection = ARWorldTrackingConfiguration.PlaneDetection.horizontal
		let options: ARSession.RunOptions = [.resetTracking, .removeExistingAnchors]
		self.session.run(configuration, options: options)
	}
	
	fileprivate func resetScene(preservingLandmarks: Landmarks? = nil)
	{
		var preservingLandmarks = preservingLandmarks ?? []
		
		for (index, landmarkNode) in self.landmarkNodes.enumerated() {
			// TODO: Test ==
			if !preservingLandmarks.contains(landmarkNode.landmark) {
				self.landmarkNodes.remove(at: index)
				landmarkNode.removeFromParentNode()
			} else {
				landmarkNode.removeAllConstraints()
				landmarkNode.removeAllActions()
			}
		}
	}
	
	fileprivate func updateDebugLabel()
	{
		var debugText = ""
		
		if let camera = self.sceneView.session.currentFrame?.camera {
			debugText += String(format: "cameraPosition: %@\n", String(describing: camera.worldPosition))
			if let trackingState = String(describing: camera.trackingState).components(separatedBy: ".").last {
				debugText += String(format: "trackingState: %@\n", trackingState)
			}
		}
		
		if let currentLocation = LocationManager.shared.currentLocation {
			debugText += String(format: "altitude: %.3f m\n", currentLocation.altitude)
			debugText += String(format: "verticalAccuracy: %.3f m\n", currentLocation.verticalAccuracy)
			debugText += String(format: "horizontalAccuracy: %.3f m\n", currentLocation.horizontalAccuracy)
		}
		
		if let currentHeading = LocationManager.shared.currentHeading {
			debugText += String(format: "trueHeading: %.3f rad\n", currentHeading.trueHeading.toRad)
			debugText += String(format: "headingAccuracy: %.3f rad\n", currentHeading.headingAccuracy.toRad)
		}
		
		self.debugLabel.text = debugText
	}
	
	fileprivate func updateLandmarkNodes()
	{
//		guard let pointOfView = self.sceneView.pointOfView else { return }
//		guard let camera = self.sceneView.session.currentFrame?.camera else { return }
		guard let currentLocation = LocationManager.shared.currentLocation else { return }
		guard let currentHeading = LocationManager.shared.currentHeading else { return }
		
		self.updateDebugLabel()
		
		for landmarkNode in self.landmarkNodes {
			landmarkNode.updateFor(sceneView: self.sceneView,
								   location: currentLocation,
								   heading: currentHeading)
		}
		
		//		fileprivate func updateLandmarkNodes()
		//		{
		//			guard let pointOfView = self.sceneView.pointOfView else { return }
		//			guard let currentLocation = LocationManager.shared.currentLocation else { return }
		//			guard let currentHeading = LocationManager.shared.currentHeading else { return }
		//
		//
		//			//		print(pointOfView.worldPosition, pointOfView.eulerAngles)
		//
		//
		//			for landmarkNode in self.landmarkNodes {
		//				let landmark = landmarkNode.landmark
		//				var distance = SCNFloat(landmark.location.distance(from: currentLocation))
		//				var bearing = SCNFloat(currentLocation.coordinate.bearing(toCoordinate: landmark.location.coordinate))
		//
		//				//			print("distance:", distance, "bearing:", bearing)
		//
		//				//			distance = 10.0
		//				//			rotation = SCNFloat.pi
		//
		//				let trueNorth = SCNVector3(pointOfView.worldPosition.x, pointOfView.worldPosition.y, pointOfView.worldPosition.z - distance)
		//				//			let pivot = pointOfView.worldPosition + trueNorth
		//
		//
		//				landmarkNode.transform = SCNMatrix4Identity
		//				landmarkNode.worldPosition = pointOfView.worldPosition
		//
		//				let rotation = SCNMatrix4MakeRotation(bearing, 0.0, 1.0, 0.0)
		//				landmarkNode.transform = SCNMatrix4Mult(landmarkNode.transform, rotation)
		//
		//				landmarkNode.worldPosition = landmarkNode.zForward.normalized * distance
		//				//			print("PAT", pointOfView.worldFront)
		//				//			landmarkNode.worldPosition = pointOfView.worldFront.normalized * distance
		//
		//				//			return
		//
		//
		//				//			let trueNorth = SCNVector3(0.0, 0.0, -1.0)
		//				//			let pivot = pointOfView.worldPosition + trueNorth
		//				//			landmarkNode.worldPosition = pivot.normalized * distance
		//
		//
		//				//			landmarkNode.worldPosition.y = pointOfView.worldPosition.y + SCNFloat(landmarkNode.landmark.location.altitude - currentLocation.altitude)
		//				//			// TODO: REMOVE
		//				//			landmarkNode.worldPosition.y = pointOfView.worldPosition.y// + 25.0
		//
		//
		//
		//
		//				////			let quat = GLKQuaternionMakeWithAngleAndVector3Axis(bearing, pointOfView.worldPosition as GLKVector3)
		//				////			let a = SCNQuaternion(0.0, 0.0, 1.0, bearing)
		//				////			landmarkNode.worldPosition *= a
		//				//			let rotationMatrix = SCNMatrix4MakeRotation(bearing, 0.0, 0.0, pointOfView.worldPosition.z)
		//				////			let rotationMatrix = SCNMatrix4MakeRotation(bearing, pointOfView.worldPosition.x, pointOfView.worldPosition.y, pointOfView.worldPosition.z)
		//				//			landmarkNode.worldPosition *= rotationMatrix
		//				////			print(landmarkNode.worldPosition)
		//
		//
		//
		//
		//
		//
		//
		//
		//				landmarkNode.text.string = String(format: "%@\ndistance:%dm\nbearing:%.3frad\nheadingAccuracy:%0.3frad\nlocationAccuracy:%dm",
		//												  landmark.name,
		//												  Int(round(distance)),
		//												  bearing,
		//												  currentHeading.headingAccuracy.toRad,
		//												  Int(round(currentLocation.horizontalAccuracy)))
		//
		//
		//
		//
		//
		//
		//
		//				let virtualDistance = pointOfView.worldPosition.distance(to: landmarkNode.worldPosition)
		//				print("worldPosition:", pointOfView.worldPosition,
		//					  "distance:", distance,
		//					  "virtualDistance:", virtualDistance,
		//					  "error:", abs(virtualDistance - distance))
		//
		//
		//				continue
		//
		//				// reset to camera position/rotation
		//				landmarkNode.worldPosition = pointOfView.worldPosition
		//				landmarkNode.worldOrientation = SCNQuaternion(0.0, 0.0, 0.0, 1.0)
		//				landmarkNode.eulerAngles.y = pointOfView.eulerAngles.y - SCNFloat(10.0.toRad)
		//				//			landmarkNode.eulerAngles.y = pointOfView.eulerAngles.y
		//				//			landmarkNode.worldOrientation = pointOfView.worldOrientation
		//				//			landmarkNode.eulerAngles.y = pointOfView.eulerAngles.y + SCNFloat(rotation)
		//				// rotate
		//				//			landmarkNode.eulerAngles.y += pointOfView
		//				// move based on calculated distance and altitude
		//				landmarkNode.worldPosition = landmarkNode.zForward * -SCNFloat(distance)
		//				//			landmarkNode.runAction(SCNAction.move)
		//
		//				//			print(landmarkNode.worldPosition.y, pointOfView.worldPosition.y)
		//				//									print(pointOfView.worldPosition.angle(to: landmarkNode.worldPosition))
		//				//						self.sceneView.scene.rootNode.trans
		//				//						GLKQuaternionRotateVector3(<#T##quaternion: GLKQuaternion##GLKQuaternion#>, <#T##vector: GLKVector3##GLKVector3#>)
		
		
		
		//			print("a:", pointOfView.worldPosition)
		//			print(pointOfView.eulerAngles)
		//			print(landmarkNode.worldPosition)
		//			print(landmarkNode.worldPosition.distance(to: pointOfView.worldPosition))
		
		
		
		//			landmarkNode.worldPosition.y += -5.0//SCNFloat(landmarkNode.landmark.location.altitude)
		
		
		
		
		//			print(rotation, currentHeading.trueHeading.toRad, pointOfView.worldOrientation.z, pointOfView.eulerAngles.z)
		//		print("rotation:", rotation.toDeg, self.sceneView.scene.rootNode.eulerAngles.y)
		//						print("heading:", currentHeading)
//		print()
		
		
		
		
		
		
		//			landmarkNode.runAction(SCNAction.rotate(by: CGFloat(rotation), around: SCNVector3(0.0, 1.0, 0.0), duration: 0.0))
		//			landmarkNode.runAction(SCNAction.rotate(by: CGFloat(rotation), around: SCNVector3(0.0, 1.0, 0.0), duration: 0.0),
		//								   completionHandler: {
		//
		//
		//
		//			})
		
		//
		//			}
		//		}
	}
	
	fileprivate func requestLandmarksFor(location: CLLocation)
	{
		guard let camera = self.sceneView.session.currentFrame?.camera else { return }
		
		print(#function)
		
		self.landmarkRequestWorldPosition = camera.worldPosition
		
		
		
		
		let urlString = "TODO"
		
		let landmarkRequest = LandmarkRequest(location: location, radius: 100.0)
		
		let successHandler = { (responseJsonDictionary: [AnyHashable: Any]) -> Bool in
			
			// TODO: uncomment
			//				guard let landmarks = try? Landmarks.decode(jsonDictionary: responseJsonDictionary) else {
			//					return false
			//				}
			
			let landmarks = Landmark.dummyLandmarks
			
			self.updateFor(landmarks: landmarks)
			
			return true
		}
		
		let errorHandler = { (requestError: RequestErrors) in
			print(self.stringForClass, #function, requestError.code, requestError.message)
			
			// Reset so we can attempt to request again right away
			// TODO: Uncomment
//			self.landmarkRequestWorldPosition = nil
			
			
			
			// TEMP: remove
			let landmarks = Landmark.dummyLandmarks
			self.updateFor(landmarks: landmarks)
			
			
			//			guard let landMarks = landmarks else {
			//				Alertift.alert(title: "Error", message: "Failed to Recieve Landmarks")
			//					.action(.default("OK"))
			//					.show(on: self)
			//				return
			//			}
		}
		
		let dataTaskHandler = { (dataTask: URLSessionDataTask) in
		}
		
		let requestIdentifier = self.stringForClass
		
		RequestController.performRequestFor(requestIdentifier: requestIdentifier,
											requestType: RequestController.RequestType.Get,
											urlString: urlString,
											parameters: try? landmarkRequest.encodeDictionary([AnyHashable: Any].self),
											allowDuplicateRequests: false,
											cancelPreviousRequests: true,
											successHandler: successHandler,
											errorHandler: errorHandler,
											dataTaskHandler: dataTaskHandler)
	}
}





extension LandmarkARViewController: LandmarkConsumer
{
	func updateFor(landmarks: Landmarks)
	{
		guard let camera = self.sceneView.session.currentFrame?.camera else { return }
		
		
		
		var preservedLandmarks = Landmarks()

		for landmarkNode in self.landmarkNodes {
			if landmarks.contains(landmarkNode.landmark) {
				preservedLandmarks.append(landmarkNode.landmark)
			}
		}
		
		self.resetScene(preservingLandmarks: preservedLandmarks)
		
		
		
		let previousLandmarks = self.landmarkNodes.map { return $0.landmark }
		let newLandmarks = landmarks.filter { return !previousLandmarks.contains($0) }
		
		for newLandmark in newLandmarks {
			let landmarkNode = LandmarkNode(landmark: newLandmark, cameraWorldPosition: camera.worldPosition)
			self.sceneView.scene.rootNode.addChildNode(landmarkNode)
			self.landmarkNodes.append(landmarkNode)
		}

		
		
		self.updateLandmarkNodes()
	}
}





extension LandmarkARViewController: LocationManagerNotificationDelegate
{
	func locationManager(_ manager: LocationManager, didUpdateCurrentLocation currentLocation: CLLocation)
	{
//		guard let camera = self.sceneView.session.currentFrame?.camera else { return }
////
////		// TODO: TEST
////		self.confirmedLocations.updateValue(camera.worldPosition, forKey: currentLocation)
//
//		if let landmarkRequestWorldPosition = self.landmarkRequestWorldPosition {
//
//		} else {
//			self.landmarkRequestWorldPosition = camera.worldPosition
//		}
//
//
//		if let lastLandmarkRequestLocation = self.lastLandmarkRequestLocation {
////			let distance = lastLandmarkRequestLocation.distance(from: currentLocation)
////			if distance > self.landmarkRequestDx {
////				print(#function, distance)
////				self.lastLandmarkRequestLocation = currentLocation
////			}
//		} else {
//			self.lastLandmarkRequestLocation = currentLocation
//		}
//
		self.updateLandmarkNodes()
	}
	
	func locationManager(_ manager: LocationManager, didUpdateCurrentHeading currentHeading: CLHeading)
	{
		self.updateLandmarkNodes()
	}
}





extension LandmarkARViewController: ARSCNViewDelegate
{
	func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval)
	{
		guard let camera = self.sceneView.session.currentFrame?.camera else { return }
		switch camera.trackingState {
		case ARCamera.TrackingState.normal:		break
		default: 								return
		}
		guard let currentLocation = LocationManager.shared.currentLocation else { return }
		guard let currentHeading = LocationManager.shared.currentHeading else { return }
	
		let deltaWorldPosition = self.landmarkRequestWorldPosition?.distance(to: camera.worldPosition) ?? SCNFloat.infinity
		guard deltaWorldPosition >= self.landmarkRequestDeltaDistance else { return }
		
		self.requestLandmarksFor(location: currentLocation)
	}
	
	func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor)
	{
	}
	
	func renderer(_ renderer: SCNSceneRenderer, willUpdate node: SCNNode, for anchor: ARAnchor)
	{
		
	}
	
	func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor)
	{
	}
	
	func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor)
	{
	}
}





extension LandmarkARViewController: ARSessionDelegate
{
	// TODO: dont request location until normal tracking state
	func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera)
	{
		DispatchQueue.main.async {
			self.updateDebugLabel()
		}
		
//		self.statusViewController.showTrackingQualityInfo(for: camera.trackingState, autoHide: true)
//
//		switch camera.trackingState {
//		case ARCamera.TrackingState.notAvailable, ARCamera.TrackingState.limited:
//			self.statusViewController.escalateFeedback(for: camera.trackingState, inSeconds: 3.0)
//		case ARCamera.TrackingState.normal:
//			self.statusViewController.cancelScheduledMessage(for: StatusViewController.MessageType.TrackingStateEscalation)
//		}
	}
	
	func session(_ session: ARSession, didFailWithError error: Error)
	{
//		guard error is ARError else { return }
//
//		let errorWithInfo = error as NSError
//		let messages = [
//			errorWithInfo.localizedDescription,
//			errorWithInfo.localizedFailureReason,
//			errorWithInfo.localizedRecoverySuggestion
//		]
//
//		// Use `flatMap(_:)` to remove optional error messages.
//		let errorMessage = messages.flatMap({ $0 }).joined(separator: "\n")
//
//		DispatchQueue.main.async {
//			self.displayErrorMessage(title: "The AR session failed.", message: errorMessage)
//		}
	}
	
	func sessionWasInterrupted(_ session: ARSession)
	{
//		self.blurView.isHidden = false
//		self.statusViewController.showMessage("""
//        SESSION INTERRUPTED
//        The session will be reset after the interruption has ended.
//        """, autoHide: false)
	}
	
	func sessionInterruptionEnded(_ session: ARSession)
	{
//		self.blurView.isHidden = true
//		self.statusViewController.showMessage("RESETTING SESSION")
//
//		self.restartExperience(resetTracking: true)
	}
}



