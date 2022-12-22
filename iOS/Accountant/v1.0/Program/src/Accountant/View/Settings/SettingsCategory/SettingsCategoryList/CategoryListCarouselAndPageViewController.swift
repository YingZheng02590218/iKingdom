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
        pageTabItems = [
            "流動資産",
            "固定資産",
            "繰延資産",
            "流動負債",
            "固定負債",
            "資本",
            "売上",
            "売上原価",
            "販売費及び一般管理費",
            "営業外損益",
            "特別損益",
            "税金"
        ]
        super.viewDidLoad()
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
        }
    }
    // 画面遷移の準備　勘定科目画面
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // セグエで場合分け
        if segue.identifier == "segue_add_account"{ // 新規で設定勘定科目を追加する場合　addButtonを押下
            // segue.destinationの型はUIViewController
            if let tableViewControllerSettingsCategoryDetail = segue.destination as? SettingsCategoryDetailTableViewController {
                // 遷移先のコントローラに値を渡す
                tableViewControllerSettingsCategoryDetail.addAccount = true // セルに表示した勘定科目の連番を取得
            }
        }
    }

    @IBAction func editButtonTapped(_ sender: Any) {
        // 編集モードを切り替える
        if let currentVC = pageViewController.viewControllers?.first as? CategoryListTableViewController {
            currentVC.setEditing(!currentVC.isEditing, animated: true)
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

        }
    }
    
}
