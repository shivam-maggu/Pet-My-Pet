//
//  Card.swift
//  Pet My Pet
//
//  Created by Shivam Maggu on 12/02/19.
//  Copyright © 2019 Shivam Maggu. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class Card: UIView {
    
    @IBOutlet weak var mImage: UIImageView!
    @IBOutlet weak var mTitle: UILabel!
    @IBOutlet weak var mDescription: UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    //Put data on card.xib
    func prepareUI(text: String, img: String, des: String) {
        mTitle.text = text
        mDescription.text = des
        let imgUrl = URL(string: img)
        mImage.kf.setImage(with: imgUrl)
    }
}
