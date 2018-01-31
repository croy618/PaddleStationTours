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

import Alertift





class LandmarkARViewController: LandmarkViewController
{
	@IBOutlet fileprivate var sceneView: ARSCNView!
	fileprivate var session: ARSession {
		return self.sceneView.session
	}
	
	fileprivate let landmarkRequestDx = 10.0 // metres
	fileprivate var lastLandmarkRequestLocation: CLLocation? = nil {
		didSet
		{
			guard let x = self.lastLandmarkRequestLocation else {
				self.landmarks.removeAll()
				return
			}
			
			
			
			
			let landmarkRequest = LandmarkRequest(altitude: 0.0,
												  latitude: 0.0,
												  longitude: 0.0,
												  radius: 100)
			
			Landmark.requestLandmarksFor(landmarkRequest: landmarkRequest) { requestedLandmarks in
				//			guard let landMarks = landmarks else {
				//				Alertift.alert(title: "Error", message: "Failed to Recieve Landmarks")
				//					.action(.default("OK"))
				//					.show(on: self)
				//				return
				//			}
				
				if let requestedLandmarks = requestedLandmarks {
					self.landmarks = requestedLandmarks
				}
			}

		}
	}
	fileprivate var landmarks = [Landmark]()
//	{
//		didSet
//		{
////			landmarkNodes.removeAll()
//
////			if let landmarks = self.landmarks {
////				for landmark in landmarks {
////					// Create Node
////				}
////			}
//		}
//	}
	
//	fileprivate var landmarkNodes = [Landmark: SKNode]()
	
	
	
	
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		self.sceneView.delegate = self
		self.sceneView.session.delegate = self
		self.sceneView.automaticallyUpdatesLighting = true
//		self.sceneView.debugOptions = Settings.sharedInstance.debugOptions
		
		self.setupCamera()
		self.setupLights()
	}
	
	override func viewWillAppear(_ animated: Bool)
	{
		super.viewWillAppear(animated)
		
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
		
		self.session.pause()
		
		Broadcaster.unregister(LocationManagerNotificationDelegate.self, observer: self)
	}
	
	override func viewDidDisappear(_ animated: Bool)
	{
		super.viewDidDisappear(animated)
	}
	
	func setupCamera()
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
	
	func setupLights()
	{
		let nodeAmbientLight = SCNNode()
		nodeAmbientLight.light = {
			let light = SCNLight()
			light.type = SCNLight.LightType.ambient
			light.color = UIColor(white: 0.5, alpha: 1.0)
			light.castsShadow = false
			return light
		}()
		self.sceneView.scene.rootNode.addChildNode(nodeAmbientLight)
		
		
		
		let nodeOmniLight = SCNNode()
		nodeOmniLight.light = {
			let light = SCNLight()
			light.type = SCNLight.LightType.omni
			light.color = UIColor(white: 1.0, alpha: 1.0)
			light.castsShadow = false
			return light
		}()
		self.sceneView.scene.rootNode.addChildNode(nodeOmniLight)
	}
	
	fileprivate func resetTracking()
	{
		let configuration = ARWorldTrackingConfiguration()
		configuration.worldAlignment = ARConfiguration.WorldAlignment.gravityAndHeading
		configuration.planeDetection = ARWorldTrackingConfiguration.PlaneDetection.horizontal
		let options: ARSession.RunOptions = [.resetTracking, .removeExistingAnchors]
		self.session.run(configuration, options: options)
	}
}





extension LandmarkARViewController: LocationManagerNotificationDelegate
{
	func locationManager(_ manager: LocationManager, didUpdateCurrentLocation currentLocation: CLLocation)
	{
		if let lastLandmarkRequestLocation = self.lastLandmarkRequestLocation {
			let distance = lastLandmarkRequestLocation.distance(from: currentLocation)
			print(distance)
			if distance > self.landmarkRequestDx {
				self.lastLandmarkRequestLocation = currentLocation
			}
		} else {
			self.lastLandmarkRequestLocation = currentLocation
		}
	}
	
	func locationManager(_ manager: LocationManager, didUpdateCurrentHeading currentHeading: CLHeading)
	{
//		print(currentHeading)
	}
}





extension LandmarkARViewController: ARSCNViewDelegate
{
	func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval)
	{
//		DispatchQueue.main.async {
//			self.virtualObjectInteraction.updateTrackedNodesToTrackedScreenPositions()
//			self.updateFocusSquare()
//		}
//
//		// If light estimation is enabled, update the intensity of the model's lights and the environment map
//		let baseIntensity: CGFloat = 40.0
//		let lightingEnvironment = self.sceneView.scene.lightingEnvironment
//		if let lightEstimate = self.session.currentFrame?.lightEstimate {
//			lightingEnvironment.intensity = lightEstimate.ambientIntensity / baseIntensity
//		} else {
//			lightingEnvironment.intensity = baseIntensity
//		}
	}
	
	func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor)
	{
//		guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
//
//		DispatchQueue.main.async {
//			self.statusViewController.cancelScheduledMessage(for: StatusViewController.MessageType.PlaneEstimation)
//			self.statusViewController.showMessage("Surface Detected")
//
//			//            let planeVisualization = PlaneVisualization.init(planeAnchor: planeAnchor)
//			//            self.visualizationPlanes.updateValue(planeVisualization, forKey: planeAnchor.identifier)
//			//            node.addChildNode(planeVisualization)
//		}
//
//		self.updateQueue.async {
//			self.virtualObjectInteraction.adjustOntoPlaneAnchor(planeAnchor, using: node)
//		}
	}
	
	func renderer(_ renderer: SCNSceneRenderer, willUpdate node: SCNNode, for anchor: ARAnchor)
	{
		
	}
	
	func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor)
	{
//		guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
//
//		DispatchQueue.main.async {
//			self.visualizationPlanes[planeAnchor.identifier]?.updateFor(planeAnchor: planeAnchor)
//		}
//
//		self.updateQueue.async {
//			self.virtualObjectInteraction.adjustOntoPlaneAnchor(planeAnchor, using: node)
//		}
	}
	
	func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor)
	{
//		guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
//
//		self.visualizationPlanes.removeValue(forKey: planeAnchor.identifier)
	}
}





extension LandmarkARViewController: ARSessionDelegate
{
	func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera)
	{
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



