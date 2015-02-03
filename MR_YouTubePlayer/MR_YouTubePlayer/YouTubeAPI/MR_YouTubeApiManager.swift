//
//  MR_YouTubeApiManager.swift
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

/**
* CallBacks
*/

//JSON Response of Webservice
typealias JsonResponseCompletionBlock = (responseObject:AnyObject?,urlResponse:NSURLResponse?,error:NSError?) -> Void

//Image-Downloading
typealias DownloadingImageCompletionBlock = (image:UIImage?,imageUrl:NSURL,error:NSError?) -> Void
typealias DownloadingImageProgressBlock = (imageUrl:NSURL,downloadProgress:NSProgress) -> Void

//YouTube
typealias VideoUrlResponseCompletionBlock = (Dictionary<String, AnyObject>?,error:NSError?) -> Void

class MR_YouTubeApiManager : NSObject {
    
    /**
    * Download-Queue
    */
    private var operationQueue:NSOperationQueue!
    
    
    //***********************************************************************
    // MARK: - Singleton Instance
    //***********************************************************************
    class var sharedInstance : MR_YouTubeApiManager {
        
    struct staticVars {
        static var onceToken : dispatch_once_t = 0
        static var instance : MR_YouTubeApiManager? = nil
        }
        dispatch_once(&staticVars.onceToken) {
            staticVars.instance = MR_YouTubeApiManager()
        }
        return staticVars.instance!
    }
    
    //Init
    override init() {
        operationQueue=NSOperationQueue()
    }
    
    //***********************************************************************
    // MARK: - Download Image Here
    //***********************************************************************
    func downloadImageWithUrlString(urlString: NSString, withCompletionHandler completionHandler:DownloadingImageCompletionBlock, withDownloadProgressHandler progressHandler:DownloadingImageProgressBlock) {
        
        //Download-Now
        let url:NSURL=NSURL(string:urlString)!
        downloadImageWithUrl(url, withCompletionHandler: completionHandler, withDownloadProgressHandler: progressHandler)
    }
    
    func downloadImageWithUrl(url: NSURL, withCompletionHandler completionHandler:DownloadingImageCompletionBlock, withDownloadProgressHandler progressHandler:DownloadingImageProgressBlock) {
        //Create New Image-Download-Task
        var downloadingImageTask:ImageDownloadingTask = ImageDownloadingTask().initWithImageUrl(url, withOperationQueue: operationQueue, withCompletionHandler: completionHandler, withDownloadProgressHandler: progressHandler)
        
        //Start Download
        downloadingImageTask.downloadTask?.resume()
    }
    
    //***********************************************************************
    // MARK: - Call Web-services Here
    //***********************************************************************
    func callWebServiceWithUrlString(urlString: NSString, serviceType type: NSString?, ServiceParameters parameters: Dictionary<String,AnyObject>?, withCompletionHandler completionHandler:JsonResponseCompletionBlock) {
        //Download-Now
        let url:NSURL=NSURL(string:urlString)!
        callWebServiceWithUrlString(url, serviceType: type, ServiceParameters: parameters, withCompletionHandler: completionHandler)
    }
    
    func callWebServiceWithUrlString(url: NSURL, serviceType type: NSString?, ServiceParameters parameters: Dictionary<String,AnyObject>?, withCompletionHandler completionHandler:JsonResponseCompletionBlock) {
        //Create New Data-Task
        var httpTask:HttpServiceDataTask = HttpServiceDataTask().initHTTPGetServiceWithUrl(url, ServiceParameters: parameters, withOperationQueue: operationQueue, withCompletionHandler: completionHandler)

        //Start Task
        httpTask.dataTask?.resume()
    }
    
}