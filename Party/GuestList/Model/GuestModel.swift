//
//  GuestModel.swift
//  Party
//
//  Created by Karen Khachatryan on 16.10.24.
//

import Foundation

struct GuestModel {
    var id: UUID?
    var photo: Data?
    var name: String?
    var phone: String?
    var email: String?
    var isConfirmed = false
}
