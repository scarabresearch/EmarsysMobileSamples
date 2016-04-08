//
//  DataSource.swift
//  EmarsysPredictShopSwift
//
//

import Foundation

class DataSource: NSObject {
    
    var categories = [String]()
    var items = [Item]()
    
    private override init() {
        super.init()
    }
    
    class var sharedDataSource: DataSource {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: DataSource!
        }
        dispatch_once(&Static.onceToken) {
            let dataSource = DataSource()
            Static.instance = dataSource
            
            let path = NSBundle.mainBundle().pathForResource("/sample", ofType: "csv")!
            let content = try! String(contentsOfFile:path, encoding:NSUTF8StringEncoding)
            let rows = content.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
            
            for rowIndex in 1...rows.count-1 {
                let row = rows[rowIndex]
                let item = Item()
                let cells = row.componentsSeparatedByString(",")
                
                for index in 0...cells.count-1 {
                    switch (index) {
                    case 0:
                        item.itemID = cells[index]
                        break
                    case 1:
                        item.link = cells[index]
                        break
                    case 2:
                        item.title = cells[index]
                        break
                    case 3:
                        item.image = cells[index]
                        break
                    case 4:
                        item.category = cells[index]
                        if !dataSource.categories.contains(item.category!) {
                            dataSource.categories.append(item.category!)
                        }
                        break
                    case 5:
                        let s = cells[index] as NSString
                        item.price = s.floatValue
                        break
                    case 6:
                        let s = cells[index] as NSString
                        item.available = s.boolValue
                        break
                    case 7:
                        item.brand = cells[index]
                        break
                    default : break
                    }
                }
                dataSource.items.append(item)
            }
        }
        return Static.instance
    }
    
    func itemsFromCategory(category: String) -> [Item] {
        let filteredArray = items.filter() { $0.category == category }
        return filteredArray
    }
    
}
