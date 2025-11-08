//
//  AntrainWidgetBundle.swift
//  AntrainWidget
//
//  Created by Burak Macbook Mini on 7.11.2025.
//

import WidgetKit
import SwiftUI

@main
struct AntrainWidgetBundle: WidgetBundle {
    var body: some Widget {
        AntrainWidget()
        AntrainWidgetControl()
        AntrainWidgetLiveActivity()
    }
}
