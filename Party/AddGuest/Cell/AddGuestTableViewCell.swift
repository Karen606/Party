//
//  AddGuestTableViewCell.swift
//  Party
//
//  Created by Karen Khachatryan on 17.10.24.
//

import UIKit

protocol AddGuestTableViewCellDelegate: AnyObject {
    func sendMessage(cell: UITableViewCell, guest: GuestModel)
    func sendEmail(cell: UITableViewCell, guest: GuestModel)
}

class AddGuestTableViewCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var guestImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    weak var delegate: AddGuestTableViewCellDelegate?
    private var guest: GuestModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        bgView.layer.cornerRadius = 16
        bgView.layer.borderWidth = 2
        bgView.layer.borderColor = UIColor.black.cgColor
        guestImageView.layer.cornerRadius = 30
        guestImageView.layer.borderWidth = 2
        guestImageView.layer.borderColor = UIColor.black.cgColor
        guestImageView.layer.masksToBounds = true
        guestImageView.contentMode = .scaleAspectFill
        phoneNumberLabel.font = .montserratMedium(size: 13)
        emailLabel.font = .montserratMedium(size: 13)
        nameLabel.font = .montserratExtraBold(size: 21)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    override func prepareForReuse() {
        guestImageView.image = nil
        guest = nil
    }
    
    func setupData(guest: GuestModel) {
        if let data = guest.photo {
            guestImageView.image = UIImage(data: data)
        }
        nameLabel.text = guest.name
        phoneNumberLabel.text = guest.phone
        emailLabel.text = guest.email
        self.guest = guest
    }
    
    @IBAction func clickedSengMessage(_ sender: UIButton) {
        guard let guest = guest else { return }
        delegate?.sendMessage(cell: self, guest: guest)
    }
    
    @IBAction func clickedSendEmail(_ sender: UIButton) {
        guard let guest = guest else { return }
        delegate?.sendEmail(cell: self, guest: guest)
    }
}
