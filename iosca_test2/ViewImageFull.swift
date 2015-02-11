//
//  ViewImageFull.swift
//  iosca_test2
//
//  Created by Student on 6/2/15.
//  Copyright (c) 2015 Student. All rights reserved.
//

import UIKit
import AssetsLibrary
import Social

class ViewImageFull: UIViewController,UIActionSheetDelegate,UIAlertViewDelegate {
    
    //UIVIEWS
    @IBOutlet weak var _activity: UIActivityIndicatorView!
    @IBOutlet weak var _fullImg: UIImageView!
    @IBOutlet weak var _imagetitle: UILabel!
    
    @IBOutlet weak var _temptitlelable: UILabel!
    //IMAGE OBJECT
    var fullsize:ImageModel!
    var error:NSError!
    
    //SQLITE VARIABLES
    
    var contactDB :COpaquePointer = nil
    var insertStatement:COpaquePointer = nil
    
    //Comment Var
    var comment:String!
    
    //LOAD IMAGE TO IMAGEVIEW
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //KEYBOARD
        
        
        //NAV BAR BUTTONS
        
        var bt1:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "moreoption:")
        var bt2:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "shareOption:")
        self.navigationItem.rightBarButtonItems = [bt2,bt1]
        
        fullimg()
        
        //SQL FILE PATHS
        
        var sqlpath = NSSearchPathForDirectoriesInDomains(
            .DocumentDirectory, .UserDomainMask, true)[0] as String
        var sqlfilename = sqlpath.stringByAppendingPathComponent("favourite.sqlite")
        
        if(sqlite3_open(sqlfilename, &contactDB) == SQLITE_OK)
        {
            var sql = "CREATE TABLE IF NOT EXISTS FAV2_COM(PHOTOID STRING PRIMARY KEY,SERVER STRING,TITLE STRING,FARM INT,SECRETE STRING,COMMENT STRING)"
            var statement:COpaquePointer = nil
            if(sqlite3_exec(contactDB, sql, nil, nil, nil) != SQLITE_OK){
                println("Faile  to create")
                println(sqlite3_errmsg(contactDB))
            }
            else
            {
                println("OK")
            }
        }
        else{
            println("falied to open db")
            println(sqlite3_errmsg(contactDB))
        }
        prepareStatements()
        
    }
    
    func prepareStatements(){
        var sqlStrings:String
        sqlStrings = "INSERT INTO FAV2_COM(PHOTOID,SERVER,TITLE,FARM,SECRETE,COMMENT) VALUES (?,?,?,?,?,?)"
        var csql = sqlStrings.cStringUsingEncoding(NSUTF8StringEncoding)
        sqlite3_prepare_v2(contactDB, csql!, -1, &insertStatement, nil)
    }
    
      override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
