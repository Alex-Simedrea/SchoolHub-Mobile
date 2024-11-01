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
    @Attribute(.unique) var id = UUID()
    var value: Int
    var date: Date
    @Relationship(inverse: \Subject.grades) var subject: Subject?
    
    init(value: Int, date: Date) {
        self.value = value
        self.date = date
    }
}

extension [Grade] {
    var average: Double {
        guard !self.isEmpty else { return 0 }
        return Double(self.reduce(0) { $0 + $1.value }) / Double(self.count)
    }
}
