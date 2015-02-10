//
//  searchCustomcell.swift
//  iosca_test2
//
//  Created by Student on 6/2/15.
//  Copyright (c) 2015 Student. All rights reserved.
//

import UIKit

class searchCustomcell: UITableViewCell {

    
    @IBOutlet weak var image_title: UILabel!
    
    @IBOutlet weak var _myimageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setCell(img:UIImage! , name:String!)
    {
        self.image_title.text = name;
        self._myimageView.image = img
    }

}
