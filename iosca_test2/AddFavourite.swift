import UIKit

class faveImage:NSObject{
    
    var title:String!
    var photoID:String!
    var farm:Int32!
    var server:String!
    var secret:String!
    var comment:String!
   
    init(photoid:String,title:String,farm:Int32,server:String,secret:String,comment:String)
    {
        self.title = title
        self.photoID = photoid
        self.secret = secret
        self.server = server
        self.farm = farm
        self.comment = comment
    }

}