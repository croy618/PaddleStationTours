//
//  LandmarkNode.swift
//  Paddle Station
//
//  Created by Pat Sluth on 2018-01-31.
//  Copyright © 2018 Pat Sluth. All rights reserved.
//

import Foundation
import SpriteKit
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
	var pinBackgroundColor = UIColor.clear {
		didSet
		{
			// TODO: update
		}
	}
	
	fileprivate let stringBuilder = StringBuilder()
	
	
	
	fileprivate lazy var rotationNode: SCNNode = {
		let node = SCNNode()
		self.addChildNode(node)
		return node
	}()
	
	fileprivate lazy var pinAnchorNode: SCNNode = {
		let node = SCNNode()
//		node.geometry = {
//			let geometry = SCNSphere(radius: 1.0)
//			let material = SCNMaterial.constantLitWith(color: UIColor.green)
//			geometry.materials = [material]
//			return geometry
//		}()
		self.rotationNode.addChildNode(node)
		return node
	}()
	
	fileprivate lazy var pinScene: LandmarkNodePinScene = {
		let pinScene = LandmarkNodePinScene(fileNamed: R.file.landmarkNodePinSceneSks.name)!
		return pinScene
	}()
	
	fileprivate lazy var pinNode: SCNNode = {
		let node = SCNNode()
		node.geometry = {
			let geometry = SCNPlane(width: 0.0, height: 0.0)
			let material = SCNMaterial.constantLitWith(color: UIColor.clear)
			
//			materrial.isDoubleSided = true
			material.diffuse.contents = self.pinScene
			material.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(1.0, -1.0, 1.0), 0.0, 1.0, 0.0)
			
			geometry.materials = [material]
			return geometry
		}()
		return node
	}()
	
	
	
	
	
	required init(landmark: Landmark, cameraWorldPosition: simd_float3)
	{
		self.landmark = landmark
		self.lockedWorldPosition = cameraWorldPosition
		
		
		
		super.init()
		
		
		
		self.pinNode.addConstraint(SCNBillboardConstraint(freeAxes: SCNBillboardAxis.Y))
		self.pinAnchorNode.addChildNode(self.pinNode)
		
		
		
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
			
			// https://signsontime.com.au/blog/90-sign-size.html
			let m = distance / 4.0
			//let m = mm / 1000.0
//			print(distance, m)
			//			self.pinScene.label?.fontSize = m
			
			let pinBackgroundPlane = self.pinNode.geometry as! SCNPlane
			pinBackgroundPlane.height = CGFloat(m)
			pinBackgroundPlane.width = pinBackgroundPlane.height * (1000.0 / 600.0)
//			let aspectRatio = pinBackgroundPlane.width / pinBackgroundPlane.height
			// TODO: SCALE BASED ON ASPECT RATIO?
//			self.pinScene.size = CGSize(width: pinBackgroundPlane.width * 25.0, height: pinBackgroundPlane.height * 25.0)
			self.pinNode.pivot = self.pinNode.centrePivot(centreX: true, centreY: false, centreZ: false)
			self.pinNode.simdPosition.y = SCNFloat(pinBackgroundPlane.height / 2.0)
			
			
			
			let attributedString = self.stringBuilder.clear()
				.append(string: self.landmark.name)
				.append(line: "distance:")
				.append(line: String(format: "\treal: %.2fm", distance))
				.append(line: String(format: "\tvirtual: %.2fm", distanceVirtual))
				.append(line: String(format: "\tΔ: %.2fm", distanceError))
				.append(line: String(format: "altitude: %.2fm (Δ: %.2fm)", self.landmark.location.altitude, altitudeDelta))
				.append(line: String(format: "bearing: %.3frad", bearing))
				.attributed
			
			let lines = attributedString.string.components(separatedBy: CharacterSet.newlines).count
			let fontSize = (self.pinScene.size.height * 0.5) / CGFloat(lines)
			
			attributedString.addAttribute(NSAttributedStringKey.font,
										  	value: UIFont.systemFont(ofSize: fontSize),
										  range: NSRange(location: 0, length: attributedString.length))
			
//			let paragraphStyle = NSMutableParagraphStyle()
//			paragraphStyle.lineSpacing = 0.0
//
//			attributedString.addAttribute(NSAttributedStringKey.paragraphStyle,
//										  value: paragraphStyle,
//										  range: NSRange(location: 0, length: attributedString.length))
			
			
			
//			self.pinScene.attributedText = attributedString
			self.pinScene.text = attributedString.string

//			self.pinScene.background?.size = self.pinScene.label!.sizee
//			self.pinScene.position = self.pinScene.label!.position
			
			
//			self.pinScene.label?.fontColor = UIColor.black
//			self.pinScene.label?.fontSize = (self.pinScene.size.height * 0.75) / CGFloat(lines)
//			self.pinScene.label.fitToHeight(maxHeight: pinBackgroundPlane.height)
			
			
			
//			// UPDATE SCALE
//			// all values in metres
//			// TODO: Sluthware
//			//	percenteage in range
//			//	value in range for percenage
//			let minDistance: SCNFloat = 10.0
//			let maxDistance: SCNFloat = 500.0
//			let minFontSize: SCNFloat = 1.0
//			let maxFontSize: SCNFloat = 200.0
//
//			let percent = (distance - minDistance) / (maxDistance - minDistance)
//			let scaledFontSize = (percent * (maxFontSize - minFontSize)) + minFontSize
//			self.pinScene.label?.fontSize = CGFloat(scaledFontSize)
//			self.text.font = self.text.font.withSize(CGFloat(scaledFontSize))
			
			
			
			
			
			
			
			
			
			
			
			
			
			
//			let pinArrowPlane = self.pinArrowNode.geometry as! SCNPlane
//			let paddingPercentage: SCNFloat = 1.1
			
			
			
			
			
//			pinBackgroundPlane.width = {
//				return CGFloat(((self.textNode.boundingBox.max.x - self.textNode.boundingBox.min.x) * self.textNode.scale.x) * paddingPercentage)
//			}()
//			pinBackgroundPlane.height = {
//				return CGFloat(((self.textNode.boundingBox.max.y - self.textNode.boundingBox.min.y) * self.textNode.scale.y) * paddingPercentage)
//			}()
//			pinBackgroundPlane.cornerRadius = 3.0
			
			
			
//			pinArrowPlane.width = pinBackgroundPlane.width / 8.0
//			pinArrowPlane.height = pinArrowPlane.width
			
			
			
//			self.textNode.simdPosition.y = SCNFloat(pinArrowPlane.height / 2.0)
			
			
			
			// Adjust up half the height because the pivot is in the centre vs on the bottom for SCNText
//			self.pinNode.simdPosition.y = self.textNode.simdPosition.y + SCNFloat((pinBackgroundPlane.height / 2.0))
//			self.pinNode.simdPosition.z = self.textNode.simdPosition.z - 10.0
			
			
			
//			self.pinArrowNode.simdEulerAngles = simd_float3.zero
			
//			self.pinArrowNode.simdPosition.z = self.pinNode.simdPosition.z
//			self.pinArrowNode.simdEulerAngles.z = SCNFloat.pi_4
//
//
//
//
//
//
//			self.textNode.opacity = 0.0
//			self.pinArrowNode.opacity = 0.0
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




