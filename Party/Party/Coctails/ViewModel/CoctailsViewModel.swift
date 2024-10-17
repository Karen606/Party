//
//  CoctailsViewModel.swift
//  Party
//
//  Created by Karen Khachatryan on 17.10.24.
//

import Foundation

class CoctailsViewModel {
    static let shared = CoctailsViewModel()
    @Published var coctails: [CoctailModel] = []
    private init() {}
    
    func fetchData() {
        CoreDataManager.shared.fetchCoctails { coctails, error in
            self.coctails = coctails
        }
    }
    
    func clear() {
        coctails = []
    }
}
