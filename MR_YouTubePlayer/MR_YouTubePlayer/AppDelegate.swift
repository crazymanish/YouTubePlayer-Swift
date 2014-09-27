//
//  AppDelegate.swift
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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var progressHud: MBProgressHUD?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //***********************************************************************
    // MARK: - Progress Hud
    //***********************************************************************
    
    //Instance
    private class func instance() -> AppDelegate{
        return UIApplication.sharedApplication().delegate as AppDelegate
    }
    
    
    //Useful to show Progress-HUD
    class func showProgressHudWithMessage(message:String) {
        AppDelegate.instance().showProgressHudWithMessage(message)
    }
    
    private func showProgressHudWithMessage(message:String) {
        if progressHud != nil {
            self.hideProgressHud()
        }
        progressHud = MBProgressHUD(window: self.window)
        self.window?.addSubview(progressHud!)
        progressHud?.labelText = message
        //Show Now
        progressHud?.show(true)
    }
    
    //Useful to Hide Progress-HUD
    class func hideProgressHud() {
        AppDelegate.instance().hideProgressHud()
    }
    
    private func hideProgressHud() {
        progressHud?.removeFromSuperview()
        progressHud = nil
    }
}

