//
//  PartiesViewModel.swift
//  Party
//
//  Created by Karen Khachatryan on 15.10.24.
//

import Foundation

class PartiesViewModel {
    static let shared = PartiesViewModel()
    @Published var parties: [PartyModel] = []
    var data: [PartyModel] = []
    var type: PartyType = .upcoming
    private init() {}
    
    func fetchData() {
        CoreDataManager.shared.fetchParties { [weak self] data, error in
            guard let self = self else { return }
            self.data = data
            filter(type: type)
        }
    }
    
    func filter(type: PartyType) {
        self.type = type
        parties = data.filter { party in
            if let partyDate = party.date {
                if type == .upcoming {
                    return partyDate >= Date()
                } else {
                    return partyDate < Date()
                }
            }
            return false
        }
    }
    
    func clear() {
        parties = []
        data = []
        type = .upcoming
    }
    
}

enum PartyType {
    case upcoming
    case past
}
