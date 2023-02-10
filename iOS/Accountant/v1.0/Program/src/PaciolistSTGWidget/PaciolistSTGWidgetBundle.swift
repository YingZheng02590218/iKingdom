//
//  PaciolistSTGWidgetBundle.swift
//  PaciolistSTGWidget
//
//  Created by Hisashi Ishihara on 2023/02/09.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import WidgetKit
import SwiftUI

@main
struct PaciolistSTGWidgetBundle: WidgetBundle {
    var body: some Widget {
        PaciolistSTGWidget()
        PaciolistSTGWidgetLiveActivity()
    }
}
