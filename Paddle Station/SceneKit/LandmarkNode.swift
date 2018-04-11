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
	var backgroundTintColor = UIColor(hex: "ab1d3a") {
		didSet
		{
			self.backgroundNode.geometry?.firstMaterial?.reflective.contents = self.backgroundTintColor
		}
	}
	
	fileprivate let stringBuilder = StringBuilder()
	
	
	
	fileprivate lazy var rotationNode: SCNNode = {
		let node = SCNNode()
		self.addChildNode(node)
		return node
	}()
	
	// The node reepresenting the real location of the landmark
	fileprivate lazy var anchorNode: SCNNode = {
		let node = SCNNode()
//		node.geometry = {
//			let geometry = SCNSphere(radius: 0.25)
//			let material = SCNMaterial.constantLitWith(color: UIColor.yellow)
//			geometry.materials = [material]
//			return geometry
//		}()
		self.rotationNode.addChildNode(node)
		return node
	}()
	
	fileprivate lazy var textNode: SCNNode = {
		let node = SCNNode()
		node.castsShadow = false
		node.geometry = {
			let geometry = SCNText(string: nil, extrusionDepth: 0.0)
			geometry.isWrapped = true
			geometry.alignmentMode = kCAAlignmentCenter
			geometry.flatness = 1.0		// 0.0 is very slow
			let material = SCNMaterial.constantLitWith(color: UIColor.white)
			material.readsFromDepthBuffer = false
			geometry.materials = [material]
			return geometry
		}()
		return node
	}()
	
	fileprivate lazy var backgroundNode: SCNNode = {
		let node = SCNNode()
		node.geometry = {
			let geometry = SCNPlane(width: 0.0, height: 0.0)
			let material = SCNMaterial.constantLitWith(color: UIColor.clear)
			material.diffuse.contents = R.image.pinBackground()
			material.reflective.contents = self.backgroundTintColor
			geometry.materials = [material]
			return geometry
		}()
		node.addChildNode(self.textNode)
		return node
	}()
	
	
	
	
	
	required init(landmark: Landmark)
	{
		self.landmark = landmark
		
		super.init()
		
		let textNodeContainer = SCNNode()
//		textNodeContainer.addConstraint(SCNBillboardConstraint(freeAxes: SCNBillboardAxis.Y))
		textNodeContainer.addChildNode(self.backgroundNode)
		self.anchorNode.addChildNode(textNodeContainer)
		self.textNode.addConstraint(SCNBillboardConstraint(freeAxes: SCNBillboardAxis.Y))
		
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
		
		self.isHidden = !(25.0...750.0).contains(distance)
		guard !self.isHidden else { return }
		
		
		
		let distanceVirtual: SCNFloat = {
			let tempWorldPosition = simd_float3(self.anchorNode.simdWorldPosition.x,
												cameraWorldPosition.y,
												self.anchorNode.simdWorldPosition.z)
			return tempWorldPosition.distance(to: cameraWorldPosition)
		}()
		let distanceError = abs(distanceVirtual - distance)
		let isOnScreen = sceneView.isNode(self.anchorNode, insideFrustumOf: pointOfView)
		let updatePosition = !isOnScreen || (distanceError > 10.0) // force update if offscreen
		
		
		
		// Update render order, so text doesnt clip into pin background
		// Use distance so that if there is a LandmarkNode behind this one
		// the text will not render in front of this backgroundNode
		self.backgroundNode.renderingOrder = -Int(distance) - 1
		self.textNode.renderingOrder = -Int(distance)
		
		
		
		if updatePosition {
			self.simdWorldPosition = camera.worldPosition
			self.rotationNode.simdWorldPosition = simd_float3.zero
			self.rotationNode.simdWorldOrientation = simd_quatf.zero
			self.anchorNode.simdWorldPosition = {
				let trueNorth = simd_float3(0.0, 0.0, -1.0)
				return trueNorth * distance
			}()
			self.rotationNode.simdPosition = simd_float3.zero
			self.rotationNode.eulerAngles.y = -bearing
			
			self.worldPosition.y = camera.worldPosition.y + altitudeDelta
		}
		
		
		
		if isOnScreen {
			
			guard let text = self.textNode.geometry as? SCNText else { return }
			guard let backgroundPlane = self.backgroundNode.geometry as? SCNPlane else { return }
			// TODO: better way of scaling??
			let titleFont = text.font.withSize(CGFloat(distance / 30.0))
			let detailFont = text.font.withSize(titleFont.pointSize * 0.65)
			
			self.stringBuilder.clear()
				.append(string: self.landmark.name, (NSAttributedStringKey.font, titleFont))
				.append(string: String(format: " (%.2fm)", distance), (NSAttributedStringKey.font, detailFont))
				.append(line: self.landmark.description, (NSAttributedStringKey.font, detailFont))
//							.append(line: "distance:")
//							.append(line: String(format: "\treal: %.2fm", distance))
//							.append(line: String(format: "\tvirtual: %.2fm", distanceVirtual))
//							.append(line: String(format: "\tΔ: %.2fm", distanceError))
//							.append(line: String(format: "altitude: %.2fm (Δ: %.2fm)", self.landmark.location.altitude, altitudeDelta))
//							.append(line: String(format: "bearing: %.3frad", bearing))
			
			text.string = self.stringBuilder.attributed
			text.containerFrame = CGRect(x: 0.0,
										 y: 0.0,
										 width: CGFloat(distance * 0.5),
										 height: 100000.0)
			
			
			
			// Based on where text should be in pinBackground.png
			self.textNode.pivot = self.textNode.pivotFor(anchorPoint: SCNVector3(0.5, 0.44, 0.0))
			
			
			
			backgroundPlane.width = {
				let width = (self.textNode.boundingBox.max.x - self.textNode.boundingBox.min.x) * self.textNode.scale.x
				let widthMultiplier: SCNFloat = 1.08	// Based on where text should be in pinBackground.png
				return CGFloat(width * widthMultiplier)
			}()
			backgroundPlane.height = {
				let height = (self.textNode.boundingBox.max.y - self.textNode.boundingBox.min.y) * self.textNode.scale.y
				let heightMultiplier: SCNFloat = 1.26	// Based on where text should be in pinBackground.png
				return CGFloat(height * heightMultiplier)
			}()
			
			
			
			// Adjust up half the height because the pivot is in the centre vs on the bottom for SCNText
			self.backgroundNode.simdPosition.y = SCNFloat(backgroundPlane.height / 2.0)
//			self.textNode.simdPosition.z = self.backgroundNode.simdPosition.z + (distance / 50.0)
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




