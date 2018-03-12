//
//  StringBuilder.swift
//  Sluthware
//
//  Created by Pat Sluth on 2018-02-13.
//  Copyright © 2018 Pat Sluth. All rights reserved.
//

import Foundation





// TODO: Update sluthware
public class StringBuilder
{
//	static let shared = StringBuilder()
	
	
	
//	fileprivate var lines = [[(String, [NSAttributedStringKey: Any]?)]]()
//	public var string: String {
//		var string = ""
//		for (index, line) in self.lines.enumerated() {
//			for component in line {
//				string += component.0
//			}
//			if index < self.lines.endIndex - 1 {
//				string += "\n"
//			}
//		}
//		return string
//	}
//	public var attributedString: NSAttributedString {
//		var attributedString = NSMutableAttributedString()
//		for (index, line) in self.lines.enumerated() {
//			for component in line {
//				attributedString.append(NSAttributedString(string: component.0, attributes: component.1))
//			}
//			if index < self.lines.endIndex - 1 {
//				attributedString.append(NSAttributedString(string: "\n", attributes: nil))
//			}
//		}
//		return attributedString.copy() as! NSAttributedString
//	}
	fileprivate(set) public var attributed = NSMutableAttributedString()
	
	public var string: String {
		return self.attributed.string
	}
//	public var attributed: NSAttributedString {
//		return self.attributedString.copy() as! NSAttributedString
//	}
	
	
	
	
	
	public init()
	{
	}
	
//	public init(string: String, _ rawAttributes: (NSAttributedStringKey, Any)...)
//	{
//		self.append(string: string, rawAttributes)
//	}
	
	public func append(string: String?, _ rawAttributes: (NSAttributedStringKey, Any)...) -> Self
	{
		let attributes = self.attributesDictionaryFrom(rawAttributes: rawAttributes)
		return self.internalAppend(string: (string ?? "", attributes))
	}
	
	public func append(line: String?, _ rawAttributes: (NSAttributedStringKey, Any)...) -> Self
	{
		let attributes = self.attributesDictionaryFrom(rawAttributes: rawAttributes)
		return self.internalAppend(line: (line ?? "", attributes))
	}
	
	fileprivate func internalAppend(string: (String, [NSAttributedStringKey: Any]?)) -> Self
	{
		self.attributed.append(NSAttributedString(string: string.0, attributes: string.1))
		
		return self
	}
	
	fileprivate func internalAppend(line: (String, [NSAttributedStringKey: Any]?)) -> Self
	{
		var line = line
//		if String.isEmpty(self.string) {
			line.0 = "\n" + line.0
//		s}
		self.attributed.append(NSAttributedString(string: line.0, attributes: line.1))
		
		return self
	}
	
	public func clear() -> Self
	{
		self.attributed = NSMutableAttributedString()
		
		return self
	}
	
	fileprivate func attributesDictionaryFrom(rawAttributes: [(NSAttributedStringKey, Any)]) -> [NSAttributedStringKey: Any]?
	{
		guard !rawAttributes.isEmpty else { return nil }
		
		var attributes = [NSAttributedStringKey: Any]()
		for rawAttribute in rawAttributes {
			attributes.updateValue(rawAttribute.1, forKey: rawAttribute.0)
		}
		return attributes
	}
}





