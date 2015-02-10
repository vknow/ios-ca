//
//  FavImageViewController.swift
//  iosca_test2
//
//  Created by Student on 8/2/15.
//  Copyright (c) 2015 Student. All rights reserved.
//

import UIKit
import Social

class FavImageViewController: UIViewController,UITextFieldDelegate,UIAlertViewDelegate {
    
    @IBOutlet weak var _presentfavimage: UIImageView!
    @IBOutlet weak var _favimagetitle: UILabel!
    @IBOutlet weak var _favimageComment: UITextField!
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    var activeTextField:UITextField!
    var mediumURl:String!
    var _favtile:String!
    var _comment:String!
    
    var img_model:faveImage!
    
    var contactDB :COpaquePointer = nil
    var upadateCommentStatement:COpaquePointer = nil
    var delelteFavorite:COpaquePointer = nil
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollview.layoutIfNeeded()
        scrollview.contentSize = contentView.bounds.size
        _favimageComment.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerForKeyboardNotifications()
        let imageData:NSData = NSData(contentsOfURL: NSURL(string: mediumURl)!)!
        let image:UIImage = UIImage(data: imageData)!
        _presentfavimage.image  = image
        _favimagetitle.text = _favtile
        _favimageComment.text = _comment
        
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
        
        sqlStrings = "update FAV2_COM SET COMMENT = ? where PHOTOID = ?"
        var csql = sqlStrings.cStringUsingEncoding(NSUTF8StringEncoding)
        sqlite3_prepare_v2(contactDB, csql!, -1, &upadateCommentStatement, nil)
        
        var sqlDelete = "delete from FAV2_COM WHERE PHOTOID=?"
         var delsql = sqlDelete.cStringUsingEncoding(NSUTF8StringEncoding)

        sqlite3_prepare_v2(contactDB, delsql!, -1, &delelteFavorite, nil)
    }
    
    func updateComment(){
        var comment = (_favimageComment.text as NSString).UTF8String
        var photo_id = (img_model.photoID as NSString).UTF8String
        
        sqlite3_bind_text(upadateCommentStatement, 1, comment, -1, nil)
        sqlite3_bind_text(upadateCommentStatement,2, photo_id, -1, nil)
        
        if(sqlite3_step(upadateCommentStatement) == SQLITE_ROW){
            println("Upadted")
        }
        let upt_coment_alert = UIAlertView(title: nil, message: "Comment Upadted", delegate: nil, cancelButtonTitle: "OK")
        upt_coment_alert.show()
        sqlite3_reset(upadateCommentStatement)
        sqlite3_clear_bindings(upadateCommentStatement)
        
    }
    
    @IBAction func fbshare(sender: AnyObject) {
        
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook){
            var fb:SLComposeViewController  = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            fb.setInitialText(_favimageComment.text)
            fb.addImage(_presentfavimage.image)
            self.presentViewController(fb, animated: true, completion: nil)
        }
        else
        {
            var alertFB:UIAlertView = UIAlertView(title: "Error", message: "Please login to Facebook account", delegate: nil, cancelButtonTitle: "OK")
            alertFB.show()
        }
        
    }
    
    
    @IBAction func twitterShare(sender: AnyObject) {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter){
            var fb:SLComposeViewController  = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            fb.setInitialText(_favimageComment.text)
            fb.addImage(_presentfavimage.image)
            self.presentViewController(fb, animated: true, completion: nil)
        }
        else
        {
            var alertFB:UIAlertView = UIAlertView(title: "Error", message: "Please login to Twitter account", delegate: nil, cancelButtonTitle: "OK")
            alertFB.show()
        }
        
    }
    
    
    @IBAction func deleteAction(sender: AnyObject) {
        let confirm_delete  = UIAlertView(title: "Alert", message: "Are you sure you want to delete?", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Ok")
        confirm_delete.show()
    }
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        switch(buttonIndex)
        {
        case 0:
            println("Cancel")
        case 1:
            println("Ok")
            deletefromDB()
        default:
            println("de")
        }
    }
    
    func deletefromDB()
    {
        var id = (img_model.photoID as NSString).UTF8String
        sqlite3_bind_text(delelteFavorite, 1, id, -1, nil)
        if (sqlite3_step(delelteFavorite) == SQLITE_DONE)
        {
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
        else
        {
            println("Error Code >>",sqlite3_errcode(delelteFavorite));
            let error = String.fromCString(sqlite3_errmsg(delelteFavorite))
            println("Error Message" + error!)
        }
        sqlite3_reset(delelteFavorite)
        sqlite3_clear_bindings(delelteFavorite)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func registerForKeyboardNotifications() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self,
            selector: "keyboardWillBeShown:",
            name: UIKeyboardWillShowNotification,
            object: nil)
        notificationCenter.addObserver(self,
            selector: "keyboardWillBeHidden:",
            name: UIKeyboardWillHideNotification,
            object: nil)
    }
    
    func keyboardWillBeShown(sender: NSNotification) {
        let info: NSDictionary = sender.userInfo!
        let value: NSValue = info.valueForKey(UIKeyboardFrameBeginUserInfoKey) as NSValue
        let keyboardSize: CGSize = value.CGRectValue().size
        let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)
        scrollview.contentInset = contentInsets
        scrollview.scrollIndicatorInsets = contentInsets
        
        // If active text field is hidden by keyboard, scroll it so it's visible
        // Your app might not need or want this behavior.
        var aRect: CGRect = self.view.frame
        aRect.size.height -= keyboardSize.height
        let activeTextFieldRect: CGRect? = activeTextField?.frame
        let activeTextFieldOrigin: CGPoint? = activeTextFieldRect?.origin
        if (!CGRectContainsPoint(aRect, activeTextFieldOrigin!)) {
            scrollview.scrollRectToVisible(activeTextFieldRect!, animated:true)
        }
    }
    
    // Called when the UIKeyboardWillHideNotification is sent
    func keyboardWillBeHidden(sender: NSNotification) {
        let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(50, 0, 0, 0)
        scrollview.contentInset = contentInsets
        scrollview.scrollIndicatorInsets = contentInsets
    }
    
    func textFieldDidBeginEditing(textField: UITextField!) {
        activeTextField = textField
        scrollview.scrollEnabled = true
    }
    
    func textFieldDidEndEditing(textField: UITextField!) {
        activeTextField = nil
        scrollview.scrollEnabled = false
        if(_comment != _favimageComment.text){
            updateComment()
        }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.registerForKeyboardNotifications()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
