//
//  PageContentViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2021/05/16.
//  Copyright © 2021 Hisashi Ishihara. All rights reserved.
//

import UIKit

class PageContentViewController: UIViewController {

    // MARK: - Variable/Let

    @IBOutlet var collectionView: UICollectionView!
    var index: Int = 0 // カルーセルのタブの識別
    
    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // ビューを設定
        settingCollectionView()
    }
    
    // MARK: - Setting

    func settingCollectionView() {
        // デリゲート、データソース
        collectionView.delegate = self
        collectionView.dataSource = self
        // XIBの登録
        collectionView.register(UINib(nibName: "CarouselTabCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CarouselTabCollectionViewCell")
        // レイアウト
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical
//        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize // Labelの文言に合わせてセルの幅を変化させる
        collectionView.collectionViewLayout = layout
        // PageViewとCollectionViewを併用するとスクロールができなくなったので、CollectionViewスクロールを有効とする
        collectionView.isScrollEnabled = true
    }

}
extension PageContentViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 50
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CarouselTabCollectionViewCell", for: indexPath) as! CarouselTabCollectionViewCell
        cell.label.text = "\(index)"
        return cell
    }
    // セルが選択された時
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }
    // セルが選択解除されたとき
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
    }
    
}
