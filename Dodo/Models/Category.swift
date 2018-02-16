//
//  Category.swift
//  Dodo
//
//  Created by Kevin Perkins on 2/15/18.
//  Copyright © 2018 Kevin Perkins. All rights reserved.
//

import Foundation
import RealmSwift

class Category : Object {
    @objc dynamic var name : String = ""
    let items = List<Item>()
}
