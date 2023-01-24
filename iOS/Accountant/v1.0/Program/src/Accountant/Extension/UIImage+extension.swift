//
//  UIImage+extension.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/01/24.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import UIKit

extension UIImage {

    public convenience init(url: String) {
        let url = URL(string: url)
        do {
            let data = try Data(contentsOf: url!)
            self.init(data: data)!
            return
        } catch let err {
            print("Error : \(err.localizedDescription)")
        }
        self.init()
    }
}
