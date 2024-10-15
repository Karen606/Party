//
//  CreatePartyViewController.swift
//  Party
//
//  Created by Karen Khachatryan on 15.10.24.
//

import UIKit
import Combine

class CreatePartyViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var titleLabels: [UILabel]!
    @IBOutlet weak var nameTextField: BaseTextField!
    @IBOutlet weak var locationTextField: BaseTextField!
    @IBOutlet weak var themeTextField: BaseTextField!
    @IBOutlet weak var dateTextField: BaseTextField!
    @IBOutlet var textFields: [BaseTextField]!
    @IBOutlet weak var saveButton: BaseButton!
    private let datePicker = UIDatePicker()
    private var containerView: UIView?
    private let viewModel = CreatePartyViewModel.shared
    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        subscribe()
    }
    
    func setupUI() {
        self.setNavigationBar(title: "Create a party")
        titleLabels.forEach({ $0.font = .montserratRegular(size: 14) })
        dateTextField.setupRightViewIcon(UIImage.bottomArrow)
        saveButton.titleLabel?.font = .montserratExtraBold(size: 21)
        textFields.forEach({ $0.delegate = self })
        datePicker.locale = NSLocale.current
        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        dateTextField.inputView = UIView()
        registerKeyboardNotifications()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showDatePicker))
        dateTextField.addGestureRecognizer(tapGesture)
    }
        
    @objc func showDatePicker() {
        if containerView != nil {
            containerView?.removeFromSuperview()
            containerView = nil
            return
        }
        containerView = UIView()
        guard let containerView = containerView else { return }
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .clear
        containerView.layer.cornerRadius = 10
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.3
        containerView.layer.shadowOffset = CGSize(width: 0, height: 3)
        containerView.layer.shadowRadius = 5
        
        containerView.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            datePicker.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            datePicker.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            datePicker.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10)
        ])
        view.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 33),
            containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -33),
            containerView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
        containerView.alpha = 0
        UIView.animate(withDuration: 0.3) {
            containerView.alpha = 1
        }
    }
    
    @objc func dateChanged() {
        viewModel.partyModel.date = datePicker.date
        dateTextField.text = datePicker.date.toString(format: "dd/MM/yyyy h:mma")
    }
    
    func subscribe() {
        viewModel.$partyModel
            .receive(on: DispatchQueue.main)
            .sink { [weak self] partyModel in
                guard let self = self else { return }
                self.saveButton.isEnabled = !(self.textFields.contains(where: { !$0.text.checkValidation() }))
            }
            .store(in: &cancellables)
    }
    
    @objc func datePickerValueChanged(sender: UIDatePicker) {
        dateTextField.text = sender.date.toString()
        viewModel.partyModel.date = sender.date
        self.view.endEditing(true)
    }
    
    @IBAction func handleTapGesture(_ sender: UITapGestureRecognizer) {
        self.handleTap()
        containerView?.removeFromSuperview()
        containerView = nil
    }
    
    @IBAction func clickedSave(_ sender: BaseButton) {
        viewModel.save { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.showErrorAlert(message: error.localizedDescription)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
}

extension CreatePartyViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        switch textField {
        case nameTextField:
            viewModel.partyModel.name = textField.text
        case locationTextField:
            viewModel.partyModel.location = textField.text
        case themeTextField:
            viewModel.partyModel.theme = textField.text
        default:
            break
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == dateTextField {
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
    }
}

extension CreatePartyViewController {
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(CreatePartyViewController.keyboardNotification(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
            let animationCurve: UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                scrollView.contentInset = .zero
            } else {
                let height: CGFloat = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)!.size.height
                scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: height, right: 0)
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
}

