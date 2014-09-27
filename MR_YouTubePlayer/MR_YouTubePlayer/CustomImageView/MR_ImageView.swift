//
//  MR_ImageView.swift
//  ImageDownloader
//
//  Created by Manish Rathi on 20/09/14.
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

import Foundation
import UIKit

class MR_ImageView : UIImageView {
    
    /**
    * Downloading Image Url
    */
    private var downloadingImageUrl:NSURL?
    //Label
    private var progressLabel:UILabel!

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        downloadImageProgressLabel()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        downloadImageProgressLabel()
    }
    
    func downloadImageProgressLabel(){
        
        if (progressLabel == nil) {
            /** @Manish ---- Frame calculation (Height/Width) */
            progressLabel = UILabel(frame: CGRectMake(0, 0, self.frame.size.width, 21))
            progressLabel.center = self.center
            progressLabel.textAlignment = NSTextAlignment.Center
            progressLabel.text = ""
            progressLabel.textColor=UIColor.blueColor()
            //make is Hidden by-default
            progressLabel.hidden=true
            self.addSubview(progressLabel)
        }
    }
    
    //***********************************************************************
    // MARK: - Download Image
    //***********************************************************************
    func downloadImageWithUrlString(urlString: NSString){
        var url:NSURL=NSURL.URLWithString(urlString)
        self.downloadImageWithUrlString(url)
    }
    func downloadImageWithUrlString(url: NSURL){
        self.downloadImageWithUrlString(url, withPlaceholderImage: nil)
    }
    
    //***********************************************************************
    // MARK: - Download Image With Place-Holder Image
    //***********************************************************************
    func downloadImageWithUrlString(urlString: NSString, withPlaceholderImage placeholderImage:UIImage?){
        var url:NSURL=NSURL.URLWithString(urlString)
        self.downloadImageWithUrlString(url, withPlaceholderImage: placeholderImage)
    }
    func downloadImageWithUrlString(url: NSURL, withPlaceholderImage placeholderImage:UIImage?){
        
        //set placeholder-Image
        if placeholderImage != nil {
            self.image=placeholderImage
        }else{
            self.image=nil
        }
        
        //Set Url
        self.downloadingImageUrl=url
        //make is Un-Hide
        progressLabel.hidden=false
        progressLabel.text=""
        
        //Start Download the Image
        MR_YouTubeApiManager.sharedInstance.downloadImageWithUrl(url, withCompletionHandler: { (image, imageUrl, error) -> Void in
            if error == nil {
                if ((self.downloadingImageUrl?.isEqual(imageUrl) != nil) && image != nil) {
                    //Update UI in main-thread
                    dispatch_async(dispatch_get_main_queue(), {
                        self.image = image
                        //make is Hidden
                        self.progressLabel.hidden=true
                    })
                }
            }else{
                //Update UI in main-thread
                dispatch_async(dispatch_get_main_queue(), {
                    //make is Hidden
                    self.progressLabel.text="Error...."
                })
                //Show Error Alert in main-thread
            }
            }) { (imageUrl, downloadProgress) -> Void in
                if (self.downloadingImageUrl?.isEqual(imageUrl) != nil) {
                    //Update UI in main-thread
                    dispatch_async(dispatch_get_main_queue(), {
                        //make is Hidden by-default
                        self.progressLabel.text=downloadProgress.localizedDescription
                    })
                }
        }
    }
    
}
