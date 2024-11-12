//
//  ProcessInfoExtension.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 09.11.2024.
//

import Foundation
import UIKit

extension ProcessInfo {
    var isOnMac: Bool {
        return ProcessInfo.processInfo.isMacCatalystApp || ProcessInfo.processInfo.isiOSAppOnMac ||
            UIDevice.current.userInterfaceIdiom == .pad
    }
}
