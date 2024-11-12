//
//  Grade.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 13.10.2024.
//

import Foundation
import SwiftData

@Model
class Grade {
//    var id = UUID()
    var value: Int = 10
    var date: Date = Date.now
    @Relationship(inverse: \Subject.grades) var subject: Subject?
    
    init(value: Int, date: Date) {
        self.value = value
        self.date = date
    }
}

extension [Grade]? {
    var average: Double {
        guard let self = self, !self.isEmpty else { return 0 }
        return Double(self.reduce(0) { $0 + $1.value }) / Double(self.count)
    }
    
    var count: Int {
        return self?.count ?? 0
    }
}
