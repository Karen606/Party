//
//  AddGuestViewController.swift
//  Party
//
//  Created by Karen Khachatryan on 16.10.24.
//

import UIKit
import Combine
import PhotosUI
import MessageUI

class AddGuestViewController: UIViewController {

    @IBOutlet weak var guestsTableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var searchTextField: PaddingTextField!
    private var partyView: PartyView?
    
    private let viewModel = AddGuestViewModel.shared
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        subscribe()
        viewModel.fetchData()
    }
    
    func setupUI() {
        setNavigationBar(title: "Add guest", setButtons: false)
        setNaviagtionMenuButton()
        nameLabel.font = .montserratExtraBold(size: 22)
        locationLabel.font = .montserratMedium(size: 15)
        dateLabel.font = .montserratExtraBold(size: 44)
        nameLabel.text = viewModel.party?.name
        locationLabel.text = viewModel.party?.location
        dateLabel.text = viewModel.party?.date?.toString(format: "dd/MM")
        searchTextField.font = .montserratMedium(size: 21)
        searchTextField.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [NSAttributedString.Key.foregroundColor: UIColor.baseDark, NSAttributedString.Key.font: UIFont.montserratMedium(size: 21) as Any])
        searchTextField.setupRightViewIcon(UIImage.search, size: CGSize(width: 66, height: 60))
        searchTextField.delegate = self
        guestsTableView.delegate = self
        guestsTableView.dataSource = self
        guestsTableView.register(UINib(nibName: "AddGuestTableViewCell", bundle: nil), forCellReuseIdentifier: "AddGuestTableViewCell")
        guestsTableView.register(UINib(nibName: "GuestFormTableViewCell", bundle: nil), forCellReuseIdentifier: "GuestFormTableViewCell")
        registerKeyboardNotifications()
    }
    
    func subscribe() {
        viewModel.$guests
            .receive(on: DispatchQueue.main)
            .sink { [weak self] guests in
                guard let self = self else { return }
                self.guestsTableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    @objc func addGuest() {
        viewModel.addGuest()
        guestsTableView.reloadData()
    }
    
    func removeSelectedGuest() {
        partyView?.removeFromSuperview()
        partyView = nil
        viewModel.selectedGuest = nil
    }
    
    func sendEmail(withView view: UIView, to recipient: String) {
        guard MFMailComposeViewController.canSendMail() else {
            let alert = UIAlertController(title: "Error", message: "Mail services are not available", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            removeSelectedGuest()
            return
        }
        guard let image = view.toImage(), let imageData = image.jpegData(compressionQuality: 1.0) else {
            let alert = UIAlertController(title: "Error", message: "Unable to convert view to image", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            removeSelectedGuest()
            return
        }
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self
        mailComposeVC.setToRecipients([recipient])
        mailComposeVC.setSubject(viewModel.party?.theme ?? "")
        mailComposeVC.setMessageBody("", isHTML: false)
        mailComposeVC.addAttachmentData(imageData, mimeType: "image/jpeg", fileName: "view.jpg")
        present(mailComposeVC, animated: true, completion: nil)
    }
    
    func sendMMS(withView view: UIView, to recipient: String) {
        guard MFMessageComposeViewController.canSendText() else {
            let alert = UIAlertController(title: "Error", message: "SMS services are not available", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            removeSelectedGuest()
            return
        }
        
        guard MFMessageComposeViewController.canSendAttachments() else {
            let alert = UIAlertController(title: "Error", message: "MMS services are not available", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            removeSelectedGuest()
            present(alert, animated: true, completion: nil)
            return
        }
        guard let image = view.toImage(), let imageData = image.jpegData(compressionQuality: 1.0) else {
            let alert = UIAlertController(title: "Error", message: "Unable to convert view to image", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            removeSelectedGuest()
            return
        }
        let messageComposeVC = MFMessageComposeViewController()
        messageComposeVC.messageComposeDelegate = self
        messageComposeVC.recipients = [recipient]
        messageComposeVC.body = viewModel.party?.theme
        messageComposeVC.addAttachmentData(imageData, typeIdentifier: "public.data", filename: "view.jpg")
        present(messageComposeVC, animated: true, completion: nil)
    }
    
    deinit {
        viewModel.clear()
    }
}

extension AddGuestViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.guest == nil ? viewModel.guests.count : viewModel.guests.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewModel.guest != nil && indexPath.row == viewModel.guests.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GuestFormTableViewCell", for: indexPath) as! GuestFormTableViewCell
            cell.delegate = self
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddGuestTableViewCell", for: indexPath) as! AddGuestTableViewCell
        cell.setupData(guest: viewModel.guests[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if viewModel.guest != nil { return nil }
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 60))
        let addRoomButton = UIButton(type: .custom)
        addRoomButton.setImage(UIImage.customAdd, for: .normal)
        addRoomButton.addTarget(self, action: #selector(addGuest), for: .touchUpInside)
        addRoomButton.frame = CGRect(x: (footerView.frame.width - 60) / 2, y: 0, width: 60, height: 60)
        footerView.addSubview(addRoomButton)
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return viewModel.guest == nil ? 60 : 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

extension AddGuestViewController: GuestFormTableViewCellDelegate {
    func choosePhoto() {
        let actionSheet = UIAlertController(title: "Select Image", message: "Choose a source", preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
                self.requestCameraAccess()
            }))
        }
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
            self.requestPhotoLibraryAccess()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        present(actionSheet, animated: true, completion: nil)
    }
    
    func saveGuest() {
        viewModel.save { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.showErrorAlert(message: error.localizedDescription)
            } else {
                self.viewModel.fetchData()
            }
        }
    }
}

extension AddGuestViewController: AddGuestTableViewCellDelegate {
    func sendMessage(cell: UITableViewCell, guest: GuestModel) {
        if partyView != nil {
            removeSelectedGuest()
            return
        }
        partyView = PartyView.instanceFromNib()
        guard let partyModel = viewModel.party, let partyView = partyView else { return }
        let rect = guestsTableView.convert(cell.frame, to: self.view)
        partyView.frame.size.width = self.view.frame.width - 66
        partyView.frame.origin = CGPoint(x: 33, y: rect.minY + 77)
        partyView.commonInit(party: partyModel, guest: guest, sendType: .phone)
        partyView.delegate = self
        self.view.addSubview(partyView)
        NSLayoutConstraint.activate([
            partyView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 33),
            partyView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -33),
            partyView.topAnchor.constraint(lessThanOrEqualTo: self.view.topAnchor, constant: rect.minY + 77),
            partyView.bottomAnchor.constraint(lessThanOrEqualTo: self.view.bottomAnchor, constant: -24)
        ])
    }
    
    func sendEmail(cell: UITableViewCell, guest: GuestModel) {
        if partyView != nil {
            removeSelectedGuest()
            return
        }
        partyView = PartyView.instanceFromNib()
        guard let partyModel = viewModel.party, let partyView = partyView else { return }
        let rect = guestsTableView.convert(cell.frame, to: self.view)
        partyView.frame.size.width = self.view.frame.width - 66
        partyView.frame.origin = CGPoint(x: 33, y: rect.minY + 77)
        partyView.commonInit(party: partyModel, guest: guest, sendType: .email)
        partyView.delegate = self
        self.view.addSubview(partyView)
        NSLayoutConstraint.activate([
            partyView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 33),
            partyView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -33),
            partyView.topAnchor.constraint(lessThanOrEqualTo: self.view.topAnchor, constant: rect.minY + 77),
            partyView.bottomAnchor.constraint(lessThanOrEqualTo: self.view.bottomAnchor, constant: -24)
        ])
    }
}

