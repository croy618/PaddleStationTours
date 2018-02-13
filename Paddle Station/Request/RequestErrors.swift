//
//  QSTRequestErrors.swift
//  Paddle Station
//
//  Created by Pat Sluth on 2017-11-25.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





enum RequestErrors
{
    case DuplicateRequest
    case InvalidResponseObject
    case InvalidURL
    case FailedToCreateDataTask
    case Cancelled
	case API(apiError: RequestAPIError)
    case Custom(code: Int, message: String)
    
    var code: Int {
        switch self {
        case .DuplicateRequest:                         return 0
        case .InvalidResponseObject:                    return 1
        case .InvalidURL:                               return 2
        case .FailedToCreateDataTask:                   return 3
        case .Cancelled:                                return 4
		case .API(let apiError):                        return apiError.code.rawValue
        case .Custom(let code, _):                      return code
        }
    }
    
    var message: String {
        switch self {
        case .DuplicateRequest:                         return "Duplicate Request"
        case .InvalidResponseObject:                    return "Invalid ResponseObject"
        case .InvalidURL:                               return "Invalid URL"
        case .FailedToCreateDataTask:                   return "Failed to cCreate URLSessionDataTask"
        case .Cancelled:                                return "Cancelled"
		case .API(let apiError):                        return apiError.message
        case .Custom(_, let message):                   return message
        }
    }
}




