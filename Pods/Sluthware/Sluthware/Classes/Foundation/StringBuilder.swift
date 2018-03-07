//
//  StringBuilder.swift
//  Sluthware
//
//  Created by Pat Sluth on 2018-02-13.
//  Copyright © 2018 Pat Sluth. All rights reserved.
//

import Foundation





public class StringBuilder
{
	fileprivate var lines = [[(String, [NSAttributedStringKey: Any]?)]]()
	public var string: String {
		var string = ""
		for (index, line) in self.lines.enumerated() {
			for component in line {
				string += component.0
			}
			if index < self.lines.endIndex - 1 {
				string += "\n"
			}
		}
		return string
	}
	public var attributedString: NSAttributedString {
		var attributedString = NSMutableAttributedString()
		for (index, line) in self.lines.enumerated() {
			for component in line {
				attributedString.append(NSAttributedString(string: component.0, attributes: component.1))
			}
			if index < self.lines.endIndex - 1 {
				attributedString.append(NSAttributedString(string: "\n", attributes: nil))
			}
		}
		return attributedString.copy() as! NSAttributedString
	}
	
	
	
	
	
	public init()
	{
	}
	
	public init(string: String, _ rawAttributes: (NSAttributedStringKey, Any)...)
	{
		let attributes = self.attributesDictionaryFrom(rawAttributes: rawAttributes)
		self.lines.append([(string, attributes)])
	}
	
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
		var lastLine = self.lines.popLast() ?? []
		lastLine.append(string)
		self.lines.append(lastLine)
		
		return self
	}
	
	fileprivate func internalAppend(line: (String, [NSAttributedStringKey: Any]?)) -> Self
	{
		self.lines.append([line])
		
		return self
	}
	
	public func clear() -> Self
	{
		self.lines.removeAll()
		
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





