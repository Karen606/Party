//
//  CreatePartyViewModel.swift
//  Party
//
//  Created by Karen Khachatryan on 15.10.24.
//

import Foundation

class CreatePartyViewModel {
    static let shared = CreatePartyViewModel()
    @Published var partyModel = PartyModel(id: UUID())
    private init() {}
    
    func save(completion: @escaping (Error?) -> Void) {
        CoreDataManager.shared.saveParty(partyModel: partyModel) { error in
            completion(error)
        }
    }
    
    func clear() {
        partyModel = PartyModel(id: UUID())
    }
}
