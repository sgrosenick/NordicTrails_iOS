//
//  TrailsModel.swift
//  NordicTrails
//
//  Created by Samuel Grosenick on 11/10/18.
//  Copyright © 2018 Samuel Grosenick. All rights reserved.
//

import Foundation

class TrailsModel {
    let id: UUID
    var title: String
    var skiType: String
    var groomStatus: String
    var difficulty: String
    var conditions: String
    
    init(title: String, skiType: String, groomStatus: String, difficulty: String, conditions: String) {
        id = UUID()
        self.title = title
        self.skiType = skiType
        self.groomStatus = groomStatus
        self.difficulty = difficulty
        self.conditions = conditions
    }
}
