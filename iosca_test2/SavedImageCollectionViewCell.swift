//
//  SavedImageCollectionViewCell.swift
//  iosca_test2
//
//  Created by Student on 9/2/15.
//  Copyright (c) 2015 Student. All rights reserved.
//

import UIKit

class SavedImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var _image: UIImageView!
 
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
 func  setimage(temp:UIImage!){
    
    self._image.image = temp;
    
    }
}

