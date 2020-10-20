//
//  ViewController.swift
//  Canvas
//
//  Created by Hisashi Ishihara on 2020/07/08.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // CanvasViewを作成し、self.viewの子供にする
        let canvasview = CanvasView(frame: CGRect(x: 10, y: 100, width: 300, height: 200))
        self.view.addSubview(canvasview)
    }


}

