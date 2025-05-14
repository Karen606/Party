//
//  PartyView.swift
//  Party
//
//  Created by Karen Khachatryan on 17.10.24.
//

import UIKit

protocol PartyViewDelegate: AnyObject {
    func sendEmail(to guest: GuestModel)
    func sendMessage(to guest: GuestModel)
    func close()
}

class PartyView: UIView {

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var bgView: UIView!
    weak var delegate: PartyViewDelegate?
    private var sendType: SendType = .email
    private var guest: GuestModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func commonInit(party: PartyModel, guest: GuestModel, sendType: SendType) {
        self.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .montserratBold(size: 36)
        locationLabel.font = .montserratExtraBold(size: 13)
        dateLabel.font = .montserratBold(size: 13)
        locationLabel.text = party.location
        nameLabel.text = "\(party.name ?? "")\n\(party.theme ?? "")"
        nameLabel.sizeToFit()
        dateLabel.text = party.date?.toString(format: "dd MMMM, yyyy h:mm a")
        self.sendType = sendType
        self.guest = guest
    }
    
    class func instanceFromNib() -> PartyView {
        return UINib(nibName: "PartyView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! PartyView
    }

    @IBAction func clickedSendButton(_ sender: UIButton) {
        guard let guest = guest else { return }
        if sendType == .email {
            delegate?.sendEmail(to: guest)
        } else {
            delegate?.sendMessage(to: guest)
        }
    }
    
    @IBAction func clickedClose(_ sender: UIButton) {
        delegate?.close()
    }
}

enum SendType {
    case phone
    case email
}
