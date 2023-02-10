//
//  PaciolistWidgetBundle.swift
//  PaciolistWidget
//
//  Created by Hisashi Ishihara on 2023/02/08.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import WidgetKit
import SwiftUI

@main
struct PaciolistWidgetBundle: WidgetBundle {
    var body: some Widget {
        PaciolistWidget()
        PaciolistWidgetLiveActivity()
    }
}
