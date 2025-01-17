//
//  Absence.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 13.10.2024.
//

import Foundation
import SwiftData

@Model
class Absence {
//    var id = UUID()
    var date: Date = Date.now
    var excused: Bool = false
    @Relationship(inverse: \Subject.absences) var subject: Subject?
    
    init(date: Date, excused: Bool) {
        self.date = date
        self.excused = excused
    }
}

extension [Absence]? {
    var excusedCount: Int {
        return self?.filter { $0.excused }.count ?? 0
    }
    
    var unexcusedCount: Int {
        return self?.filter { !$0.excused }.count ?? 0
    }
    
    var count: Int {
        return self?.count ?? 0
    }
}
