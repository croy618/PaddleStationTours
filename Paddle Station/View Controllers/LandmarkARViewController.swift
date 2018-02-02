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
				//			guard let landMarks = landmarks else {
				//				Alertift.alert(title: "Error", message: "Failed to Recieve Landmarks")
				//					.action(.default("OK"))
				//					.show(on: self)
				//				return
				//			}
				
				self.resetScene(preservedLandmarks: landmarks)
				
				guard let landmarks = landmarks else { return }
				
				self.landmarkNodes = landmarks.map {
					let landmarkNode = LandmarkNode(landmark: $0)
					self.sceneView.scene.rootNode.addChildNode(landmarkNode)
//					landmarkNode.addConstraint(SCNTransformConstraint.positionConstraint(inWorldSpace: true, with: { node, position -> SCNVector3 in
//						guard let landmarkNode = node as? LandmarkNode else { return position }
//						guard let currentLocation = LocationManager.shared.currentLocation else { return position }
//						guard let currentHeading = LocationManager.shared.currentHeading else { return position }
//
//						let distance = landmarkNode.landmark.location.distance(from: currentLocation)
//						let rotation = currentLocation.coordinate.bearing(toCoordinate: landmarkNode.landmark.location.coordinate)
//
//
//
////						self.sceneView.scene.rootNode.trans
////						GLKQuaternionRotateVector3(<#T##quaternion: GLKQuaternion##GLKQuaternion#>, <#T##vector: GLKVector3##GLKVector3#>)
//
//
//
////						print("distance:", distance)
//						print("rotation:", rotation.toDeg, self.sceneView.scene.rootNode.eulerAngles.y)
////						print("heading:", currentHeading)
//						print()
//
//						// TODO: rotate and translate from the current CLLocation in SceneKit
//						return SCNVector3Zero
//					}))
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
		guard let pointOfView = self.sceneView.pointOfView else { return }
		guard let currentLocation = LocationManager.shared.currentLocation else { return }
		guard let currentHeading = LocationManager.shared.currentHeading else { return }

		
//		print(pointOfView.worldPosition, pointOfView.eulerAngles)
		
		
		for landmarkNode in self.landmarkNodes {
			let landmark = landmarkNode.landmark
			var distance = SCNFloat(landmark.location.distance(from: currentLocation))
			var bearing = SCNFloat(currentLocation.coordinate.bearing(toCoordinate: landmark.location.coordinate))

//			print("distance:", distance, "bearing:", bearing)
			
//			distance = 20.0
//			rotation = SCNFloat.pi
			
//			var test = pointOfView.worldPosition
			let trueNorth = SCNVector3(0.0, 0.0, -1.0)
//			var pivot = trueNorth - pointOfView.worldPosition// + trueNorth
			let pivot = pointOfView.worldPosition + trueNorth
//			var projected =
//			pivot = pivot.project(onto: trueNorth)
//			landmarkNode.worldPosition = trueNorth.normalized * distance
			landmarkNode.worldPosition = pivot.normalized * distance
			
			let rotationMatrix = SCNMatrix4MakeRotation(bearing, 0.0, -1.0, 0.0)
			landmarkNode.worldPosition *= rotationMatrix
//			print(landmarkNode.worldPosition)
			
			
			
			
			
			
//			landmarkNode.worldPosition = landmarkNode.worldPosition * rotationnn
//			landmarkNode.rotate(by: , aroundTarget: SCNVector3Zero)
//			print(landmarkNode.worldPosition, landmarkNode.worldPosition * rotationnn)currentLocation.altitude
			landmarkNode.worldPosition.y = pointOfView.worldPosition.y + SCNFloat(landmarkNode.landmark.location.altitude - currentLocation.altitude)
			// TODO: REMOVE
			landmarkNode.worldPosition.y = pointOfView.worldPosition.y + 25.0
			
			landmarkNode.text.string = String(format: "%@\ndistance:%dm\nbearing:%.3frad\nheadingAccuracy:%0.3frad\nlocationAccuracy:%dm",
											  landmark.name,
											  Int(round(distance)),
											  bearing,
											  currentHeading.headingAccuracy.toRad,
											  Int(round(currentLocation.horizontalAccuracy)))
			
			
			
			
			
			continue
			
			// reset to camera position/rotation
			landmarkNode.worldPosition = pointOfView.worldPosition
			landmarkNode.worldOrientation = SCNQuaternion(0.0, 0.0, 0.0, 1.0)
			landmarkNode.eulerAngles.y = pointOfView.eulerAngles.y - SCNFloat(10.0.toRad)
//			landmarkNode.eulerAngles.y = pointOfView.eulerAngles.y
//			landmarkNode.worldOrientation = pointOfView.worldOrientation
//			landmarkNode.eulerAngles.y = pointOfView.eulerAngles.y + SCNFloat(rotation)
			// rotate
//			landmarkNode.eulerAngles.y += pointOfView
			// move based on calculated distance and altitude
			landmarkNode.worldPosition = landmarkNode.zForward * -SCNFloat(distance)
			//			landmarkNode.runAction(SCNAction.move)
			
//			print(landmarkNode.worldPosition.y, pointOfView.worldPosition.y)
			//									print(pointOfView.worldPosition.angle(to: landmarkNode.worldPosition))
			//						self.sceneView.scene.rootNode.trans
			//						GLKQuaternionRotateVector3(<#T##quaternion: GLKQuaternion##GLKQuaternion#>, <#T##vector: GLKVector3##GLKVector3#>)
			
			
			
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
		}
	}
}

public extension SCNVector3
{
//	func rotated(byRad rad: SCNFloat) -> SCNVector3
//	{
//		let theta =
//		theta = 10 * Mathf.Deg2Rad; // Rotate 10° from origin along z-axis
//		azimuth = 20 * Mathf.Deg2Rad; // Rotate 20° from origin along the axis defined by theta
//
//		newVector.x = originalVector.x * Mathf.Cos(theta) * Mathf.Sin(azimuth);
//		newVector.y = originalVector.y * Mathf.Sin(theta) * Mathf.Sin(azimuth);
//		newVector.z = originalVector.z * Mathf.Cos(azimuth);
//	}

//	static func distance(from vectorA: SCNVector3, to vectorB: SCNVector3) -> SCNFloat
//	{
//		return SCNFloat(simd_distance(simd_float3(vectorA), simd_float3(vectorB)))
//	}
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



