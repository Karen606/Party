//
//  CoctailFormViewModel.swift
//  Party
//
//  Created by Karen Khachatryan on 17.10.24.
//

import Foundation

class CoctailFormViewModel {
    static let shared = CoctailFormViewModel()
    @Published var coctail = CoctailModel(compositions: [CompositionModel(), CompositionModel(), CompositionModel()])
    var previousCompositionsCount: Int = 0
    private init() {}
    
    func addComposition() {
        coctail.compositions?.append(CompositionModel())
    }
    
    func save(completion: @escaping (Error?) -> Void) {
        coctail.compositions?.removeAll(where: { !$0.name.checkValidation() && !$0.value.checkValidation() })
        CoreDataManager.shared.saveCoctail(coctailModel: coctail) { error in
            completion(error)
        }
    }
    
    func clear() {
        coctail = CoctailModel(compositions: [CompositionModel(), CompositionModel(), CompositionModel()])
        previousCompositionsCount = 0
    }
}
