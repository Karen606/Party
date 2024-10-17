//
//  SettingViewController.swift
//  Party
//
//  Created by Karen Khachatryan on 17.10.24.
//

import UIKit

class SettingViewController: UIViewController {

    @IBOutlet var sectionButtons: [UIButton]!
    override func viewDidLoad() {
        super.viewDidLoad()
        setNaviagtionBackButton(image: .closeBig)
        sectionButtons.forEach({ $0.titleLabel?.font = .montserratExtraBold(size: 36) })
    }
    
    @IBAction func clickedContactUs(_ sender: UIButton) {
    }
    
    @IBAction func clickedPrivacyPolicy(_ sender: UIButton) {
    }
    
    @IBAction func clickedRateUs(_ sender: UIButton) {
    }
}
