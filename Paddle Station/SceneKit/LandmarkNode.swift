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
	
	fileprivate(set) lazy var text: SCNText = {
		let geometry = SCNText(string: nil, extrusionDepth: 0.0)
		geometry.alignmentMode = kCAAlignmentCenter
		geometry.flatness = 0.75   // 0.0 is very slow
		let material: SCNMaterial = {
			let material = SCNMaterial()
			
			material.diffuse.contents = UIColor.white
			material.isDoubleSided = true
			material.ambient.contents = UIColor.black
			material.lightingModel = SCNMaterial.LightingModel.constant
			material.emission.contents = material.diffuse.contents
			
			return material
		}()
		geometry.materials = [material]
		
		return geometry
	}()
	
	
	
	
	
	required init(landmark: Landmark)
	{
		self.landmark = landmark
		
		
		
		super.init()
		
		
		
		self.geometry = {
			let geometry = SCNSphere(radius: 1.0)
			
			let material: SCNMaterial = {
				let material = SCNMaterial()
				
				material.diffuse.contents = UIColor.random
				material.isDoubleSided = true
				material.ambient.contents = UIColor.black
				material.lightingModel = SCNMaterial.LightingModel.constant
				material.emission.contents = material.diffuse.contents
				
				return material
			}()
			geometry.materials = [material]
			
			return geometry
		}()
		
		
		
		let textNode = SCNNode(geometry: self.text)
		textNode.castsShadow = false
		textNode.scale = SCNVector3Make(0.3, 0.3, 0.3)
		let textNodeContainer = SCNNode()
		textNodeContainer.addConstraint(SCNBillboardConstraint())
		textNodeContainer.addChildNode(textNode)
		self.addChildNode(textNodeContainer)
	}
	
	required init?(coder aDecoder: NSCoder)
	{
		fatalError(#function + " has not been implemented")
	}
}




