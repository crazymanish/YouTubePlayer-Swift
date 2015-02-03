//
//  HttpServiceDataTask.swift
//  MR_YouTubePlayer
//
//  Created by Manish Rathi on 25/09/14.
//  Copyright (c) 2014 Rathi Inc. All rights reserved.
//
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//
//

import UIKit

extension String {
    func escapeString() -> String {
        var raw: NSString = self
        var str = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,raw,"[].",":/?&=;+!@#$()',*",CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding))
        return str as NSString
    }
}

class HttpServiceDataTask: NSObject,NSURLSessionDataDelegate {
    
    //Blocks
    private var completionBlock:JsonResponseCompletionBlock?
    
    /**
    * will hold the Url-session
    */
    private var session:NSURLSession!
    
    /**
    * will hold the NSURLSessionDataTask Object
    */
    var dataTask:NSURLSessionDataTask?
    
    
    //***********************************************************************
    // MARK: - Init & Prepare HTTP -GET Request Here
    //***********************************************************************
    func initHTTPGetServiceWithUrl(url: NSURL,  ServiceParameters parameters: Dictionary<String,AnyObject>?, withOperationQueue queue:NSOperationQueue, withCompletionHandler completionHandler:JsonResponseCompletionBlock) -> HttpServiceDataTask
    {
        var downloadingTask:HttpServiceDataTask = HttpServiceDataTask()
        var completeUrl = url
        
        //Callback
        downloadingTask.completionBlock=completionHandler
        
        //Session configuration
        var configuration:NSURLSessionConfiguration=NSURLSessionConfiguration.defaultSessionConfiguration()
        downloadingTask.session=NSURLSession(configuration: configuration, delegate: downloadingTask, delegateQueue: queue)
        
        var queryString:String = ""
        if parameters != nil {
            queryString = NSString(format:"%@?",url.absoluteString!) as String
            queryString = NSString(format:"%@%@",queryString,downloadingTask.stringFromParameters(parameters!)) as String
            completeUrl = NSURL(string:queryString)!
        }
        
        //Prepare-Request
        let request:NSURLRequest=NSURLRequest(URL: completeUrl)
        downloadingTask.dataTask = downloadingTask.session.dataTaskWithRequest(request) { (data: NSData!, response: NSURLResponse?, error: NSError?) -> Void in
            var parsingError: NSError?
            let jsonObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(), error: &parsingError)
            downloadingTask.completionBlock!(responseObject: jsonObject?,urlResponse: response?,error: error)
        }
        
        return downloadingTask
    }
    
    //Init
    override init() {
        
    }
    
    ///convert the parameter dict to its HTTP string representation
    private func stringFromParameters(parameters: Dictionary<String,AnyObject>) -> String
    {
        return join("&", map(serializeHttpRequestObject(parameters, key: nil), {(pair) in
            return pair.stringValue()
        }))
    }
    
    ///the method to serialized all the objects
    private func serializeHttpRequestObject(object: AnyObject,key: String?) -> Array<HTTPRequestPair>
    {
        var collect = Array<HTTPRequestPair>()
        if let array = object as? Array<AnyObject> {
            for nestedValue : AnyObject in array {
                collect.extend(self.serializeHttpRequestObject(nestedValue,key: "\(key!)[]"))
            }
        } else if let dict = object as? Dictionary<String,AnyObject> {
            for (nestedKey, nestedObject: AnyObject) in dict {
                var newKey = key != nil ? "\(key!)[\(nestedKey)]" : nestedKey
                collect.extend(self.serializeHttpRequestObject(nestedObject,key: newKey))
            }
        } else {
            collect.append(HTTPRequestPair(value: object, key: key))
        }
        return collect
    }
    
    ///Local class to create key/pair of the parameters
    class HTTPRequestPair: NSObject
    {
        var value: AnyObject
        var key: String!
        
        init(value: AnyObject, key: String?) {
            self.value = value
            self.key = key
        }
        
        private func getValue() -> String
        {
            var val = ""
            if let str = self.value as? String {
                val = str
            } else if self.value.description != nil {
                val = self.value.description
            }
            return val
        }
        private func stringValue() -> String
        {
            var val = getValue()
            if self.key == nil {
                return val.escapeString()
            }
            return "\(self.key.escapeString())=\(val.escapeString())"
        }
    }
}
