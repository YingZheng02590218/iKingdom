//
//  Toast.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2024/01/26.
//  Copyright © 2024 Hisashi Ishihara. All rights reserved.
//

import UIKit

enum Toast {
    
    internal static func show(_ text: String, _ parent: UIView) {
        DispatchQueue.main.async {
            let label = UILabel()
            let width = 300.0
            let height = 50.0
            var bottomPadding = 0.0
            if #available(iOS 13.0, *) {
                let scenes = UIApplication.shared.connectedScenes
                let windowScene = scenes.first as? UIWindowScene
                if let window = windowScene?.windows.first {
                    bottomPadding = window.safeAreaInsets.bottom
                }
            }
            label.backgroundColor = UIColor.red.withAlphaComponent(0.8)
            label.textColor = UIColor.white
            label.textAlignment = .center
            label.text = text
            label.frame = CGRect(
                x: parent.frame.size.width * 0.5 - (width / 2),
                y: parent.frame.size.height - height - bottomPadding,
                width: width,
                height: height
            )
            parent.addSubview(label)
            
            UIView.animate(
                withDuration: 1.0, 
                delay: 3.0,
                options: .curveEaseOut,
                animations: {
                    label.alpha = 0.0
                }, completion: { _ in
                    label.removeFromSuperview()
                }
            )
        }
    }
}
