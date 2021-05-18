//
//  CarouselAndPageViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2021/05/16.
//  Copyright © 2021 Hisashi Ishihara. All rights reserved.
//

import UIKit

class CarouselAndPageViewController: UIViewController {

    // MARK: - Variable/Let

    @IBOutlet var carouselCollectionView: UICollectionView!
    var pageTabItems: [String] = [] // タブに表示する文言
    private var selectedIndex: Int = 0 // 選択されたカルーセルのタブのRow
    private var pageViewController: UIPageViewController { return self.children.compactMap { $0 as? UIPageViewController }.first! } // 中央のView
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // タブに表示する文言
        pageTabItems = ["流動資産","固定資産","繰延資産","流動負債","固定負債","資本","売上","売上原価","販売費及び一般管理費","営業外損益","特別損益","税金"]
        // ビューを設定
        settingCollectionView()
        settingPageView()
    }
    
    // MARK: - Setting

    func settingCollectionView() {
        // デリゲート、データソース
        carouselCollectionView.delegate = self
        carouselCollectionView.dataSource = self
        // XIBの登録
        carouselCollectionView.register(UINib(nibName: "CarouselTabCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CarouselTabCollectionViewCell")
        // レイアウト
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize // Labelの文言に合わせてセルの幅を変化させる
        carouselCollectionView.collectionViewLayout = layout
    }
    
    func settingPageView() {
        // デリゲート、データソース
        pageViewController.delegate = self
        pageViewController.dataSource = self
        // 最初に表示するViewControllerを指定する
        selectedIndex = 0
        // Storyboardから遷移先のViewControllerを生成
        selectTab(selectedIndex)
    }
    // カルーセルのタブをタップされたときに中央のビューをスクロールさせる
    func selectTab(_ index: Int) {
        // 選択されたタブのViewControllerをセットする
        let viewController = UIStoryboard(name: "PageContentViewController", bundle: nil).instantiateInitialViewController() as! PageContentViewController
        viewController.index = index
        pageViewController.setViewControllers([viewController], direction: .forward, animated: false, completion: nil)
        // セルを選択して、collectionViewの中の中心にスクロールさせる　追随　追従
        self.carouselCollectionView.selectItem(at: IndexPath(row: selectedIndex, section: 0), animated: true, scrollPosition: .centeredHorizontally)
    }
    
}
// カルーセル
extension CarouselAndPageViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pageTabItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CarouselTabCollectionViewCell", for: indexPath) as! CarouselTabCollectionViewCell
        cell.label.text = "\(pageTabItems[indexPath.row])"
        return cell
    }
    // セルが選択された時
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 次に帆ｙ時する ViewController を指定する
        selectedIndex = indexPath.row
        // 中央部のビューを差し替える
        selectTab(selectedIndex)
    }
    // セルが選択解除されたとき
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
    }
}
// カルーセル　セルのサイズ、位置
extension CarouselAndPageViewController: UICollectionViewDelegateFlowLayout {
    
    // セルのサイズ
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cell:CarouselTabCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CarouselTabCollectionViewCell", for: indexPath) as! CarouselTabCollectionViewCell
        print(cell.label.frame.width, collectionView.frame.height)
//        return CGSize(width: cell.label.frame.width, height: collectionView.frame.height)
        return CGSize(width: collectionView.frame.height * 2, height: collectionView.frame.height)
    }
    // セルを中央寄せにする
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout,
              let dataSourceCount = collectionView.dataSource?.collectionView(collectionView, numberOfItemsInSection: section),
              dataSourceCount > 0 else {
            return .zero
        }
        let cellCount = CGFloat(dataSourceCount)
        let itemSpacing = flowLayout.minimumLineSpacing
        let cellWidth = flowLayout.itemSize.width + itemSpacing
        let cellSpacing = flowLayout.minimumInteritemSpacing
        var insets = flowLayout.sectionInset
        
        let totalCellWidth = cellWidth * cellCount - itemSpacing
        let contentWidth = collectionView.frame.size.width - collectionView.contentInset.left - collectionView.contentInset.right

        guard totalCellWidth < contentWidth else {
            return insets
        }
        let padding = (contentWidth - totalCellWidth) / 2.0
        insets.left = padding
        insets.right = padding
//        return insets

//        let inset = (collectionView.bounds.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
//        return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
}
// 中央のビュー
extension CarouselAndPageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    // 右にスワイプ　戻り値のViewControllerが表示され、nilならそれ以上進まない
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        // 遷移先のViewControllerを生成
        let beforeViewController = UIStoryboard(name: "PageContentViewController", bundle: nil).instantiateInitialViewController() as! PageContentViewController
        if let viewController = viewController as? PageContentViewController {
            let beforeIndex: Int = viewController.index - 1
            if beforeIndex < 0 {
                // これ以上戻らない
                return nil
            }
            beforeViewController.index = beforeIndex
        }
        return beforeViewController
    }
    // 左にスワイプ　戻り値のViewControllerが表示され、nilならそれ以上進まない
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let afterViewController = UIStoryboard(name: "PageContentViewController", bundle: nil).instantiateInitialViewController() as! PageContentViewController
        if let viewController = viewController as? PageContentViewController {
            let afterIndex: Int = viewController.index + 1
            let maxCount = pageTabItems.count
            if afterIndex >= maxCount {
                // これ以上戻らない
                return nil
            }
            afterViewController.index = afterIndex
        }
        return afterViewController
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        // viewControllerBefore と viewControllerAfter　は2回処理が走ってインデックスがずれるので、アニメーション完了後にインデックスを取得
        if let currentVC = pageViewController.viewControllers?.first as? PageContentViewController {
            let currentIndex = currentVC.index
            selectedIndex = currentIndex
            // タブの選択位置を更新する
            // セルを選択して、コレクションビューの中の中心へスクロールさせる
            self.carouselCollectionView.selectItem(at: IndexPath(row: selectedIndex, section: 0), animated: true, scrollPosition: .centeredHorizontally)

        }
    }
}
