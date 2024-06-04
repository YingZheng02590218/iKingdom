//
//  Cells.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2024/03/15.
//  Copyright © 2024 Hisashi Ishihara. All rights reserved.
//

import SpreadsheetView
import UIKit

class DateCell: Cell {
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        label.frame = bounds
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.textAlignment = .center
        label.textColor = .paperTextColor
        
        contentView.addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class TimeTitleCell: Cell {
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        label.frame = bounds
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .center
        label.textColor = .paperTextColor
        
        contentView.addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class TimeCell: Cell {
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        label.frame = bounds
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: UIFont.Weight.medium)
        label.textAlignment = .left
        label.textColor = .paperTextColor
        
        contentView.addSubview(label)
    }
    
    override var frame: CGRect {
        didSet {
            label.frame = bounds.insetBy(dx: 6, dy: 0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class ScheduleCell: BlurCell {
    var color: UIColor = .clear {
        didSet {
            backgroundView?.backgroundColor = color
        }
    }
    
    override var frame: CGRect {
        didSet {
            label.frame = bounds.insetBy(dx: 0, dy: 0)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        
        backgroundView = UIView()
        // selectedBackgroundView を明示的に生成することで、nilになることを防ぐ
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = .mainColor

        label.frame = bounds
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .right
        label.textColor = .paperTextColor
        
        contentView.addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class BlurCell: Cell {
    let label = UILabel()
    // ダークモード対応
    var blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UITraitCollection.isDarkMode ? UIBlurEffect.Style.dark : UIBlurEffect.Style.extraLight))
    
    open var isMasked = false {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        DispatchQueue.main.async {
            if self.isMasked {
                // ぼかし効果のスタイルを決め、エフェクトを生成
                // ぼかし効果を設定したUIVisualEffectViewのインスタンスを生成
                self.blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UITraitCollection.isDarkMode ? UIBlurEffect.Style.dark : UIBlurEffect.Style.extraLight))
                // ぼかし効果Viewのframeをviewのframeに合わせる
                self.blurEffectView.frame = self.label.frame
                
                self.blurEffectView.alpha = 1.0
                // viewにぼかし効果viewを追加
                if self.label.subviews.isEmpty {
                    self.label.addSubview(self.blurEffectView)
                } else {
                    print("addSubview is not empty")
                }
                self.blurEffectView.isHidden = false
            } else {
                self.blurEffectView.isHidden = true
            }
        }
    }
}
