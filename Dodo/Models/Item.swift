//
//  Item.swift
//  Dodo
//
//  Created by Kevin Perkins on 2/15/18.
//  Copyright © 2018 Kevin Perkins. All rights reserved.
//

import Foundation
import RealmSwift

class Item : Object {
    @objc dynamic var name : String = ""
    @objc dynamic var finished : Bool = false
    @objc dynamic var dateCreated : Date?
    var category = LinkingObjects(fromType: Category.self, property: "items")
}
