//
//  TodoItem.swift
//  Dodo
//
//  Created by Kevin Perkins on 2/13/18.
//  Copyright © 2018 Kevin Perkins. All rights reserved.
//

import Foundation

class Item: Codable {
    let name : String
    var finished : Bool = false
    
    init(text: String) {
        name = text
    }
}
