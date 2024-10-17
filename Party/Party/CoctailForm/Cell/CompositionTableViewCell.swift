//
//  CompositionTableViewCell.swift
//  Party
//
//  Created by Karen Khachatryan on 17.10.24.
//

import UIKit

class CompositionTableViewCell: UITableViewCell {

    @IBOutlet weak var nameTextField: PaddingTextField!
    @IBOutlet weak var valueTextField: PaddingTextField!
    private var index = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        let textFields = [nameTextField, valueTextField]
        textFields.forEach { field in
            field?.layer.cornerRadius = 11.5
            field?.layer.borderWidth = 1.5
            field?.layer.borderColor = UIColor.baseDark.cgColor
            field?.delegate = self
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        index = 0
    }
    
    func setupData(composition: CompositionModel?, index: Int) {
        self.index = index
        self.nameTextField.text = composition?.name
        self.valueTextField.text = composition?.value
    }
}

extension CompositionTableViewCell: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        switch textField {
        case nameTextField:
            CoctailFormViewModel.shared.coctail.compositions?[index].name = textField.text
        case valueTextField:
            CoctailFormViewModel.shared.coctail.compositions?[index].value = textField.text
        default:
            break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.endEditing(true)
    }
}