extension AddGuestViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private func requestCameraAccess() {
        let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch cameraStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.openCamera()
                }
            }
        case .authorized:
            openCamera()
        case .denied, .restricted:
            showSettingsAlert()
        @unknown default:
            break
        }
    }
    
    private func requestPhotoLibraryAccess() {
        let photoStatus = PHPhotoLibrary.authorizationStatus()
        switch photoStatus {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    self.openPhotoLibrary()
                }
            }
        case .authorized:
            openPhotoLibrary()
        case .denied, .restricted:
            showSettingsAlert()
        case .limited:
            break
        @unknown default:
            break
        }
    }
    
    private func openCamera() {
        DispatchQueue.main.async {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
    }
    
    private func openPhotoLibrary() {
        DispatchQueue.main.async {
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
    }
    
    private func showSettingsAlert() {
        let alert = UIAlertController(title: "Access Needed", message: "Please allow access in Settings", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var image: UIImage?
        if let editedImage = info[.editedImage] as? UIImage {
            image = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            image = originalImage
        }
        if let imageData = image?.jpegData(compressionQuality: 1.0) {
            let data = imageData as Data
            viewModel.guest?.photo = data
            if let cell = guestsTableView.cellForRow(at: IndexPath(row: viewModel.guests.count, section: 0)) as? GuestFormTableViewCell {
                cell.setupPhoto(image: image)
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension AddGuestViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        viewModel.search(by: textField.text)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
    }
}

extension AddGuestViewController {
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(AddGuestViewController.keyboardNotification(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
            let animationCurve: UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                guestsTableView.contentInset = .zero
            } else {
                let height: CGFloat = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)!.size.height
                guestsTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: height, right: 0)
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
}

extension AddGuestViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        switch result {
        case .cancelled:
            removeSelectedGuest()
        case .saved:
            removeSelectedGuest()
        case .sent:
            viewModel.addGuestToParty()
            removeSelectedGuest()
        case .failed:
            removeSelectedGuest()
            self.showErrorAlert(message: "Mail sent failure: \(String(describing: error?.localizedDescription))")
        @unknown default:
            removeSelectedGuest()
            break
        }
    }
}

extension AddGuestViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
        switch result {
        case .cancelled:
            removeSelectedGuest()
        case .sent:
            viewModel.addGuestToParty()
            removeSelectedGuest()
        case .failed:
            removeSelectedGuest()
            self.showErrorAlert(message: "MMS failed")
        @unknown default:
            removeSelectedGuest()
            break
        }
    }
}

extension AddGuestViewController: PartyViewDelegate {
    func close() {
        removeSelectedGuest()
    }
    
    func sendEmail(to guest: GuestModel) {
        guard let partyView = partyView else { return }
        viewModel.selectedGuest = guest
        partyView.closeButton.isHidden = true
        partyView.sendButton.isHidden = true
        sendEmail(withView: partyView.bgView, to: guest.email ?? "")
    }
    
    func sendMessage(to guest: GuestModel) {
        guard let partyView = partyView else { return }
        viewModel.selectedGuest = guest
        partyView.closeButton.isHidden = true
        partyView.sendButton.isHidden = true
        sendMMS(withView: partyView.bgView, to: guest.phone ?? "")
    }
}
