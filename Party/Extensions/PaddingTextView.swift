//
//  PaddingTextView.swift
//  Party
//
//  Created by Karen Khachatryan on 17.10.24.
//

import UIKit

class PaddingTextView: UITextView {
    private var customPadding = UIEdgeInsets(top: 8, left: 8, bottom: 4, right: 8)
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textContainerInset = customPadding
    }
}
