//
//  GuestListTableViewCell.swift
//  Party
//
//  Created by Karen Khachatryan on 16.10.24.
//

import UIKit

class GuestListTableViewCell: UITableViewCell {

    @IBOutlet weak var confirmedButton: UIButton!
    @IBOutlet weak var guestImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.font = .montserratExtraBold(size: 21)
        phoneLabel.font = .montserratMedium(size: 13)
        confirmedButton.titleLabel?.font = .montserratExtraBold(size: 12)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    override func prepareForReuse() {
        guestImageView.image = nil
    }
    
    func setupData(guest: GuestModel) {
        if let data = guest.photo {
            guestImageView.image = UIImage(data: data)
        }
        nameLabel.text = guest.name
        phoneLabel.text = guest.phone
        confirmedButton.isEnabled = !guest.isConfirmed
        confirmedButton.backgroundColor = guest.isConfirmed ? .clear : .baseOrange
    }
    
    @IBAction func clickedConfirmed(_ sender: UIButton) {
    }
}
