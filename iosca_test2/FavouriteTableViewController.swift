//
//  FavouriteTableViewController.swift
//  iosca_test2
//
//  Created by Student on 7/2/15.
//  Copyright (c) 2015 Student. All rights reserved.
//

import UIKit

class FavouriteTableViewController: UITableViewController {
    
    //SQLITE VARIABLES
    
    var contactDB :COpaquePointer = nil
    var selectStatement:COpaquePointer = nil
    
    var images:NSMutableArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("Enter Fave Class")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
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
  
    func prepareStatements()
    {
        var sqlStrings:String
        
        sqlStrings = "Select * from FAV2_COM"
        var csql = sqlStrings.cStringUsingEncoding(NSUTF8StringEncoding)
        sqlite3_prepare_v2(contactDB, csql!, -1, &selectStatement, nil)
        
    }
    
    func display(){
        while(sqlite3_step(selectStatement) == SQLITE_ROW)
        {
            println("Status retived")
            let photoId = String.fromCString(UnsafePointer<CChar>(sqlite3_column_text(selectStatement, 0)))!
            let Title = String.fromCString(UnsafePointer<CChar>(sqlite3_column_text(selectStatement, 2)))!
            let Server = String.fromCString(UnsafePointer<CChar>(sqlite3_column_text(selectStatement, 1)))!
            let Farm:Int32 = sqlite3_column_int(selectStatement, 3)
            let Secret = String.fromCString(UnsafePointer<CChar>(sqlite3_column_text(selectStatement, 4)))!
            let Comment = String.fromCString(UnsafePointer<CChar>(sqlite3_column_text(selectStatement, 5)))!
            println("-----------------------")
            NSLog("%@,%d,%@,%@", photoId,Farm,Server,Secret)
            println("-----------------------")
            println(Comment)
                   var dispatch_q:dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
            images.addObject(faveImage(photoid: photoId, title: Title, farm: Farm, server: Server, secret: Secret,comment:Comment))
            
        }
        sqlite3_reset(selectStatement)
        sqlite3_clear_bindings(selectStatement)
        println("---------------")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        images.removeAllObjects()
        tableView.reloadData()
        display()
    }
    
    //GET SMALL IMAGE URL
    
    func downloadPhoto(obj:faveImage , size:String)->String{
        
        var _size:String = size
        return "http://farm\(obj.farm).staticflickr.com/\(obj.server)/\(obj.photoID)_\(obj.secret)_\(_size).jpg"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return images.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("imageCell", forIndexPath: indexPath) as searchCustomcell
        var temp:faveImage = images[indexPath.row] as faveImage
        
        if(indexPath.row % 2 == 0 )
        {
            cell.backgroundColor = UIColorFromRGB(0xB2DFEE)
            cell.image_title.textColor = UIColor.whiteColor()
        }
        else
        {
            cell.backgroundColor = UIColorFromRGB(0xF0F8FF)
            cell.image_title.textColor = UIColor.blackColor()
        }

        let que:dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(que, {
            var error:NSError?
             var url = self.downloadPhoto(temp, size: "s")
            let imageData:NSData = NSData(contentsOfURL: NSURL(string: url)!, options: nil, error: &error)!
            if(error == nil)
            {
                let image:UIImage = UIImage(data: imageData)!
                dispatch_async(dispatch_get_main_queue(), {
                    cell.setCell(image, name: temp.title)
                });
            }
        })
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    
    
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
   
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "viewfav"
        {
            
            if let view_ = segue.destinationViewController as? FavImageViewController
            {
                let indexpath = tableView.indexPathForSelectedRow()?.row
                let img_obj = images.objectAtIndex(indexpath!) as? faveImage
                view_._comment = img_obj?.comment
                view_.mediumURl = downloadPhoto(img_obj!, size: "m")
                view_._favtile = img_obj?.title
                view_.img_model = img_obj
            }
        }
    }
    
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

    
}
