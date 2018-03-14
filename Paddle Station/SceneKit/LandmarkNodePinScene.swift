//
//  GameScene.swift
//  test
//
//  Created by Pat Sluth on 2018-03-08.
//  Copyright © 2018 Pat Sluth. All rights reserved.
//

import SpriteKit
import GameplayKit





extension SKLabelNode
{
	func sizeToFit()
	{
		guard let scene = self.scene else { return }
		
//		while self.frame.size.width > scene.size.width {
//			self.fontSize -= 1.0
//		}
		
		while self.frame.size.height > scene.size.height {
			self.fontSize -= 1.0
		}
	}
	
	func fitToWidth(maxWidth: CGFloat)
	{
//		while frame.size.width >= maxWidth {
//			fontSize-=1.0
//		}
	}
	
	func fitToHeight(maxHeight: CGFloat)
	{
//		while frame.size.height >= maxHeight {
//			fontSize-=1.0
//		}
	}
}





class LandmarkNodePinScene: SKScene
{
	lazy var background: SKSpriteNode? = {
		return self.childNode(withName: "//background") as? SKSpriteNode
	}()
	
	lazy var label: SKLabelNode? = {
		return self.childNode(withName: "//label") as? SKLabelNode
	}()
	
//	override var size: CGSize {
//		didSet
//		{
//			self.background?.size = self.size
//			self.background?.position = CGPoint.zero
//			
//			self.label?.fontColor = UIColor.black
//			self.label?.fontSize = self.size.height / 7.0
//		}
//	}
}




