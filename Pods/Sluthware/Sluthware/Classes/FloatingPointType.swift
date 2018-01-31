//
//  FloatingPointType.swift
//  Sluthware
//
//  Created by Pat Sluth on 2017-08-08.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation
import CoreGraphics





public protocol FloatingPointType: BinaryFloatingPoint
{
	init(_ value: Float)
	init(_ value: Double)
	init(_ value: CGFloat)
	
	func to<T: FloatingPointType>() -> T
}

extension Float:	FloatingPointType { public func to<T: FloatingPointType>() -> T { return T(self) } }
extension Double:	FloatingPointType { public func to<T: FloatingPointType>() -> T { return T(self) } }
extension CGFloat:	FloatingPointType { public func to<T: FloatingPointType>() -> T { return T(self) } }




