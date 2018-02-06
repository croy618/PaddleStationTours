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
				self.resetScene()
				return
			}
			
			
			
			
			let landmarkRequest = LandmarkRequest(altitude: 0.0,
												  latitude: 0.0,
												  longitude: 0.0,
												  radius: 100)
			
			Landmark.requestLandmarksFor(landmarkRequest: landmarkRequest) { landmarks in
				
				if self.landmarkNodes.count > 0 {
					return
				}
				
				//			guard let landMarks = landmarks else {
				//				Alertift.alert(title: "Error", message: "Failed to Recieve Landmarks")
				//					.action(.default("OK"))
				//					.show(on: self)
				//				return
				//			}
				
				//				self.resetScene(preservedLandmarks: landmarks)	// TODO: Fix
				self.resetScene(preservedLandmarks: nil)
				
				guard var landmarks = landmarks else { return }
//				let previousLandmarks = self.landmarkNodes.map { return $0.landmark }
//				landmarks = landmarks.filter { return !previousLandmarks.contains($0) }
				
				self.landmarkNodes = landmarks.map {
					let landmarkNode = LandmarkNode(landmark: $0)
					self.sceneView.scene.rootNode.addChildNode(landmarkNode)
					return landmarkNode
				}
			}

		}
	}
//	fileprivate var landmarks = [Landmark]()
	fileprivate var landmarkNodes = [LandmarkNode]()
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
		
		self.resetScene()
		
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
//		configuration.worldAlignment = ARConfiguration.WorldAlignment.gravityAndHeading
		configuration.planeDetection = ARWorldTrackingConfiguration.PlaneDetection.horizontal
		let options: ARSession.RunOptions = [.resetTracking, .removeExistingAnchors]
		self.session.run(configuration, options: options)
	}
	
	fileprivate func resetScene(preservedLandmarks: [Landmark]? = nil)
	{
		if let preservedLandmarks = preservedLandmarks {
			for (index, landmarkNode) in self.landmarkNodes.enumerated() {
				// TODO: Test ==
				if !preservedLandmarks.contains(landmarkNode.landmark) {
					landmarkNode.removeFromParentNode()
					self.landmarkNodes.remove(at: index)
				} else {
					landmarkNode.removeAllConstraints()
					landmarkNode.removeAllActions()
				}
			}
		} else {
			for landmarkNode in self.landmarkNodes {
				landmarkNode.removeFromParentNode()
			}
			self.landmarkNodes.removeAll()
		}
	}
	
	fileprivate func updateLandmarkNodes()
	{
//		guard let pointOfView = self.sceneView.pointOfView else { return }
		guard let cameraTransform = self.sceneView.session.currentFrame?.camera.transform else { return }
		guard let currentLocation = LocationManager.shared.currentLocation else { return }
		guard let currentHeading = LocationManager.shared.currentHeading else { return }

		let cameraWorldPosition = cameraTransform.translation
		
		for landmarkNode in self.landmarkNodes {
			let landmark = landmarkNode.landmark
			let distance = SCNFloat(landmark.location.distance(from: currentLocation))
			let bearing = SCNFloat(currentLocation.coordinate.bearing(toCoordinate: landmark.location.coordinate))
			
			landmarkNode.isHidden = (distance > 500.0)
			guard !landmarkNode.isHidden else { continue }

			let trueNorth = simd_float3(0.0, 0.0, -1.0)
			
			landmarkNode.simdWorldPosition = cameraWorldPosition
			landmarkNode.rootNode.simdWorldPosition = simd_float3.zero
			landmarkNode.rootNode.simdWorldOrientation = simd_quatf.zero
//			landmarkNode.destinationNode.worldPosition = trueNorth * distance
			landmarkNode.destinationNode.simdWorldPosition = landmarkNode.destinationNode.worldPositionFor(targetWorldPosition: trueNorth * distance,
																										   relativeTo: cameraTransform,
																										   smoothMovement: true)
			landmarkNode.rootNode.simdPosition = simd_float3.zero
			landmarkNode.rootNode.eulerAngles.y = -bearing
			
			
			
			landmarkNode.text.string = String(format: "%@\ndistance:%dm\nbearing:%.3frad\nheadingAccuracy:%0.3frad\nlocationAccuracy:%dm",
											  landmark.name,
											  Int(round(distance)),
											  bearing,
											  currentHeading.headingAccuracy.toRad,
											  Int(round(currentLocation.horizontalAccuracy)))
			
			
//			let virtualDistance = simd_length(landmarkNode.destinationNode.simdWorldPosition - cameraWorldPosition)
			let virtualDistance = landmarkNode.destinationNode.simdWorldPosition.distance(to: cameraWorldPosition)
			print("worldPosition:", cameraWorldPosition,
				  "distance:", distance,
				  "virtualDistance:", virtualDistance,
				  "error:", abs(virtualDistance - distance))
			
			
			
//			landmarkNode.worldPosition.y = pointOfView.worldPosition.y + SCNFloat(landmarkNode.landmark.location.altitude - currentLocation.altitude)
			// TODO: REMOVE
			landmarkNode.simdWorldPosition.y = cameraWorldPosition.y + 50.0

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
				print()
				
				
				
				
				
				
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
}





extension LandmarkARViewController: LocationManagerNotificationDelegate
{
	func locationManager(_ manager: LocationManager, didUpdateCurrentLocation currentLocation: CLLocation)
	{
		if let lastLandmarkRequestLocation = self.lastLandmarkRequestLocation {
			let distance = lastLandmarkRequestLocation.distance(from: currentLocation)
			if distance > self.landmarkRequestDx {
				print(#function, distance)
				self.lastLandmarkRequestLocation = currentLocation
			}
		} else {
			self.lastLandmarkRequestLocation = currentLocation
		}
		
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



