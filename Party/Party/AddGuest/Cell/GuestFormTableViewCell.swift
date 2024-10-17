//
//  GuestFormTableViewCell.swift
//  Party
//
//  Created by Karen Khachatryan on 16.10.24.
//

import UIKit
import PhotosUI

protocol GuestFormTableViewCellDelegate: AnyObject {
    func saveGuest()
    func choosePhoto()
}

class GuestFormTableViewCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: EmailTextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var saveButton: BaseButton!
    @IBOutlet weak var emailErrorLabel: UILabel!
    weak var delegate: GuestFormTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        nameTextField.attributedPlaceholder = NSAttributedString(string: "Enter a name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.montserratExtraBold(size: 21) as Any])
        nameTextField.font = .montserratExtraBold(size: 21)
        phoneNumberTextField.attributedPlaceholder = NSAttributedString(string: "Enter the phone number", attributes: [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.349132359, green: 0.3637986183, blue: 0.4161400795, alpha: 1), NSAttributedString.Key.font: UIFont.montserratMedium(size: 13) as Any])
        phoneNumberTextField.font = .montserratMedium(size: 13)
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Enter email", attributes: [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.349132359, green: 0.3637986183, blue: 0.4161400795, alpha: 1), NSAttributedString.Key.font: UIFont.montserratMedium(size: 13) as Any])
        emailTextField.font = .montserratMedium(size: 13)
        emailErrorLabel.font = .montserratExtraBold(size: 8)
        saveButton.titleLabel?.font = .montserratExtraBold(size: 8.5)
        bgView.layer.cornerRadius = 16
        bgView.layer.borderWidth = 2
        bgView.layer.borderColor = UIColor.black.cgColor
        photoButton.layer.cornerRadius = 30
        photoButton.layer.borderWidth = 2
        photoButton.layer.borderColor = UIColor.black.cgColor
        photoButton.layer.masksToBounds = true
        photoButton.imageView?.contentMode = .scaleAspectFill
        nameTextField.delegate = self
        emailTextField.delegate = self
        phoneNumberTextField.delegate = self
        saveButton.isEnabled = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endEditing(true)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    override func prepareForReuse() {
        photoButton.setImage(nil, for: .normal)
        nameTextField.text = nil
        emailTextField.text = nil
        phoneNumberTextField.text = nil
    }
    
    func setupPhoto(image: UIImage?) {
        self.photoButton.setImage(image, for: .normal)
    }
    
    @IBAction func choosePhoto(_ sender: UIButton) {
        delegate?.choosePhoto()
    }
    
    @IBAction func clickedSave(_ sender: BaseButton) {
        if !emailTextField.text.isValidEmail() {
            emailErrorLabel.isHidden = false
            return
        }
        emailErrorLabel.isHidden = true
        delegate?.saveGuest()
    }
    
}

extension GuestFormTableViewCell: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        switch textField {
        case nameTextField:
            AddGuestViewModel.shared.guest?.name = textField.text
        case emailTextField:
            AddGuestViewModel.shared.guest?.email = textField.text
        case phoneNumberTextField:
            AddGuestViewModel.shared.guest?.phone = textField.text
        default:
            break
        }
        saveButton.isEnabled = (nameTextField.text.checkValidation() && emailTextField.text.checkValidation() && phoneNumberTextField.text.checkValidation())
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == emailTextField {
            emailErrorLabel.isHidden = emailTextField.text.isValidEmail()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.endEditing(true)
    }
}
