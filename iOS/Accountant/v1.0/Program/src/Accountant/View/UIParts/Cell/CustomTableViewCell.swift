//
//  CustomTableViewCell.swift
//  CollectionInTableApp
//
//  Created by Hisashi Ishihara on 2023/07/16.
//

import UIKit

protocol CustomCollectionViewCellDelegate: AnyObject {
    func showDetail(cell: ListCollectionViewCell)
}

class CustomTableViewCell: UITableViewCell {

    var delegate: CustomCollectionViewCellDelegate?

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // setup
        createList()
        // Long tap
        setupRecognizer()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 画面の回転に合わせてCellのサイズを変更する
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.reloadData()
    }
    
    // MARK: - Create View
    
    // setup
    func createList() {
        // xib読み込み
        let nib = UINib(nibName: "ListCollectionViewCell", bundle: .main)
        collectionView.register(nib, forCellWithReuseIdentifier: "cell")
    }
    
    func configure(gropName: String) {
        titleLabel.text = gropName
    }
    
    func setupRecognizer() {
        // 更新機能　編集機能
        // UILongPressGestureRecognizer宣言
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(cellLongPressed))// 正解: Selector("somefunctionWithSender:forEvent: ") → うまくできなかった。2020/07/26
        // `UIGestureRecognizerDelegate`を設定するのをお忘れなく
        longPressRecognizer.delegate = self
        // CollectionViewにrecognizerを設定
        collectionView.addGestureRecognizer(longPressRecognizer)
    }
    // 編集機能　長押しした際に呼ばれるメソッド
    @objc
    func cellLongPressed(recognizer: UILongPressGestureRecognizer) {
        // 押された位置でcellのPathを取得
        let point = recognizer.location(in: collectionView)
        let indexPath = collectionView.indexPathForItem(at: point)
        if indexPath?.section == 1 {
            print("空白行を長押し")
        } else {
            if let indexPath = indexPath {
                if recognizer.state == UIGestureRecognizer.State.began {
                    // 長押しされた場合の処理
                    print("長押しされたcellのindexPath:\(String(describing: indexPath.row))")
                    // collectionViewCoellのindexPathを特定する
                    guard let cell = collectionView.cellForItem(at: indexPath) as? ListCollectionViewCell else {
                        return
                    }
                    delegate?.showDetail(cell: cell)
                }
            }
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        // Add wobble animation to each collection view cell
        collectionView.indexPathsForVisibleItems.forEach { indexPath in
            if let cell = self.collectionView.cellForItem(at: indexPath) as? ListCollectionViewCell {
                // マイクロインタラクション アニメーション　セル 編集中
                cell.animateViewWobble(isActive: editing)
            }
        }
    }
}
