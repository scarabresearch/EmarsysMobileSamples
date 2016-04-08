//
//  RecommendedItem.swift
//  EmarsysPredictShopSwift
//
//

import UIKit

class RecommendedItem: UICollectionViewCell {
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var price: UILabel!
    
    var item: Item!
}
