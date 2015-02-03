//
//  MR_YouTubeListTableViewController.swift
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
import MediaPlayer

public let searchYouTubeVideoUrlString : String = "http://gdata.youtube.com/feeds/api/videos"

class MR_YouTubeListTableViewController: UITableViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate {
    
    //Video Quality-Type
    enum VideoQualityType: Int {
        case Hd720 = 1,
        Medium,
        Low
    }
    
    //IBOutlets
    @IBOutlet weak var videoSearchBar: UISearchBar!
    
    //Property
    private var videoList = NSMutableArray()
    private var currentPageNumber:Int = 0
    private var selectedRow:Int = -1
    
    
    //***********************************************************************
    // MARK: - UITableViewDataSource
    //***********************************************************************
    
    //numberOfRowsInSection
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        var totalRows : Int!
        if (videoList.count == 0) {
            totalRows=videoList.count
        }else {
            totalRows = videoList.count+1
        }
        
        return totalRows
    }
    
    //cellForRowAtIndexPath
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell : UITableViewCell!
        
        if (indexPath.row < videoList.count) {
            cell = self.youTubeListTableViewCellAtIndexPath(indexPath)
        }else {
            cell = self.loadMoreTableViewCellAtIndexPath(indexPath)
        }
        
        return cell
    }
    
    //***********************************************************************
    // YouTube ListTableViewCellAtIndexPath
    //***********************************************************************
    private func youTubeListTableViewCellAtIndexPath(indexPath:NSIndexPath) ->MR_YouTubeListTableViewCell
    {
        let cell : MR_YouTubeListTableViewCell=tableView.dequeueReusableCellWithIdentifier("MR_YouTubeListTableViewCell", forIndexPath: indexPath) as MR_YouTubeListTableViewCell
        
        //Configure the cell...
        
        //detailString
        let detailString: NSString  = videoList[indexPath.row]["title"] as String
        cell.videoDetailLabel.text = detailString
        cell.videoThumbView.downloadImageWithUrlString(videoList[indexPath.row]["imageUrl"] as NSString)
        
        return cell;
    }
    
    //***********************************************************************
    // YouTube ListTableViewCellAtIndexPath
    //***********************************************************************
    private func loadMoreTableViewCellAtIndexPath(indexPath:NSIndexPath) ->UITableViewCell
    {
        let cell : MR_LoadMoreTableViewCell=tableView.dequeueReusableCellWithIdentifier("MR_LoadMoreTableViewCell", forIndexPath: indexPath) as MR_LoadMoreTableViewCell
        
        //Configure the cell...
        
        //Start-animating
        cell.activityIndicatorView.startAnimating()
        
        //Fetch Details
        self.fetchVideoDetails()
        
        return cell;
    }
    
    //didSelectRowAtIndexPath
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        selectedRow=indexPath.row
        
        var alert = UIAlertController(title: "Choose Format", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel, handler:alertViewCancelButtonHandler))
        alert.addAction(UIAlertAction(title: "Hd720", style: UIAlertActionStyle.Default, handler:hd720QualityButtonHandler))
        alert.addAction(UIAlertAction(title: "Medium", style: UIAlertActionStyle.Default, handler:mediumQualityButtonHandler))
        alert.addAction(UIAlertAction(title: "Low", style: UIAlertActionStyle.Default, handler:lowQualityButtonHandler))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //***********************************************************************
    // MARK: - AlertView Action
    //***********************************************************************
    private func alertViewCancelButtonHandler(alertView: UIAlertAction!)
    {
        selectedRow = -1
    }
    private func hd720QualityButtonHandler(alertView: UIAlertAction!)
    {
        self.playVideoWithVideoQualityType(VideoQualityType.Hd720)
    }
    private func mediumQualityButtonHandler(alertView: UIAlertAction!)
    {
        self.playVideoWithVideoQualityType(VideoQualityType.Medium)
    }
    private func lowQualityButtonHandler(alertView: UIAlertAction!)
    {
        self.playVideoWithVideoQualityType(VideoQualityType.Low)
    }
    
    //***********************************************************************
    // MARK: - Play Video
    //***********************************************************************
    private func playVideoWithVideoQualityType(qualityType:VideoQualityType)
    {
        if (selectedRow >= 0) {
            let url:NSURL=NSURL(string:(videoList[selectedRow]["videoUrl"] as NSString))!
            
            HCYoutubeParser.h264videosWithYoutubeURL(url, completeBlock: { (videoFormatDictionary, error) -> Void in
                if error == nil {
                    var videoString: String?
                    var videoFormat: String!
                    switch qualityType {
                    case .Hd720:
                        videoString = videoFormatDictionary["hd720"] as AnyObject? as? String
                        videoFormat = "HD720"
                    case .Medium:
                        videoString = videoFormatDictionary["medium"] as AnyObject? as? String
                        videoFormat = "Medium"
                    case .Low:
                        videoString = videoFormatDictionary["small"] as AnyObject? as? String
                        videoFormat = "Low"
                    default:
                        println("default case excuted")
                    }
                    
                    if videoString == nil {
                        var alert = UIAlertController(title: "Error", message: "This video don't supports \(videoFormat),\n Please play the video with other formats.", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel, handler:self.alertViewCancelButtonHandler))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }else {
                        //Play Video Now
                        var mediaPlayer: MPMoviePlayerViewController = MPMoviePlayerViewController(contentURL: NSURL(string: videoString!))
                        self.presentViewController(mediaPlayer, animated: true, completion: nil)
                    }
                }else {
                    var alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel, handler:self.alertViewCancelButtonHandler))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            })
        }
    }
    
    
    //***********************************************************************
    // MARK: - UISearchBarDelegate
    //***********************************************************************
    
    // called when keyboard search button pressed
    func searchBarSearchButtonClicked(searchBar: UISearchBar)
    {
        currentPageNumber=0
        videoList = NSMutableArray()
        self.fetchVideoDetails()
    }
    
    
    //***********************************************************************
    // MARK: - fetchDetails For PageNumber
    //***********************************************************************
    private func fetchVideoDetails()
    {
        //Show Loading
        AppDelegate.showProgressHudWithMessage("Loading...")
        
        var dataDictionary = Dictionary<String, AnyObject>()
        
        dataDictionary["orderby"] = "relevance" //"published"
        dataDictionary["v"] = "2"
        dataDictionary["alt"] = "json"
        dataDictionary["max-results"] = 25
        dataDictionary["start-index"] = currentPageNumber+1
        dataDictionary["q"] = self.videoSearchBar.text
        
        let url:NSURL = NSURL(string:searchYouTubeVideoUrlString)!
        MR_YouTubeApiManager.sharedInstance.callWebServiceWithUrlString(url, serviceType: "GET", ServiceParameters:dataDictionary, withCompletionHandler: { (responseObject, urlResponse, error) -> Void in
            if responseObject == nil {
                //Update UI in main-thread
                dispatch_async(dispatch_get_main_queue(), {
                    var alert = UIAlertController(title: "Error", message: "Something wrong going on.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel, handler:self.alertViewCancelButtonHandler))
                    self.presentViewController(alert, animated: true, completion: nil)
                })
            }else {
                //Update UI in main-thread
                dispatch_async(dispatch_get_main_queue(), {
                    //Add & Reload
                    self.videoList.addObjectsFromArray(self.videoListFromJSON(responseObject as Dictionary<String, AnyObject>))
                    self.tableView.reloadData()
                })
                //+1 Page-Number
                ++self.currentPageNumber
            }
            
            //Update UI in main-thread
            dispatch_async(dispatch_get_main_queue(), {
                //Hide Loading
                AppDelegate.hideProgressHud()
            })
        })
    }
    
    private func videoListFromJSON(json: Dictionary<String, AnyObject>) -> [Dictionary<String, String>]
    {
        var videoList = [Dictionary<String, String>]()
        
        if let feed = json["feed"] as? NSDictionary {
            if let entries = feed["entry"] as? NSArray {
                for entry in entries {
                    var dataDictionary = Dictionary<String, String>()
                    if let name = entry["title"] as? NSDictionary {
                        if let label = name["$t"] as? String {
                            dataDictionary["title"] = label
                        }
                    }
                    if let link = entry["link"] as? NSArray {
                        if let label = link[0] as? NSDictionary {
                            if let href = label["href"] as? String {
                                let videoUrl = href.stringByReplacingOccurrencesOfString("&feature=youtube_gdata", withString: "", options: nil, range: nil)
                                dataDictionary["videoUrl"] = videoUrl
                            }
                        }
                    }
                    if let mediaGroup = entry["media$group"] as? NSDictionary {
                        if let link = mediaGroup["media$thumbnail"] as? NSArray {
                            if let label = link[0] as? NSDictionary {
                                if let imageUrl = label["url"] as? String {
                                    dataDictionary["imageUrl"] = imageUrl
                                }
                            }
                        }
                    }
                    videoList.append(dataDictionary)
                }
            }
        }
        
        return videoList
    }
    
}

