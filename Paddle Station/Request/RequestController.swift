//
//  RequestController.swift
//  Paddle Station
//
//  Created by Pat Sluth on 2017-11-25.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation

import AFNetworking





typealias RequestIdentifier = String





protocol RequestControllerNotificationProtocol: class
{
	func onRequestCompleted(forRequestIdentifier requestIdentifier: RequestIdentifier, responseJsonDictionary: [AnyHashable: Any])
	func onRecieved(requestError: RequestErrors)
}





final class RequestController: NSObject
{
	struct RequestHandlers
	{
		typealias Success = (_ responseJsonDictionary: [AnyHashable: Any]) -> Bool
		typealias Error = (_ requestError: RequestErrors) -> Void
		typealias DataTask = (_ dataTask: URLSessionDataTask) -> Void
	}
	
	
	
	
	
    enum RequestType
    {
        case Get
        case Post
        case Delete
    }
    
    
    
    
    
    fileprivate static var activeDataTasksByRequestIdentifier = [RequestIdentifier: [URLSessionTask]]()
    
    
    
    
    
    
    fileprivate override init()
    {
        super.init()
    }
    
    fileprivate class func add(dataTask: URLSessionTask, forRequestIdentifier requestIdentifier: RequestIdentifier)
    {
        if var dataTasks = self.activeDataTasksByRequestIdentifier[requestIdentifier] {
            dataTasks.append(dataTask)
            self.activeDataTasksByRequestIdentifier.updateValue(dataTasks, forKey: requestIdentifier)
        } else {
            self.activeDataTasksByRequestIdentifier.updateValue([dataTask], forKey: requestIdentifier)
        }
    }
    
    fileprivate class func remove(dataTask: URLSessionTask?, forRequestIdentifier requestIdentifier: RequestIdentifier) -> Bool
    {
        guard let dataTask = dataTask else { return false }
        
        if var dataTasks = self.activeDataTasksByRequestIdentifier[requestIdentifier] {
            
            guard let index = dataTasks.index(of: dataTask) else { return false }
            
            dataTasks.remove(at: index)
            
            if dataTasks.isEmpty {
                self.activeDataTasksByRequestIdentifier.removeValue(forKey: requestIdentifier)
            } else {
                self.activeDataTasksByRequestIdentifier.updateValue(dataTasks, forKey: requestIdentifier)
            }
            
            return true
        }
        
        return false
    }
    
    class func hasActiveDataTasksFor(requestIdentifier: RequestIdentifier) -> Bool
    {
        if let dataTasks = self.activeDataTasksByRequestIdentifier[requestIdentifier] {
            for dataTask in dataTasks {
                if dataTask.state == URLSessionTask.State.running {
                    return true
                }
            }
        }
        return false
    }
    
    class func cancelDataTasksFor(requestIdentifier: RequestIdentifier)
    {
        if let dataTasks = self.activeDataTasksByRequestIdentifier[requestIdentifier] {
            for dataTask in dataTasks {
                dataTask.cancel()
            }
        }
        
        self.activeDataTasksByRequestIdentifier.removeValue(forKey: requestIdentifier)
    }
    
    class func cancelDataTasks()
    {
        for (requestIdentifier, _) in self.activeDataTasksByRequestIdentifier {
            RequestController.cancelDataTasksFor(requestIdentifier: requestIdentifier)
        }
    }
	
	class func performRequestFor(requestIdentifier: RequestIdentifier,
								 requestType: RequestController.RequestType,
								 urlString: String?,
								 parameters: Any?,
								 allowDuplicateRequests: Bool,
								 cancelPreviousRequests: Bool,
								 successHandler: @escaping RequestController.RequestHandlers.Success,
								 errorHandler: RequestController.RequestHandlers.Error?,
								 dataTaskHandler: RequestController.RequestHandlers.DataTask?)
	{
		let internalErrorHandler = { (requestError: RequestErrors) in
			Broadcaster.notify(RequestControllerNotificationProtocol.self) {
				$0.onRecieved(requestError: requestError)
			}
			errorHandler?(requestError)
		}
		
		guard let urlString = urlString else { return }
		guard !String.isEmpty(urlString) else {
			internalErrorHandler(RequestErrors.InvalidURL)
			return
		}
		
		print(urlString)
		
		
		
		if cancelPreviousRequests {
			self.cancelDataTasksFor(requestIdentifier: requestIdentifier)
		}
		
		
		
		if !allowDuplicateRequests {
			guard !self.hasActiveDataTasksFor(requestIdentifier: requestIdentifier) else {
				internalErrorHandler(RequestErrors.DuplicateRequest)
				return
			}
		}
		
		
		
		let manager: AFHTTPSessionManager = {
			let manager = AFHTTPSessionManager()
			
			manager.requestSerializer = AFJSONRequestSerializer()
			manager.requestSerializer.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
			
			return manager
		}()
		
		let success = { (dataTask: URLSessionDataTask, responseObject: Any?) in
			
			guard self.remove(dataTask: dataTask, forRequestIdentifier: requestIdentifier) else { return }
			
			guard let responseJsonDictionary = responseObject as? [AnyHashable: Any] else {
				internalErrorHandler(RequestErrors.InvalidResponseObject)
				return
			}
			
			if !successHandler(responseJsonDictionary) {
				if let apiError = try? RequestAPIError.decode(jsonDictionary: responseJsonDictionary) {
					internalErrorHandler(RequestErrors.API(apiError: apiError))
				} else {
					internalErrorHandler(RequestErrors.InvalidResponseObject)
				}
			} else {
				Broadcaster.notify(RequestControllerNotificationProtocol.self) {
					$0.onRequestCompleted(forRequestIdentifier: requestIdentifier, responseJsonDictionary: responseJsonDictionary)
				}
			}
		}
		
		let failure = { (dataTask: URLSessionDataTask?, error: Error) -> Void in
			let _ = self.remove(dataTask: dataTask, forRequestIdentifier: requestIdentifier)
			let error = error as NSError
			internalErrorHandler(RequestErrors.Custom(code: error.code, message: error.localizedDescription))
		}
		
		
		
		var dataTask: URLSessionDataTask?
		
		switch requestType {
		case RequestController.RequestType.Get:
			dataTask = manager.get(urlString, parameters: parameters, progress: nil, success: success, failure: failure)
			break
		case RequestController.RequestType.Post:
			dataTask = manager.post(urlString, parameters: parameters, progress: nil, success: success, failure: failure)
			break
		case RequestController.RequestType.Delete:
			dataTask = manager.delete(urlString, parameters: parameters, success: success, failure: failure)
			break
		}
		
		if let dataTask = dataTask {
			self.add(dataTask: dataTask, forRequestIdentifier: requestIdentifier)
			dataTaskHandler?(dataTask)
		} else {
			internalErrorHandler(RequestErrors.FailedToCreateDataTask)
		}
    }
}




