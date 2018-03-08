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





extension SCNNode
{
	var landmarkNode: LandmarkNode? {
		var node: SCNNode? = self
		while let _ = node {
			if let landmarkNode = node as? LandmarkNode {
				return landmarkNode
			}
			node = node?.parent
		}
		return nil
	}
}





class LandmarkNode: SCNNode
{
	let landmark: Landmark
	let lockedWorldPosition: simd_float3
	var pinBackgroundColor = UIColor.black {
		didSet
		{
			// TODO: update
		}
	}
	
	
	
	fileprivate lazy var rotationNode: SCNNode = {
		let node = SCNNode()
		self.addChildNode(node)
		return node
	}()
	
	fileprivate lazy var pinAnchorNode: SCNNode = {
		let node = SCNNode()
		self.rotationNode.addChildNode(node)
		return node
	}()
	
	fileprivate(set) lazy var text: SCNText = {
		let geometry = SCNText(string: nil, extrusionDepth: 0.0)
		geometry.alignmentMode = kCAAlignmentCenter
		geometry.flatness = 1.0		// 0.0 is very slow
		let material = SCNMaterial.constantLitWith(color: UIColor.white)
		geometry.materials = [material]
		
		return geometry
	}()
	
	fileprivate lazy var textNode: SCNNode = {
		let node = SCNNode(geometry: self.text)
		node.castsShadow = false
//		node.scale = SCNVector3Make(0.3, 0.3, 0.3)
		return node
	}()
	
	fileprivate lazy var pinBackgroundNode: SCNNode = {
		let node = SCNNode()
		node.geometry = {
			let geometry = SCNPlane(width: 0.0, height: 0.0)
			let material = SCNMaterial.constantLitWith(color: self.pinBackgroundColor)
			geometry.materials = [material]
			return geometry
		}()
		return node
	}()
	
	fileprivate lazy var pinArrowNode: SCNNode = {
		let node = SCNNode()
		node.geometry = {
			let geometry = SCNPlane(width: 0.0, height: 0.0)
			let material = SCNMaterial.constantLitWith(color: self.pinBackgroundColor)
			geometry.materials = [material]
			return geometry
		}()
		return node
	}()
	
	
	
//	public init(location: CLLocation?, image: UIImage) {
//		self.image = image
//
//		let plane = SCNPlane(width: image.size.width / 100, height: image.size.height / 100)
//		plane.firstMaterial!.diffuse.contents = image
//		plane.firstMaterial!.lightingModel = .constant
//
//		annotationNode = SCNNode()
//		annotationNode.geometry = plane
//
//		super.init(location: location)
//
//		let billboardConstraint = SCNBillboardConstraint()
//		billboardConstraint.freeAxes = SCNBillboardAxis.Y
//		constraints = [billboardConstraint]
//
//		addChildNode(anno`tationNode)
//	}
	
	required init(landmark: Landmark, cameraWorldPosition: simd_float3)
	{
		self.landmark = landmark
		self.lockedWorldPosition = cameraWorldPosition
		
		
		
		super.init()
		
		
		
		let textNodeContainer = SCNNode()
		textNodeContainer.addConstraint(SCNBillboardConstraint(freeAxes: SCNBillboardAxis.Y))
		textNodeContainer.addChildNode(self.textNode)
		textNodeContainer.addChildNode(self.pinBackgroundNode)
		textNodeContainer.addChildNode(self.pinArrowNode)
		self.pinAnchorNode.addChildNode(textNodeContainer)
		
		
		
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
		let cameraWorldPosition = camera.worldPosition
		let distance = SCNFloat(self.landmark.location.distance(from: location))
		let bearing = SCNFloat(location.coordinate.bearing(toCoordinate: self.landmark.location.coordinate))
		let altitudeDelta = SCNFloat(self.landmark.location.altitude - location.altitude)
		
//		self.isHidden = !(25.0...500.0).contains(distance)
		self.isHidden = false
		guard !self.isHidden else { return }
		
		
		
		let distanceVirtual: SCNFloat = {
			let tempWorldPosition = simd_float3(self.pinAnchorNode.simdWorldPosition.x,
												cameraWorldPosition.y,
												self.pinAnchorNode.simdWorldPosition.z)
			return tempWorldPosition.distance(to: cameraWorldPosition)
		}()
		let distanceError = abs(distanceVirtual - distance)
		let isOnScreen = sceneView.isNode(self.pinAnchorNode, insideFrustumOf: pointOfView)
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
			self.pinAnchorNode.simdWorldPosition = {
				let trueNorth = simd_float3(0.0, 0.0, -1.0)
				return trueNorth * distance
			}()
			//			landmarkNode.pinNode.simdWorldPosition = landmarkNode.pinNode.worldPositionFor(targetWorldPosition: trueNorth * distance,
			//																										   relativeTo: camera.transform,
			//																										   smoothMovement: true)
			self.rotationNode.simdPosition = simd_float3.zero
			self.rotationNode.eulerAngles.y = -bearing
			
			self.worldPosition.y = camera.worldPosition.y + altitudeDelta
		}
		
		
		
