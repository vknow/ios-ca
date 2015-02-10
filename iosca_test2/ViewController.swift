//
//  ViewController.swift
//  iosca_test2
//
//  Created by Student on 6/2/15.
//  Copyright (c) 2015 Student. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var searchKey: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
 
         NSLog("%@", "Hell")
        searchKey.delegate = self
        searchKey.enablesReturnKeyAutomatically = true
        searchKey.resignFirstResponder()
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        searchKey.resignFirstResponder()
performSegueWithIdentifier("nextView", sender: self)
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == "nextView"{
            if searchKey.text.isEmpty{
                var alertWindow:UIAlertView = UIAlertView(title: "Error", message: "Enter the Search value", delegate: nil, cancelButtonTitle: "OK")
                alertWindow.show()
                return false
            }
            else
            {
                
                return true
            }
        }
        else
        {
            return false
        }
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "nextView"{
            var tem = searchKey.text
            let temp1 = segue.destinationViewController as NextView
            temp1.toPass  = tem
        }
    }

}

