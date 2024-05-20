//
//  SplitViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2024/05/20.
//  Copyright © 2024 Hisashi Ishihara. All rights reserved.
//

import UIKit

class SplitViewController: UISplitViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
    }
}

extension SplitViewController: UISplitViewControllerDelegate {
    
    @available(iOS 14.0, *)
    func splitViewController(_ svc: UISplitViewController, topColumnForCollapsingToProposedTopColumn proposedTopColumn: UISplitViewController.Column) -> UISplitViewController.Column {
        return .primary
    }
}
