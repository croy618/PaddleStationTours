//
//  Codable.swift
//  Sluthware
//
//  Created by Pat Sluth on 2017-10-08.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





enum EncodableErrors: Error
{
	case failedEncodeToType(type: String)
	case failedEncodeToString
}





public extension Encodable
{
	func encode() throws -> Data
	{
		let encoder = JSONEncoder()
		encoder.outputFormatting = JSONEncoder.OutputFormatting.prettyPrinted
		return try encoder.encode(self)
	}
	
	func encodeDictionary<T>(_ type: T.Type) throws -> T
	{
		let encoder = JSONEncoder()
		encoder.outputFormatting = JSONEncoder.OutputFormatting.prettyPrinted
		let data = try encoder.encode(self)
		if let dictionary = try JSONSerialization.jsonObject(with: data) as? T {
			return dictionary
		}
		
		throw EncodableErrors.failedEncodeToType(type: String(describing: type))
	}
	
	func encodeString() throws -> String
	{
		let data = try self.encode()
		if let string = String(data: data, encoding: String.Encoding.utf8) {
			return string
		}
		
		throw EncodableErrors.failedEncodeToString
	}
}




