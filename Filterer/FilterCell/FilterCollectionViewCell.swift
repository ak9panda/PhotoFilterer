//
//  FilterCollectionViewCell.swift
//  Filterer
//
//  Created by admin on 07/10/2021.
//  Copyright © 2021 UofT. All rights reserved.
//

import UIKit

class FilterCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var textLabel: UILabel!
    
    static var identifier : String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
