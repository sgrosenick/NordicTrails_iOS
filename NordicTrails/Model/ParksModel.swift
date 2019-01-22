//
//  ParksModel.swift
//  NordicTrails
//
//  Created by Samuel Grosenick on 11/3/18.
//  Copyright © 2018 Samuel Grosenick. All rights reserved.
//

import Foundation

class ParksModel {
    let id: UUID
    var title: String
//    var difficulty: String
//    var trailUse: String
    
    init(title: String) {
        id = UUID()
        self.title = title
//        self.difficulty = difficulty
//        self.trailUse = trailUse
    }
}
