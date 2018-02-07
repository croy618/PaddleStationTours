//
//  LandmarkNode.swift
//  Paddle Station
//
//  Created by Pat Sluth on 2018-01-31.
//  Copyright © 2018 Pat Sluth. All rights reserved.
//

import Foundation
import SceneKit





// TODO: MOVE ContantLitMaterial
class LandmarkNode: SCNNode
{
	let landmark: Landmark
	let cameraWorldPosition: simd_float3
	var lockPosition: Bool = false
	
	fileprivate(set) lazy var text: SCNText = {
		let geometry = SCNText(string: nil, extrusionDepth: 0.0)
		geometry.alignmentMode = kCAAlignmentCenter
		geometry.flatness = 0.75   // 0.0 is very slow
		let material = SCNMaterial.constantLitWith(color: UIColor.white)
		geometry.materials = [material]
		
		return geometry
	}()
	
	lazy var rootNode: SCNNode = {
		let node = SCNNode()
		self.addChildNode(node)
		return node
	}()
	
	lazy var destinationNode: SCNNode = {
		let node = SCNNode()
		node.geometry = {
			let geometry = SCNSphere(radius: 1.0)
			let material = SCNMaterial.constantLitWith(color: UIColor.random)
			geometry.materials = [material]
			return geometry
		}()
		self.rootNode.addChildNode(node)
		return node
	}()
	
	
	
	
	
	required init(landmark: Landmark, cameraWorldPosition: simd_float3)
	{
		self.landmark = landmark
		self.cameraWorldPosition = cameraWorldPosition
		
		
		
		super.init()
		
		
		
		let textNode = SCNNode(geometry: self.text)
		textNode.castsShadow = false
		textNode.scale = SCNVector3Make(0.3, 0.3, 0.3)
		let textNodeContainer = SCNNode()
		textNodeContainer.addConstraint(SCNBillboardConstraint())
		textNodeContainer.addChildNode(textNode)
		self.destinationNode.addChildNode(textNodeContainer)
		
		
		
		self.isHidden = true
	}
	
	required init?(coder aDecoder: NSCoder)
	{
		fatalError(#function + " has not been implemented")
	}
}




