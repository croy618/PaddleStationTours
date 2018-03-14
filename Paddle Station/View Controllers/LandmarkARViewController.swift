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
	
	@IBOutlet fileprivate var logoImageView: UIImageView!
	@IBOutlet fileprivate var statusLabel: UILabel!
	@IBOutlet fileprivate var debugLabel: UILabel!
	
	fileprivate let landmarkRequestDeltaDistance: SCNFloat = 10.0 // metres
	fileprivate var landmarkRequestWorldPosition: simd_float3?
	fileprivate var confirmedLocations = [CLLocation: simd_float3]()
	
	fileprivate var landmarkNodes = [LandmarkNode]()
	
	
	
	
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		let tap = UITapGestureRecognizer(target: self, action: #selector(self.onTap(_:)))
		self.sceneView.addGestureRecognizer(tap)
		
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
		self.resetTracking()
//		self.session.pause()
//		self.landmarkRequestWorldPosition = nil
	}
	
	@objc fileprivate func onTap(_ tap: UITapGestureRecognizer)
	{
		let position = tap.location(in: self.sceneView)
		let hitTestOptions: [SCNHitTestOption: Any] = [SCNHitTestOption.boundingBoxOnly: false,
													   SCNHitTestOption.searchMode: SCNHitTestSearchMode.all.rawValue]
		let hitTestResults = self.sceneView.hitTest(position, options: hitTestOptions)
		for hitTestResult in hitTestResults {
			guard let landmark = hitTestResult.node.landmarkNode?.landmark else { continue }
			
			if let landmarkURL = landmark.url {
				let safariViewController = SFSafariViewController(url: landmarkURL)
				self.present(safariViewController, animated: true, completion: nil)
				break
			}
		}
	}
	
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
		let preservingLandmarks = preservingLandmarks ?? []
		
		let currentLandmarkNodes = self.landmarkNodes
		self.landmarkNodes.removeAll()
		
		for landmarkNode in currentLandmarkNodes {
			landmarkNode.removeAllActions()
			landmarkNode.removeAllConstraints()
			if !preservingLandmarks.contains(landmarkNode.landmark) {
				landmarkNode.removeFromParentNode()
			} else {
				self.landmarkNodes.append(landmarkNode)
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
		DispatchQueue.main.async {
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
		}
	}
	
	fileprivate func requestLandmarksFor(location: CLLocation, heading: CLHeading)
	{
		guard let camera = self.sceneView.session.currentFrame?.camera else { return }
		
		self.landmarkRequestWorldPosition = camera.worldPosition
		
		
		
		let urlString = "http://159.65.73.98/landmarks/"
		
		let landmarkRequest = LandmarkRequest(location: location, radius: 500.0)
		
		let successHandler = { (responseObject: Any) -> Bool in
			
			guard let responseJsonDictionary = responseObject as? [[AnyHashable: Any]] else { return false }
			guard let landmarks = try? Landmarks.decode(jsonDictionary: responseJsonDictionary) else { return false }

//			let landmarks = Landmark.dummyLandmarks
			self.updateFor(landmarks: landmarks)
			
			return true
		}
		
		let errorHandler = { (requestError: RequestErrors) in
			print(self.stringForClass, #function, requestError.code, requestError.message)
			
			// Reset so we can attempt to request again right away
			// TODO: Uncomment
//			self.landmarkRequestWorldPosition = nil
			
			
			
			// TEMP: remove
//			let landmarks = Landmark.dummyLandmarks
//			self.updateFor(landmarks: landmarks)
			
			
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
		
		self.requestLandmarksFor(location: currentLocation, heading: currentHeading)
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
//		print(#function, camera.trackingState)
		
		DispatchQueue.main.async {
			self.updateDebugLabel()
			self.statusLabel.text = camera.trackingState.presentationString
		}
		
		// TODO: Animate logo in and out
		switch camera.trackingState {
		case ARCamera.TrackingState.normal:
			self.logoImageView.alpha = 0.0
			break
		default:
			self.logoImageView.alpha = 1.0
			self.landmarkRequestWorldPosition = nil
			break
		}
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





extension ARCamera.TrackingState
{
	var presentationString: String {
		switch self {
		case ARCamera.TrackingState.notAvailable:
			return "TRACKING UNAVAILABLE"
		case ARCamera.TrackingState.normal:
			return "TRACKING NORMAL"
		case ARCamera.TrackingState.limited(ARCamera.TrackingState.Reason.excessiveMotion):
			return "TRACKING LIMITED\nExcessive motion"
		case ARCamera.TrackingState.limited(ARCamera.TrackingState.Reason.insufficientFeatures):
			return "TRACKING LIMITED\nLow detail"
		case ARCamera.TrackingState.limited(ARCamera.TrackingState.Reason.initializing):
			return "Initializing"
		}
	}
	
	var recommendation: String? {
		switch self {
		case ARCamera.TrackingState.limited(ARCamera.TrackingState.Reason.excessiveMotion):
			return "Try slowing down your movement, or reset the session."
		case ARCamera.TrackingState.limited(ARCamera.TrackingState.Reason.insufficientFeatures):
			return "Try pointing at a flat surface, or reset the session."
		default:
			return nil
		}
	}
}



