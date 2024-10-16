//
//  CategoryListCarouselAndPageViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2021/05/19.
//  Copyright © 2021 Hisashi Ishihara. All rights reserved.
//

import UIKit

class CategoryListCarouselAndPageViewController: CarouselAndPageViewController {

    // MARK: - Variable/Let
    
    @IBOutlet private var addBarButtonItem: UIBarButtonItem!
    
    // MARK: - LifeCycle

    override func viewDidLoad() {
        // タブに表示する文言
        pageTabItems = Rank0.allCases.map({ $0.rawValue })
        super.viewDidLoad()
        
        // 編集ボタンの設定
        navigationItem.rightBarButtonItem = editButtonItem
    }
    
    // MARK: - Action

    // カルーセルのタブをタップされたときに中央のビューをスクロールさせる
    override func selectTab(_ index: Int) {
        // 選択されたタブのViewControllerをセットする
        if let viewController = UIStoryboard(name: "CategoryListTableViewController", bundle: nil).instantiateInitialViewController() as? CategoryListTableViewController {
            viewController.index = index
            pageViewController.setViewControllers([viewController], direction: .forward, animated: false, completion: nil)
            // セルを選択して、collectionViewの中の中心にスクロールさせる　追随　追従
            self.carouselCollectionView.selectItem(at: IndexPath(row: selectedIndex, section: 0), animated: true, scrollPosition: .centeredHorizontally)
            // 編集モードを切り替える
            viewController.setEditing(isEditing, animated: false)
        }
    }
    // 画面遷移の準備　勘定科目画面
    @IBAction func addBarButtonItemTapped(_ sender: Any) {
        DispatchQueue.main.async {
            if let viewController = UIStoryboard(
                name: String(describing: SettingsCategoryDetailTableViewController.self),
                bundle: nil
            ).instantiateInitialViewController() as? SettingsCategoryDetailTableViewController {
                // 遷移先のコントローラに値を渡す
                viewController.addAccount = true // セルに表示した勘定科目の連番を取得
                // ナビゲーションバーを表示させる
                let navigation = UINavigationController(rootViewController: viewController)
                self.present(navigation, animated: true, completion: nil)
            }
        }
    }
    
    // 編集モード切り替え
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        // 編集モードを切り替える
        if let currentVC = pageViewController.viewControllers?.first as? CategoryListTableViewController {
            currentVC.setEditing(editing, animated: true)
        }
    }
    
    // MARK: - UIPageViewControllerDelegate
    // MARK: - UIPageViewControllerDataSource
    
    // 右にスワイプ　戻り値のViewControllerが表示され、nilならそれ以上進まない
    override func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        // 遷移先のViewControllerを生成
        guard let beforeViewController = UIStoryboard(name: "CategoryListTableViewController", bundle: nil).instantiateInitialViewController() as? CategoryListTableViewController else { return nil }
        if let viewController = viewController as? CategoryListTableViewController {
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
    override func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let afterViewController = UIStoryboard(name: "CategoryListTableViewController", bundle: nil).instantiateInitialViewController() as? CategoryListTableViewController else { return nil }
        if let viewController = viewController as? CategoryListTableViewController {
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
    
    override func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        // viewControllerBefore と viewControllerAfter　は2回処理が走ってインデックスがずれるので、アニメーション完了後にインデックスを取得
        if let currentVC = pageViewController.viewControllers?.first as? CategoryListTableViewController {
            let currentIndex = currentVC.index
            selectedIndex = currentIndex
            // タブの選択位置を更新する
            // セルを選択して、コレクションビューの中の中心へスクロールさせる
            self.carouselCollectionView.selectItem(at: IndexPath(row: selectedIndex, section: 0), animated: true, scrollPosition: .centeredHorizontally)
            // 編集モードを切り替える
            currentVC.setEditing(isEditing, animated: false)
        }
    }
    
}
