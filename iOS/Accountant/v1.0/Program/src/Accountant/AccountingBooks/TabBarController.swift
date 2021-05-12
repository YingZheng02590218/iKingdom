//
//  TabBarController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2021/05/07.
//  Copyright © 2021 Hisashi Ishihara. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // 背景の透過
        UITabBar.appearance().backgroundImage = UIImage()
        // 境界線の透過
        UITabBar.appearance().shadowImage = UIImage()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