		if isOnScreen {
			self.text.string = StringBuilder()
				.append(string: self.landmark.name)
				.append(line: "distance:")
				.append(line: String(format: "\treal: %.2fm", distance))
				.append(line: String(format: "\tvirtual: %.2fm", distanceVirtual))
				.append(line: String(format: "\tΔ: %.2fm", distanceError))
				.append(line: String(format: "altitude: %.2fm (Δ: %.2fm)", self.landmark.location.altitude, altitudeDelta))
				.append(line: String(format: "bearing: %.3frad", bearing))
				.string
			
			
			
			// UPDATE SCALE
			// all values in metres
			// TODO: Sluthware
			//	percenteage in range
			//	value in range for percenage
			let minDistance: SCNFloat = 10.0
			let maxDistance: SCNFloat = 500.0
			let minFontSize: SCNFloat = 1.0
			let maxFontSize: SCNFloat = 10.0
			
			let percent = (distance - minDistance) / (maxDistance - minDistance)
			let scaledFontSize = (percent * (maxFontSize - minFontSize)) + minFontSize
			
			self.text.font = self.text.font.withSize(CGFloat(scaledFontSize))
			
			
			
			
			
			
			
			
			// https://signsontime.com.au/blog/90-sign-size.html
//			let mm = distance * 4.0
//			let m = mm / 1000.0
//			print(mm, m)
//			self.text.font = self.text.font.withSize(CGFloat(m))
			
			
			
			
			
			
			
			
			
			
			self.textNode.pivot = self.textNode.centrePivot(centreX: true, centreY: false, centreZ: false)
			
			
			
			let pinBackgroundPlane = self.pinBackgroundNode.geometry as! SCNPlane
			let pinArrowPlane = self.pinArrowNode.geometry as! SCNPlane
			let paddingPercentage: SCNFloat = 1.1
			
			
			
			pinBackgroundPlane.width = {
				return CGFloat(((self.textNode.boundingBox.max.x - self.textNode.boundingBox.min.x) * self.textNode.scale.x) * paddingPercentage)
			}()
			pinBackgroundPlane.height = {
				return CGFloat(((self.textNode.boundingBox.max.y - self.textNode.boundingBox.min.y) * self.textNode.scale.y) * paddingPercentage)
			}()
			pinBackgroundPlane.cornerRadius = 3.0
			
			
			
			pinArrowPlane.width = pinBackgroundPlane.width / 8.0
			pinArrowPlane.height = pinArrowPlane.width
			
			
			
			self.textNode.simdPosition.y = SCNFloat(pinArrowPlane.height / 2.0)
			
			
			
			// Adjust up half the height because the pivot is in the centre vs on the bottom for SCNText
			self.pinBackgroundNode.simdPosition.y = self.textNode.simdPosition.y + SCNFloat((pinBackgroundPlane.height / 2.0))
			self.pinBackgroundNode.simdPosition.z = self.textNode.simdPosition.z - 10.0
			
			
			
			self.pinArrowNode.simdEulerAngles = simd_float3.zero
			self.pinArrowNode.simdPosition.y = self.textNode.simdPosition.y
			self.pinArrowNode.simdPosition.z = self.pinBackgroundNode.simdPosition.z
			self.pinArrowNode.simdEulerAngles.z = SCNFloat.pi_4
		}
		
		
		
		// UPDATE SCALE
//		let minDistance: SCNFloat = 10.0
//		let maxDistance: SCNFloat = 500.0
//		let minRadius: SCNFloat = 0.10
//		let maxRadius: SCNFloat = 10.0
//
//		let percent = (distance - minDistance) / (maxDistance - minDistance)
//		let radius = (percent * (maxRadius - minRadius)) + minRadius
//		if let geometry = self.pinAnchorNode.geometry as? SCNSphere {
//			//			geometry.radius = CGFloat(radius)
//		}
	}
}




