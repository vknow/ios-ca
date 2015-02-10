
//
//  AppDelegate.swift
//  iosca_test2
//
//  Created by Student on 6/2/15.
//  Copyright (c) 2015 Student. All rights reserved.
//

import UIKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,AVAudioPlayerDelegate {
    
    var window: UIWindow?
    var audioPlayer:AVAudioPlayer!
    
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        UINavigationBar.appearance().barTintColor = UIColorFromRGB(0x067AB5)
        UIBarButtonItem.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
     playmusic("1")
        return true
    }
    func playmusic(file:String)
    {
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, {[ weak self] in
            let audioSession = AVAudioSession.sharedInstance();
            NSNotificationCenter.defaultCenter().addObserver(self!, selector: "handleInterruption", name: AVAudioSessionInterruptionNotification, object: nil);
            audioSession.setActive(true, error: nil);
            var audioSessionError : NSError?;
            if audioSession.setCategory(AVAudioSessionCategoryPlayback, error: &audioSessionError)
            {
                println("Audio Session started");
            }
            else
            {
                println("Cannot start audio session");
            }
            let filePath = NSBundle.mainBundle().pathForResource("1" , ofType: "mp3");
            let fileData = NSData(contentsOfFile: filePath!,options: .DataReadingMappedIfSafe,error: nil);
            var error:NSError?;
            self!.audioPlayer = AVAudioPlayer(data: fileData, error: &error);
            if let theAudioPlayer = self!.audioPlayer
            {
                theAudioPlayer.delegate = self;
                theAudioPlayer.prepareToPlay();
                theAudioPlayer.play();
                
            }
            else
            {
                println("failed");
            }
        })
    }
  
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool)
    {
        player.play();
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
    
    
}

