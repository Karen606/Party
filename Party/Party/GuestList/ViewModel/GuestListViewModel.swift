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
    
    func fetchData() {
        guard let id = partyModel?.id else { return }
        CoreDataManager.shared.fetchGuests(forPartyId: id) { [weak self] guests, error in
            guard let self = self else { return }
            self.guest = guests
        }
    }
    
    func confirmationGuest(guest: GuestModel, completion: @escaping (Error?) -> Void) {
        guard let partyID = partyModel?.id, let guestID = guest.id else { return }
        CoreDataManager.shared.updateGuestConfirmationStatus(partyID: partyID, guestID: guestID, isConfirmed: true) { error in
            completion(error)
        }
    }
    
    func clear() {
        partyModel = nil
        guest = []
    }
}
