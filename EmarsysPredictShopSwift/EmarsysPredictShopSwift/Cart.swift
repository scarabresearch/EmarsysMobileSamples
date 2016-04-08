//
//  Cart.swift
//  EmarsysPredictShopSwift
//
//

import UIKit
import EmarsysPredictSDK

class Cart: NSObject {
    
    var cartItems = [CartItem]()
    
    private override init() {
        super.init()
    }
    
    class var sharedCart: Cart {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: Cart! = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = Cart()
        }
        return Static.instance
    }
    
    func addItem(item: Item) {
        for next in cartItems {
            if next.item.itemID == item.itemID {
                next.count += 1
                return
            }
        }
        let newItem = CartItem()
        newItem.item = item
        newItem.count = 1
        cartItems.append(newItem)
    }
    
    func convertItems() -> [EMCartItem] {
        return cartItems.map({ EMCartItem(itemID: $0.item.itemID, price: $0.item.price!, quantity: $0.count) })
    }
}
