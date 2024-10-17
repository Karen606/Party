//
//  CoctailFormViewController.swift
//  Party
//
//  Created by Karen Khachatryan on 17.10.24.
//

import UIKit
import Combine
import PhotosUI

class CoctailFormViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var nameTextField: PaddingTextField!
    @IBOutlet weak var compositionsTableView: UITableView!
    @IBOutlet weak var descriptionTextView: PaddingTextView!
    @IBOutlet weak var saveButton: BaseButton!
    @IBOutlet weak var tableViewHeightConst: NSLayoutConstraint!
    @IBOutlet var titleLabels: [UILabel]!
    private let viewModel = CoctailFormViewModel.shared
    private var cancellables: Set<AnyCancellable> = []
    var completion: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        subscribe()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            if let newSize = change?[.newKey] as? CGSize {
                updateTableViewHeight(newSize: newSize)
            }
        }
    }
    
    func setupUI() {
        setNavigationBar(title: "Create a cocktail")
        registerKeyboardNotifications()
        compositionsTableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        photoButton.layer.cornerRadius = 16
        photoButton.layer.borderWidth = 2
        photoButton.layer.borderColor = UIColor.baseDark.cgColor
        photoButton.layer.masksToBounds = true
        photoButton.imageView?.contentMode = .scaleAspectFill
        nameTextField.layer.cornerRadius = 11.5
        nameTextField.layer.borderColor = UIColor.baseDark.cgColor
        nameTextField.layer.borderWidth = 1.5
        nameTextField.font = .montserratSemiBold(size: 13)
        nameTextField.delegate  = self
        titleLabels.forEach({ $0.font = .montserratRegular(size: 12) })
        descriptionTextView.font = .montserratSemiBold(size: 13)
        descriptionTextView.layer.cornerRadius = 16
        descriptionTextView.layer.borderWidth = 2
        descriptionTextView.layer.borderColor = UIColor.baseDark.cgColor
        descriptionTextView.delegate = self
        saveButton.titleLabel?.font = .montserratExtraBold(size: 21)
        compositionsTableView.delegate = self
        compositionsTableView.dataSource = self
        compositionsTableView.register(UINib(nibName: "CompositionTableViewCell", bundle: nil), forCellReuseIdentifier: "CompositionTableViewCell")
    }
    
    private func updateTableViewHeight(newSize: CGSize) {
        tableViewHeightConst.constant = newSize.height
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func subscribe() {
        viewModel.$coctail
            .receive(on: DispatchQueue.main)
            .sink { [weak self] coctail in
                guard let self = self else { return }
                if let data = coctail.photo {
                    self.photoButton.setImage(UIImage(data: data), for: .normal)
                } else {
                    self.photoButton.setImage(UIImage.imagePlaceholder, for: .normal)
                }
                self.nameTextField.text = coctail.name
                self.descriptionTextView.text = coctail.descriptionPreparation
                self.saveButton.isEnabled = (coctail.name.checkValidation() && coctail.descriptionPreparation.checkValidation() && coctail.photo != nil) && !((coctail.compositions ?? []).contains(where: { $0.name.checkValidation() != $0.value.checkValidation() }))
                if (coctail.compositions?.count ?? 0) != viewModel.previousCompositionsCount {
                    self.compositionsTableView.reloadData()
                    viewModel.previousCompositionsCount = coctail.compositions?.count ?? 0
                }
            }
            .store(in: &cancellables)
    }
    
    @IBAction func handleTapGesture(_ sender: UITapGestureRecognizer) {
        handleTap()
    }
    
    @objc func addComposition() {
        viewModel.addComposition()
    }

    @IBAction func choosePhoto(_ sender: UIButton) {
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
    
    @IBAction func clickedSave(_ sender: Any) {
        viewModel.save { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.showErrorAlert(message: error.localizedDescription)
            } else {
                self.completion?()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    deinit {
        viewModel.clear()
    }
}

extension CoctailFormViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.coctail.compositions?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CompositionTableViewCell", for: indexPath) as! CompositionTableViewCell
        cell.setupData(composition: viewModel.coctail.compositions?[indexPath.row], index: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))
        let addCompositionButton = UIButton(type: .custom)
        addCompositionButton.setImage(UIImage.smallAdd, for: .normal)
        addCompositionButton.addTarget(self, action: #selector(addComposition), for: .touchUpInside)
        addCompositionButton.frame = CGRect(x: 33, y: 12, width: 25, height: 25)
        footerView.addSubview(addCompositionButton)
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        40
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

extension CoctailFormViewController: UITextFieldDelegate, UITextViewDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        viewModel.coctail.name = textField.text
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        viewModel.coctail.descriptionPreparation = textView.text
    }
}

extension CoctailFormViewController {
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(CoctailFormViewController.keyboardNotification(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
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

extension CoctailFormViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
            if let editedImage = info[.editedImage] as? UIImage {
                photoButton.setImage(editedImage, for: .normal)
            } else if let originalImage = info[.originalImage] as? UIImage {
                photoButton.setImage(originalImage, for: .normal)
            }
            if let imageData = photoButton.imageView?.image?.jpegData(compressionQuality: 1.0) {
                let data = imageData
                viewModel.coctail.photo = data
            }
            picker.dismiss(animated: true, completion: nil)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }
}
