//
//  LandmarkNode.swift
//  Paddle Station
//
//  Created by Pat Sluth on 2018-01-31.
//  Copyright © 2018 Pat Sluth. All rights reserved.
//

import Foundation
import SceneKit
import CoreLocation
import ARKit





class LandmarkNode: SCNNode
{
	let landmark: Landmark
	let lockedWorldPosition: simd_float3
	var lockPosition: Bool = false
	
	fileprivate(set) lazy var text: SCNText = {
		let geometry = SCNText(string: nil, extrusionDepth: 0.0)
		geometry.alignmentMode = kCAAlignmentCenter
		geometry.flatness = 1.0		// 0.0 is very slow
		let material = SCNMaterial.constantLitWith(color: UIColor.white)
		geometry.materials = [material]
		
		return geometry
	}()
	
	fileprivate lazy var rotationNode: SCNNode = {
		let node = SCNNode()
		self.addChildNode(node)
		return node
	}()
	
	fileprivate lazy var pinNode: SCNNode = {
		let node = SCNNode()
		node.geometry = {
			let geometry = SCNSphere(radius: 1.0)
			let material = SCNMaterial.constantLitWith(color: UIColor.random)
			geometry.materials = [material]
			return geometry
		}()
		self.rotationNode.addChildNode(node)
		return node
	}()
	
	
	
	
	
	required init(landmark: Landmark, cameraWorldPosition: simd_float3)
	{
		self.landmark = landmark
		self.lockedWorldPosition = cameraWorldPosition
		
		
		
		super.init()
		
		
		
		let textNode = SCNNode(geometry: self.text)
		textNode.castsShadow = false
		textNode.scale = SCNVector3Make(0.3, 0.3, 0.3)
		let textNodeContainer = SCNNode()
		textNodeContainer.addConstraint(SCNBillboardConstraint(freeAxes: SCNBillboardAxis.Y))
		textNodeContainer.addChildNode(textNode)
		self.pinNode.addChildNode(textNodeContainer)
		
		
		
		self.isHidden = true
	}
	
	required init?(coder aDecoder: NSCoder)
	{
		fatalError(#function + " has not been implemented")
	}
	
	func updateFor(sceneView: ARSCNView, location: CLLocation, heading: CLHeading)
	{
		guard let pointOfView = sceneView.pointOfView else { return }
		guard let camera = sceneView.session.currentFrame?.camera else { return }
		let distance = SCNFloat(self.landmark.location.distance(from: location))
		let bearing = SCNFloat(location.coordinate.bearing(toCoordinate: self.landmark.location.coordinate))
		let altitudeDelta = SCNFloat(self.landmark.location.altitude - location.altitude)
		
		self.isHidden = !(25.0...500.0).contains(distance)
		guard !self.isHidden else { return }
		
		
		
		var _pinNodeWorldPosition = self.pinNode.simdWorldPosition
		_pinNodeWorldPosition.y = 0.0
		var _cameraWorldPosition = camera.worldPosition
		_cameraWorldPosition.y = 0.0
		
		let distanceVirtual = _pinNodeWorldPosition.distance(to: _cameraWorldPosition)
		let distanceError = abs(distanceVirtual - distance)
		let isOnScreen = sceneView.isNode(self.pinNode, insideFrustumOf: pointOfView)
		let updatePosition = !isOnScreen || (distanceError > 10.0) // force update if offscreen
		
		
		
		//			if landmarkNode.lockPosition {
		//				var a = landmarkNode.pinNode.simdWorldPosition
		//				a.y = 0.0
		//				var b = landmarkNode.cameraWorldPosition
		//				b.y = 0.0
		//				let virtualDistance = a.distance(to: b)
		//				let distanceError = abs(virtualDistance - distance)
		//
		//				if distanceError > 10.0 {
		//					landmarkNode.lockPosition = false
		//				} else {
		//					return
		//				}
		//
		////				print("actualDistance:", distance,
		////					  "virtualDistance:", virtualDistance1,
		////					  "distanceError:", distanceError1)
		////
		////
		////				landmarkNode.text.string = String(format: "%@\ndistance:%dm\nbearing:%.3frad\naltitudeDelta:%dm",
		////												  landmark.name,
		////												  Int(round(distance)),
		////												  bearing,
		////												  Int(round(altitudeDelta)))
		//
		//
		//			}
		
		
		
		if updatePosition {
			self.simdWorldPosition = camera.worldPosition
			self.rotationNode.simdWorldPosition = simd_float3.zero
			self.rotationNode.simdWorldOrientation = simd_quatf.zero
			self.pinNode.simdWorldPosition = {
				let trueNorth = simd_float3(0.0, 0.0, -1.0)
				return trueNorth * distance
			}()
			//			landmarkNode.pinNode.simdWorldPosition = landmarkNode.pinNode.worldPositionFor(targetWorldPosition: trueNorth * distance,
			//																										   relativeTo: camera.transform,
			//																										   smoothMovement: true)
			self.rotationNode.simdPosition = simd_float3.zero
			self.rotationNode.eulerAngles.y = -bearing
		}
		
		
		
		if isOnScreen {
			self.text.string = StringBuilder(line: self.landmark.name)
				.append(line: "distance:")
				.append(line: String(format: "\treal: %.2fm", distance))
				.append(line: String(format: "\tvirtual: %.2fm", distanceVirtual))
				.append(line: String(format: "\tΔ: %.2fm", distanceError))
				.append(line: String(format: "altitude: %.2fm (Δ: %.2fm)", self.landmark.location.altitude, altitudeDelta))
				.append(line: String(format: "bearing: %.3frad", bearing))
				.string
		}
		
		
		
		if updatePosition {
			self.worldPosition.y = camera.worldPosition.y + altitudeDelta
		}
		
		
		
		
		// UPDATE SCALE
		let minDistance: SCNFloat = 10.0
		let maxDistance: SCNFloat = 500.0
		let minRadius: SCNFloat = 0.10
		let maxRadius: SCNFloat = 10.0
		
		let percent = (distance - minDistance) / (maxDistance - minDistance)
		let radius = (percent * (maxRadius - minRadius)) + minRadius
		if let geometry = self.pinNode.geometry as? SCNSphere {
			//			geometry.radius = CGFloat(radius)
		}
		
//		print("actualDistance:", distance,
//			  "virtualDistance:", virtualDistance,
//			  "distanceError:", distanceError,
//			  "radius:", radius)
		
		
		
		
	}
}




