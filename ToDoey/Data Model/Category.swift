//
//  Category.swift
//  ToDoey
//
//  Created by Eugene Razorenov on 19/06/2019.
//  Copyright © 2019 Eugene Razorenov. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    
    @objc dynamic var name : String = ""
    @objc dynamic var cellColor  : String = ""
    
    let items = List<Item>()
    
}