//        fullimg()
    }
    
    
    // ALERT VIEW DELEGATE
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if(alertView.tag == 0){
            comment = alertView.textFieldAtIndex(0)?.text
            if comment.isEmpty{
                comment = ""
            }
            addtofavorite()
        }
    }
    
    
    //BUTTON BAR ICON MOREOPTION
    
    @IBAction func moreoption(sender: AnyObject){
        if fullsize != nil{
            NSLog("%@", "Vino")
            let actionsheet = UIActionSheet(title: "More Options", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Save Image", "Add To Favourite")
            actionsheet.actionSheetStyle = .Default
            actionsheet.showInView(view)
        }
        else
        {
            var temp:UIAlertView = UIAlertView(title: "Error", message: "Image hasn't been loaded", delegate: nil, cancelButtonTitle: "Dismiss")
            temp.show()
        }
    }
    
    //SELECT ACTION FUNCTION
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        switch buttonIndex{
        case 0:
            print("Cancel")
        case 1:
            print("SAVE IMAGE")
            downloadImage(self)
        case 2:
            println("FAVOURITE Methde")
            callAlert()
        default:
            print("Def")
            
        }
    }
    
    func callAlert(){
        var comment_alert:UIAlertView = UIAlertView(title: "Comments", message: "Vino", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "OK")
        comment_alert.tag = 0;
        comment_alert.alertViewStyle = UIAlertViewStyle.PlainTextInput;
        comment_alert.show()
    }
    
    
    func addtofavorite(){
        println("FAVE SQL FUNC")
        println(">>>>"+comment)
        //        comment = ""
        var _id = (fullsize.photoID as NSString).UTF8String
        var _title = (fullsize.title as NSString).UTF8String
        var _server  = (fullsize.server as NSString).UTF8String
        var _farm:Int32 = Int32(fullsize.farm)
        var _secret = (fullsize.secret as NSString).UTF8String
        var _comment = (comment as NSString).UTF8String
        println("-----------------------")
        //        NSLog("%@,%@,%@,%d", _id,_server,_secret,_farm)
        println("-----------------------")
        println(_server)
        
        sqlite3_bind_text(insertStatement, 1, _id, -1, nil)
        sqlite3_bind_text(insertStatement, 2, _server, -1, nil)
        sqlite3_bind_text(insertStatement, 3, _title, -1, nil)
        sqlite3_bind_int(insertStatement, 4, _farm)
        sqlite3_bind_text(insertStatement, 5, _secret, -1, nil)
        sqlite3_bind_text(insertStatement,6,_comment,-1,nil)
        
        if(sqlite3_step(insertStatement) == SQLITE_DONE){
            var temp = UIAlertView(title: "Done", message: "Added to Favorites", delegate: nil, cancelButtonTitle: "OK")
            temp.show()
        }
        else{
            if sqlite3_errcode(contactDB) == 19{
                var temp = UIAlertView(title: "Error", message: "Already in Favorites", delegate: nil, cancelButtonTitle: "Dismiss")
                temp.show()
            }
            else{
                println("errorcode:", sqlite3_errcode(contactDB))
                let err = String.fromCString(sqlite3_errmsg(contactDB))
                println("Error>>",err)
            }
        }
        
        sqlite3_reset(insertStatement)
        sqlite3_clear_bindings(insertStatement)
        
    }
    
    //CREATE DIR IN DOCUMENT AND SELCTION OF IMAGE TO DOWNLOAD
    
    @IBAction func downloadImage(sender: AnyObject) {
        var error:NSError?
        
        var paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        var docDir:AnyObject = paths[0]
        var datapath = docDir.stringByAppendingPathComponent("Vinoth")
        if(!NSFileManager.defaultManager().fileExistsAtPath(datapath)){
            NSFileManager.defaultManager().createDirectoryAtPath(datapath, withIntermediateDirectories: false, attributes: nil, error: &error)
            if(error == nil)
            {
                saveimage(datapath, image: _fullImg)
            }
        }
        else
        {
            saveimage(datapath, image: _fullImg)
        }
        
    }
    
    //SAVE TO LOCAL DOCUMENT AND PHOTO ROLL
    
    
    func saveimage(path:String,image:UIImageView)->Bool{
        var temp:UIImage = image.image!
        UIImageWriteToSavedPhotosAlbum(temp,nil,nil,nil)
        let imgdata = UIImageJPEGRepresentation(image.image, 1.0)
        var img_path = path.stringByAppendingPathComponent(fullsize.photoID+".jpg")
        let result = imgdata.writeToFile(img_path, atomically: true)
        var alt:UIAlertView = UIAlertView(title: "Done", message: "Photo saved", delegate: nil, cancelButtonTitle: "OK")
        alt.show()
        print("SAve  "+img_path)
        return result
        
    }
    
    
    // SOCIAL MEDIA SHARING OPTIONS
    
    @IBAction func shareOption(sender: AnyObject) {
        if(fullsize != nil){
            let acv = UIActivityViewController(activityItems: [_fullImg.image!], applicationActivities: nil)
            acv.excludedActivityTypes = [ UIActivityTypeCopyToPasteboard,UIActivityTypeSaveToCameraRoll,UIActivityTypeAddToReadingList ]
            if(acv.popoverPresentationController != nil){
                acv.popoverPresentationController?.sourceView = sender.view
                acv.popoverPresentationController?.sourceRect = CGRect(x: 44, y: 10, width: 500, height: 500)
            }
            self.presentViewController(acv, animated: true, completion: nil)
        }
        else
        {
            var temp:UIAlertView = UIAlertView(title: "Error", message: "Image hasn't been loaded", delegate: nil, cancelButtonTitle: "Dismiss")
            temp.show()
            
        }
    }
    
    
    //DOWNLOAD LARGE SIZE IMAGE AND DISPLAY TO IMAGEVIEW
    
    func fullimg()
    {
        _fullImg.hidden = true;
//        _imagetitle.hidden = true
        _temptitlelable.hidden = true
        _activity.startAnimating()
        println("Enter FullView func")
        GetImages.fullsecreteCode(fullsize, completion:{ (search:String!,val:String!,error:NSError!) ->() in
            
            if(error == nil && val != "no_val"){
                dispatch_async(dispatch_get_main_queue(),{
                    
                    var url:String = "https://farm\(self.fullsize.farm).staticflickr.com/\(self.fullsize.server)/\(self.fullsize.photoID)_\(val)_o.jpg";
                    println(url)
                    
                    let que:dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                    dispatch_async(que, {
                        
                        var error:NSError?
                        let imageData:NSData = NSData(contentsOfURL: NSURL(string: url)!, options: nil, error: &error)!
                        
                        if(error == nil)
                        {
                            let imag:UIImage = UIImage(data: imageData)!
                            dispatch_async(dispatch_get_main_queue(), {
                                let image:UIImage = UIImage(data: imageData)!
                                self._fullImg.image = image
                                self._imagetitle.text = self.fullsize.title
                                self._fullImg.hidden = false
                                self._imagetitle.hidden = false
                                self._temptitlelable.hidden = false
                                self._activity.stopAnimating()
                                
                            })
                        }
                        
                    })
//                    let imageData:NSData = NSData(contentsOfURL: NSURL(string: url)!)!
                    
//                    let image:UIImage = UIImage(data: imageData)!
//                    self._fullImg.image = image
//                    self._imagetitle.text = self.fullsize.title
//                    self._fullImg.hidden = false
//                    self._imagetitle.hidden = false
//                    self._temptitlelable.hidden = false
//                    self._activity.stopAnimating()
                })
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(),{
                    self.loadimg()
                })
            }
        })
    }
    
    
    ///// LOADING MEDIUM SIZE IMAGE iF LARGE NOT AVAILABLE
    
    func loadimg(){
//        _fullImg.hidden = true;
//        _activity.startAnimating()
        println("Enter func")
        let searchURL:String = GetImages.downloadPhoto(fullsize, size: "m")
        println(searchURL);
        
        let imageData:NSData = NSData(contentsOfURL: NSURL(string: searchURL)!)!
        
        let image:UIImage = UIImage(data: imageData)!
        _fullImg.image = image
        _fullImg.hidden = false
        self._imagetitle.text = self.fullsize.title
//        _imagetitle.hidden = false
        _temptitlelable.hidden = false
        _activity.stopAnimating()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    
    
    
}
