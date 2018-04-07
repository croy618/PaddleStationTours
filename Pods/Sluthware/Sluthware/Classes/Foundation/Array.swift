//
//  Array.swift
//  Sluthware
//
//  Created by Pat Sluth on 2017-09-30.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





public extension Array
{
//	public var unique: Array
//	{
//		return Array(Set(self))
//	}
	
	public subscript(safe index: Index) -> Element?
	{
		guard (0..<self.count).contains(index) else { return nil }
		return self[index]
	}
	
	
	
	
	
	
	
//	public mutating func removingDuplicates()
//	{
//		self = self.unique
//	}
//
	public mutating func popFirst() -> Element?
	{
		if let first = self.first {
			self.removeFirst()
			return first
		}
		
		return nil
	}
	
//	public func removingDuplicates() -> [Element.Type]
//	{
//		return [Element.Type]
//	}
}




