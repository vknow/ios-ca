//
//  NextView.swift
//  iosca_test2
//
//  Created by Student on 6/2/15.
//  Copyright (c) 2015 Student. All rights reserved.
//

import UIKit


class NextView: UIViewController,UITableViewDataSource,UITableViewDelegate {
    @IBOutlet weak var _temp: UILabel!
    
    @IBOutlet weak var image_name: UILabel!
    
    @IBOutlet weak var _imagetablview: UITableView!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    
    var toPass:String!
    
    var imgArr:NSMutableArray!;
    
    let img_obj:GetImages  = GetImages()
    
    var noimage:UIAlertView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _temp.text = "\""+toPass+"\"";
        _imagetablview.delegate = self
        noimage =  UIAlertView(title: "Sorry", message: "No image for key \(self.toPass)", delegate: nil, cancelButtonTitle: "OK")
        loadimg()
        
        
    }
    
    func loadimg(){
        activity.startAnimating()
        println("Enter func")
        img_obj.loadimageforstring("s",searchstring:toPass, completion: { (searchString:String!,arrayPhotos:NSMutableArray!, error:NSError!) -> () in
            
            if (error == nil){
                if(arrayPhotos.count > 0)
                {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.imgArr = arrayPhotos
                        self._imagetablview.dataSource = self
                        self._imagetablview.reloadData()
                        self.activity.stopAnimating()
                        
                    })
                }
                else{
                    print("Else Case")
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.activity.stopAnimating()
                        self.noimage.show()
                        self.navigationController?.popToRootViewControllerAnimated(true)
                        
                    })
                    
                }
                
            }
            
        })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "viewfullsize"{
            if var view = segue.destinationViewController as? ViewImageFull{
                if let indexpath = self._imagetablview.indexPathForSelectedRow()
                {
                    var image_obj = self.imgArr[indexpath.row] as ImageModel
                    view.fullsize = image_obj
                    view.title  = image_obj.title
                }
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imgArr.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:searchCustomcell = tableView.dequeueReusableCellWithIdentifier("imgCell", forIndexPath: indexPath) as searchCustomcell
        
        if(indexPath.row % 2 == 0 )
        {
            cell.backgroundColor = UIColorFromRGB(0xB2DFEE)
            cell.image_title.textColor = UIColor.grayColor()
        }
        else
        {
            cell.backgroundColor = UIColorFromRGB(0xF0F8FF)
            cell.image_title.textColor = UIColor.blackColor()
        }
      
        let que:dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(que, {
        
            var error:NSError?
            let url:String = GetImages.downloadPhoto(self.imgArr.objectAtIndex(indexPath.item) as ImageModel, size: "s")
            let imageData:NSData = NSData(contentsOfURL: NSURL(string: url)!, options: nil, error: &error)!
            
            if(error == nil)
            {
                let imag:UIImage = UIImage(data: imageData)!
                dispatch_async(dispatch_get_main_queue(), {
                    cell.setCell(imag, name: (self.imgArr[indexPath.row] as ImageModel).title)
                })
            }
        
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
    
    
    
    
}
