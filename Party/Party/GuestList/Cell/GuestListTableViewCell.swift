//
//  GuestListTableViewCell.swift
//  Party
//
//  Created by Karen Khachatryan on 16.10.24.
//

import UIKit

protocol GuestListTableViewCellDelegate: AnyObject {
    func confirmationGuest(guest: GuestModel)
}

class GuestListTableViewCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var confirmedButton: UIButton!
    @IBOutlet weak var guestImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    private var guest: GuestModel?
    weak var delegate: GuestListTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        nameLabel.font = .montserratExtraBold(size: 21)
        phoneLabel.font = .montserratMedium(size: 13)
        confirmedButton.titleLabel?.font = .montserratExtraBold(size: 12)
        bgView.layer.cornerRadius = 16
        bgView.layer.borderWidth = 2
        bgView.layer.borderColor = UIColor.black.cgColor
        guestImageView.layer.cornerRadius = 30
        guestImageView.layer.borderWidth = 2
        guestImageView.layer.borderColor = UIColor.black.cgColor
        guestImageView.layer.masksToBounds = true
        guestImageView.contentMode = .scaleAspectFill
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    override func prepareForReuse() {
        guestImageView.image = nil
        guest = nil
    }
    
    func setupData(guest: GuestModel) {
        self.guest = guest
        if let data = guest.photo {
            guestImageView.image = UIImage(data: data)
        }
        nameLabel.text = guest.name
        phoneLabel.text = guest.phone
        confirmedButton.isEnabled = !guest.isConfirmed
        confirmedButton.backgroundColor = guest.isConfirmed ? .clear : .baseOrange
    }
    
    @IBAction func clickedConfirmed(_ sender: UIButton) {
        guard let guest = guest else { return }
        delegate?.confirmationGuest(guest: guest)
    }
}
