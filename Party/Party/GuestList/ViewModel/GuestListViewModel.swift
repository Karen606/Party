//
//  GuestListViewModel.swift
//  Party
//
//  Created by Karen Khachatryan on 16.10.24.
//

import Foundation

class GuestListViewModel {
    static let shared = GuestListViewModel()
    @Published var guest: [GuestModel] = []
    var partyModel: PartyModel?
    
    private init() {}
    
    func clear() {
        partyModel = nil
        guest = []
    }
}
