//
//  RequestAPIError.swift
//  Paddle Station
//
//  Created by Pat Sluth on 2017-09-15.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





class RequestAPIError: NSObject, Decodable
{
    fileprivate enum CodingKeys: String, CodingKey
    {
        case code
        case message
    }
    
    enum Code: Int, Decodable
    {
        case InvalidEndpoint =                      1001
        case InvalidOrMalformedArgument =           1002
        case ArgumentLengthExceedsLimit =           1003
        case MissingRequiredArgument =              1004
        case RequestLengthExceedsLimit =            1005
        case RateLimitExceeded  =                   1006
        case IQServerBusinessError =                1007
        case IQServerTechnicalError =               1008
        case IQServerUnexpectedError  =             1009
        case IQServerInvalidResponse =              1010
        case IQServerResponseTimeout =              1011
        case MethodUnsupported =                    1012
        case RequestNotJSON =                       1013
        case MissingAuthorizationHeader =           1014
        case MalformedAuthorizationHeader =         1015
        case RequestOutOfAllowedOAuthScopes =       1016
        case InvalidAccessToken =                   1017
        case AccountNumberNotFound =                1018
        case SymbolNotFound =                       1019
        case OrderNotFound =                        1020
        case UnexpectedUnHandledError =             1021
    }
    
    
    
    
    
    static let httpStatusCodes: [Int] = [400, 401, 403, 404, 405, 413, 429, 500, 502, 503]
    
    
    
    let code: RequestAPIError.Code
    let message: String
    
    
    
    
    
    fileprivate override init()
    {
        fatalError(#function + " has not been implemented")
    }
    
    required init(from decoder: Decoder) throws
    {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        
        
        self.code = try values.decode(RequestAPIError.Code.self, forKey: CodingKeys.code)
        self.message = try values.decode(String.self, forKey: CodingKeys.message)
        
        
        
        super.init()
    }
}




