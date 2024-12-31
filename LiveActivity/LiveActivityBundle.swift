//
//  LiveActivityBundle.swift
//  LiveActivity
//
//  Created by Alexandru Simedrea on 21.12.2024.
//

import SwiftUI
import WidgetKit

@main
struct LiveActivityBundle: WidgetBundle {
    var body: some Widget {
#if !targetEnvironment(macCatalyst)
        TimetableLiveActivity()
#endif
    }
}
