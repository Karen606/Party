//
//  ViewController.swift
//  Party
//
//  Created by Karen Khachatryan on 15.10.24.
//

import UIKit

class MenuViewController: UIViewController {

    @IBOutlet var sectionsView: [UIView]!
    @IBOutlet var sectionsButton: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionsButton.forEach({ $0.titleLabel?.font = .montserratExtraBold(size: 21) })
    }


}

