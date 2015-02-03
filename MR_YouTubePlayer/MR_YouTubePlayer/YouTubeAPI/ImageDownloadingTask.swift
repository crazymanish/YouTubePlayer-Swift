//
//  ImageDownloadingTask.swift
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

class ImageDownloadingTask: NSObject,NSURLSessionDownloadDelegate {
    
    //Blocks
    private var progressBlock:DownloadingImageProgressBlock?
    private var completionBlock:DownloadingImageCompletionBlock?
    private var downloadedProgress:NSProgress?
    
    /**
    * will hold the Url-session
    */
    private var session:NSURLSession?
    
    /**
    * will hold the NSURLSessionDownloadTask Object
    */
    var downloadTask:NSURLSessionDownloadTask?
    
    
    //***********************************************************************
    // MARK: - Init & Prepare Download Request Here
    //***********************************************************************
    func initWithImageUrl(url: NSURL, withOperationQueue queue:NSOperationQueue, withCompletionHandler completionHandler:DownloadingImageCompletionBlock, withDownloadProgressHandler progressHandler:DownloadingImageProgressBlock) -> ImageDownloadingTask {
        
        var downloadingTask:ImageDownloadingTask = ImageDownloadingTask()
        
        //Callback
        downloadingTask.completionBlock=completionHandler
        downloadingTask.progressBlock=progressHandler
        
        //Progress
        downloadingTask.downloadedProgress = NSProgress(totalUnitCount: 1)
        
        //Session configuration
        var configuration:NSURLSessionConfiguration=NSURLSessionConfiguration.defaultSessionConfiguration()
        downloadingTask.session=NSURLSession(configuration: configuration, delegate: downloadingTask, delegateQueue: queue)
        
        //Prepare-Request
        var request:NSURLRequest=NSURLRequest(URL: url)
        downloadingTask.downloadTask=downloadingTask.session?.downloadTaskWithRequest(request)
        
        return downloadingTask
    }
    
    //Init
    override init() {
        
    }
    
    //***********************************************************************
    // MARK: - NSURLSessionDownloadDelegate
    //***********************************************************************
    
    /* Sent when a download task that has completed a download.  The delegate should
    * copy or move the file at the given location to a new location as it will be
    * removed when the delegate message returns. URLSession:task:didCompleteWithError: will
    * still be called.
    */
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL){
        
        //Complition Block with Sucess Image
        let imagePath:NSString=location.path!
        let imageData:NSData=NSFileManager.defaultManager().contentsAtPath(imagePath)!
        let image:UIImage=UIImage(data: imageData)!
        //Call Blocak Now
        completionBlock!(image:image,imageUrl: downloadTask.originalRequest.URL,error:nil)
    }
    
    /* Sent periodically to notify the delegate of download progress. */
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64){
        //Progress Block
        downloadedProgress?.totalUnitCount=totalBytesExpectedToWrite
        downloadedProgress?.completedUnitCount=totalBytesWritten
        progressBlock!(imageUrl: downloadTask.originalRequest.URL,downloadProgress: downloadedProgress!)
    }
    
    /* Sent when a download has been resumed. If a download failed with an
    * error, the -userInfo dictionary of the error will contain an
    * NSURLSessionDownloadTaskResumeData key, whose value is the resume
    * data.
    */
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64){
        //Not Using Resume
    }
    
    /* Sent as the last message related to a specific task.  Error may be
    * nil, which implies that no error occurred and this task is complete.
    */
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?){
        //Call Blocak Now
        completionBlock!(image:nil,imageUrl: task.originalRequest.URL,error:error)
    }
}
