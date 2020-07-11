//
//  CanvasView.swift
//  Canvas
//
//  Created by Hisashi Ishihara on 2020/07/08.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit

class CanvasView: UIView {

    // オフスクリーン保持用のプロパティ
    private var canvas:UIImage?
    
    // 画面表示用オフスクリーンへの描画
    override func draw(_ rect: CGRect) {
        // オフスクリーンが無効なら、画像を作成しオフスクリーンへ割り当てる
        if self.canvas == nil {
            self.canvas = self.canvasImage()
        }
        // ①画像を描画
        self.canvas?.draw(in: self.bounds)
        
        // ②スケーリングさせないUIImageの描画
//        self.canvas?.draw(at: CoreGraphics.CGPoint(x: 0, y: 0)) // 指定座標を左上にした等倍画像を描く
        /* 正方形のオフスクリーンを作成
          UIGraphicsBeginImageContext(CGSize(width: 20, height: 20))
          20*20の正方形　を作成したのでオフスクリーン上にちいさな正方形が表示されることになる。
        */
    }
 
    // オフスクリーン画像を作成
    func canvasImage() -> UIImage! {
        // ①正方形のオフスクリーンを作成
//        UIGraphicsBeginImageContext(CGSize(width: 20, height: 20))
        // ②CanvasView全体のオフスクリーンを作成
        UIGraphicsBeginImageContext(self.bounds.size)
        
        // ①色を赤色に塗る
//        UIColor.red.setFill()
//        UIRectFill(CGRect(x: 5, y: 5, width: 10, height: 10))
        // ②赤い円を描く
        UIColor.red.setFill()
        let context = UIGraphicsGetCurrentContext() // 設定されているCGContextを取り出す
        context!.fillEllipse(in: self.bounds) // 枠いっぱいの円で塗りつぶす
        
        // オフスクリーンを画像として取り出す
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

}
