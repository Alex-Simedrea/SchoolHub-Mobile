//
//  DoubleExtension.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 31.10.2024.
//

import Foundation

extension Double {
    var gradeFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: self)) ?? ""
    }
}
