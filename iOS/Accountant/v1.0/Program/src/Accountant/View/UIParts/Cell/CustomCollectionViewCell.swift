//
//  CustomCollectionViewCell.swift
//  CollectionInTableApp
//
//  Created by Hisashi Ishihara on 2023/07/16.
//

import UIKit

protocol CustomCollectionViewCellDelegate: AnyObject {
    func showDetail(cell: CustomCollectionViewCell)
}

class CustomCollectionViewCell: UICollectionViewCell {
    
    weak var delegate: CustomCollectionViewCellDelegate?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageview: UIImageView!
    
    @IBAction func tappedButton(_ sender: Any) {
        delegate?.showDetail(cell: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    func getImageByUrl(url: String, completion: @escaping (UIImage) -> ()) {
        // URLから画像データを取得する処理は別スレッドで行う
        // Synchronous URL loading of 警告対策
        DispatchQueue.global(qos: .background).async {
            let url = URL(string: url)
            do {
                let data = try Data(contentsOf: url!)
                    if let image = UIImage(data: data) {
                        completion(image)
                    }
                
            } catch let err {
                print("Error : \(err.localizedDescription)")
            }
        }
    }
}
