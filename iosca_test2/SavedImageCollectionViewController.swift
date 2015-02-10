//
//  SavedImageCollectionViewController.swift
//  iosca_test2
//
//  Created by Student on 9/2/15.
//  Copyright (c) 2015 Student. All rights reserved.
//

import UIKit

let reuseIdentifier = "imageCell"

class SavedImageCollectionViewController: UICollectionViewController,UICollectionViewDelegate {
    
    var inde:UIImage? = UIImage()
    var indexpath:NSIndexPath = NSIndexPath()
    var _images:NSMutableArray!
    var defa:NSArray!;
    var datapath:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        //         self.clearsSelectionOnViewWillAppear = false
        
        _images = NSMutableArray()
        
        self.collectionView?.backgroundColor = UIColor.whiteColor()
        collectionView?.dataSource = self;
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadImages()
        collectionView?.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        _images.removeAllObjects()
    }
    
    func loadImages()
    {
        var error:NSError?
        
        var paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        var docDir:AnyObject = paths[0]
        datapath = docDir.stringByAppendingPathComponent("Vinoth")
        if(!NSFileManager.defaultManager().fileExistsAtPath(datapath)){
            println("NOfile")
            var nofolder =  UIAlertView(title: "Alert", message: "Download Folder is Empty!!!", delegate: nil, cancelButtonTitle: "OK")
            nofolder.show()
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
        else
            
        {
            defa = NSFileManager.defaultManager().contentsOfDirectoryAtPath(datapath, error: &error)!
            if(error==nil){
                println("------")
                for var i = 0; i <  defa.count ; i++ {
                    println(defa.objectAtIndex(i))
                }
            }
        }
        for var i=0;i < defa.count;i++ {
            var temp:NSString = datapath.stringByAppendingPathComponent(defa[i] as NSString)
            self._images.addObject(UIImage(contentsOfFile: temp)!)
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
       if segue.identifier == "editimage"
       {
        if let same = segue.destinationViewController as? FullView
            {
                let indexPath = collectionView?.indexPathForCell(sender as UICollectionViewCell)
                var collectioncell:SavedImageCollectionViewCell = collectionView?.cellForItemAtIndexPath(indexPath!) as SavedImageCollectionViewCell
                same.tem = collectioncell._image.image
            }
        }
    }
    
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 1
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return _images.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:SavedImageCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as SavedImageCollectionViewCell
        
        dispatch_async(dispatch_get_main_queue(), {
            cell.setimage(self._images.objectAtIndex(indexPath.item) as UIImage)
        })
        
        return cell
    }
    
    
    
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    // MARK: UICollectionViewDelegate
    
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
    }
    */
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var collectioncell:SavedImageCollectionViewCell = collectionView.cellForItemAtIndexPath(indexPath) as SavedImageCollectionViewCell
//        collectioncell.backgroundColor = UIColorFromRGB(0x067AB5)
        
    }
    
    override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
//        var collectioncell:SavedImageCollectionViewCell = collectionView.cellForItemAtIndexPath(indexPath) as SavedImageCollectionViewCell
//        collectioncell.backgroundColor = UIColor.clearColor()
    }
    
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    
    /*
    
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
    }
    
    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
    return true
    }
    
    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
    
}
