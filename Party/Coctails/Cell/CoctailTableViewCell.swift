//
//  CoctailTableViewCell.swift
//  Party
//
//  Created by Karen Khachatryan on 17.10.24.
//

import UIKit

class CoctailTableViewCell: UITableViewCell {

    @IBOutlet weak var coctailImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        nameLabel.font = .montserratBold(size: 21)
        descriptionLabel.font = .montserratExtraBold(size: 18)
        coctailImageView.layer.cornerRadius = 16
        coctailImageView.layer.borderColor = UIColor.black.cgColor
        coctailImageView.layer.borderWidth = 2
        coctailImageView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        coctailImageView.image = nil
    }
    
    func setupData(coctail: CoctailModel) {
        if let data = coctail.photo {
            coctailImageView.image = UIImage(data: data)
        }
        nameLabel.text = coctail.name
        descriptionLabel.text = coctail.descriptionPreparation
    }
    
}
