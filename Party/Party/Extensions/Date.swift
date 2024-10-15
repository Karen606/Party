//
//  Date.swift
//  Party
//
//  Created by Karen Khachatryan on 15.10.24.
//

import Foundation

extension Date {
    func toString(format: String = "dd/MM/yyyy") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
