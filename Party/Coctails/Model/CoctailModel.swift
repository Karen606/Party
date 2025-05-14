//
//  CoctailModel.swift
//  Party
//
//  Created by Karen Khachatryan on 17.10.24.
//

import Foundation

struct CoctailModel {
    var id: UUID?
    var name: String?
    var photo: Data?
    var compositions: [CompositionModel]?
    var descriptionPreparation: String?
}

struct CompositionModel {
    var name: String?
    var value: String?
}
