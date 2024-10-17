//
//  PartyTableViewCell.swift
//  Party
//
//  Created by Karen Khachatryan on 15.10.24.
//

import UIKit

class PartyTableViewCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.font = .montserratBold(size: 36)
        locationLabel.font = .montserratExtraBold(size: 13)
        dateLabel.font = .montserratBold(size: 13)
        self.backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setupData(party: PartyModel) {
        locationLabel.text = party.location
        nameLabel.text = party.name
        dateLabel.text = party.date?.toString(format: "dd MMMM, yyyy h:mm a")
        bgView.backgroundColor = PartiesViewModel.shared.type == .upcoming ? .baseOrange : #colorLiteral(red: 1, green: 0.7137254902, blue: 0.5058823529, alpha: 1)
    }
    
}
