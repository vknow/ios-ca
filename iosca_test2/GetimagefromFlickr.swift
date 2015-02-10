//
//  GetimagefromFlickr.swift
//  iosca_test2
//
//  Created by Student on 6/2/15.
//  Copyright (c) 2015 Student. All rights reserved.
//

import UIKit

class GetImages {
   
    class func getImagefromUrl(searchstr:String) -> String
    {
        let apikey:String = "b216022f247d1e00753b0237044d0b82"
        let search:String = searchstr.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        return "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apikey)&text=\(search)&format=json&nojsoncallback=1&per_page=100"
    }
    
    class func downloadPhoto(obj:ImageModel , size:String)->String{
        var _size:String = size
        
        if _size.isEmpty{
            _size = "m"
        }
        
        return "http://farm\(obj.farm).staticflickr.com/\(obj.server)/\(obj.photoID)_\(obj.secret)_\(_size).jpg"
    }
    
    class func downloadfullsize(obj:ImageModel)->String{
        let apikey:String = "b216022f247d1e00753b0237044d0b82"
        
        return "https://api.flickr.com/services/rest/?method=flickr.photos.getInfo&api_key=\(apikey)&photo_id=\(obj.photoID)&format=json&nojsoncallback=1"
    }
    
    
    class func fullsecreteCode(photo:ImageModel,completion:(searchString:String!, string_val:String!, error:NSError!)->()){
        
        var jsonUrl:String! = downloadfullsize(photo)
        var dipatch:dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        println(jsonUrl)
        dispatch_async(dipatch, {
            var error:NSError?
            
            let searchstring:String! = NSString(contentsOfURL: NSURL(string : jsonUrl)!, encoding: NSUTF8StringEncoding, error: &error)
            if error != nil{
                completion (searchString: searchstring, string_val: nil, error: error)
            }
            else{
                
                var jsondata:NSData! = searchstring.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
                //                var temp:NSString = NSString(data: jsondata, encoding: NSUTF8StringEncoding)!
                //                NSLog("%@", temp)
                if let result:NSDictionary! = NSJSONSerialization.JSONObjectWithData(jsondata, options: nil, error: &error) as? NSDictionary
                {
                    if(error != nil){
                        completion(searchString: searchstring, string_val: nil, error: error)
                    }
                    else
                    {
                        println("HEllo")
                        let value:NSDictionary! = result.objectForKey("photo") as? NSDictionary
                        if let flag:String  = value.objectForKey("originalsecret") as? String
                        {
                            let status:String = result.objectForKey("photo")?.objectForKey("originalsecret") as String
                            
                            if status.isEmpty{
                                let error:NSError? =
                                NSError(domain: "FlickrSearch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:result.objectForKey("message")!])
                                completion(searchString: searchstring, string_val: nil, error: error)
                            }
                            else
                            {
                                completion(searchString: searchstring, string_val: status, error: nil)
                            }
                        }
                        else{
                             completion(searchString: searchstring, string_val: "no_val", error: nil)
                        }
                    }
                }
                    
                    
                else
                {
                    completion(searchString: searchstring, string_val: "no", error: error)
                }
            }
            
        })
        
    }
    
    
    func loadimageforstring(imagesize:String, searchstring:String , completion:(searchString:String!, arrayPhotos:NSMutableArray!, error:NSError!)->()){
        
        var urlstring:String = GetImages.getImagefromUrl(searchstring);
        var dispatch_q:dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        
        
        dispatch_async(dispatch_q, {
            var error:NSError?
            
            let searchstring:String! = NSString(contentsOfURL: NSURL(string : urlstring)!, encoding: NSUTF8StringEncoding, error: &error)
            if error != nil{
                completion (searchString: searchstring, arrayPhotos: nil, error: error)
            }
            else
            {
                var jsondata:NSData! = searchstring.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
                let result:NSDictionary! = NSJSONSerialization.JSONObjectWithData(jsondata, options: nil, error: &error) as NSDictionary
                if(error != nil){
                    completion(searchString: searchstring, arrayPhotos: nil, error: error)
                }
                else
                {
                    let status:String = result.objectForKey("stat") as String
                    
                    if status == "fail"{
                        let error:NSError? =
                        NSError(domain: "FlickrSearch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:result.objectForKey("message")!])
                        
                        completion(searchString: searchstring, arrayPhotos: nil, error: error)
                    }
                    else
                    {
                        let resultArray:NSArray = result.objectForKey("photos")?.objectForKey("photo")  as NSArray
                        
                        let flickrPhotos:NSMutableArray = NSMutableArray()
                        
                        for photoObject in resultArray{
                            let photoDict:NSDictionary = photoObject as NSDictionary
                            println(photoDict)
                            var flickrPhoto:ImageModel = ImageModel()
                            flickrPhoto.farm = photoDict.objectForKey("farm") as Int
                            flickrPhoto.server = photoDict.objectForKey("server") as String
                            flickrPhoto.secret = photoDict.objectForKey("secret") as String
                            flickrPhoto.photoID = photoDict.objectForKey("id") as String
                            flickrPhoto.title = photoDict.objectForKey("title") as String
                            
                            let searchURL:String = GetImages.downloadPhoto(flickrPhoto, size: imagesize)
                            println(searchURL);
                            
//                            let imageData:NSData = NSData(contentsOfURL: NSURL(string: searchURL)!, options: nil, error: &error)!
//                            let image:UIImage = UIImage(data: imageData)!
                            
                            flickrPhoto.thumbnail = nil
                            
                            flickrPhotos.addObject(flickrPhoto)
                            
                        }
                        completion(searchString: searchstring, arrayPhotos: flickrPhotos, error: nil)
                    }
                }
            }
        })
    }
    
}
