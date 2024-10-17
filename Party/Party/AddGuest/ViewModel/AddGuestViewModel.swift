//
//  AddGuestViewModel.swift
//  Party
//
//  Created by Karen Khachatryan on 16.10.24.
//

import Foundation

class AddGuestViewModel {
    static let shared = AddGuestViewModel()
    @Published var guests: [GuestModel] = []
    var guest: GuestModel?
    var data: [GuestModel] = []
    var party: PartyModel?
    var search: String?
    private init() {}
    
    func fetchData() {
        CoreDataManager.shared.fetchGuests { [weak self] data, error in
            guard let self = self else { return }
            self.data = data
            search(by: search)
        }
    }
    
    func search(by value: String?) {
        self.search = value
        if let value = value, !value.isEmpty {
            guests = data.filter { ($0.name)?.localizedCaseInsensitiveContains(value) ?? false }
        } else {
            guests = data
        }
    }
    
    func save(completion: @escaping (Error?) -> Void) {
        guard let guest = guest else { return }
        CoreDataManager.shared.saveGuest(guestModel: guest) { [weak self] error in
            self?.guest = nil
            completion(error)
        }
    }
    
    func addGuest() {
        guest = GuestModel()
    }
    
    func clear() {
        guests = []
        data = []
        guest = nil
        party = nil
        search = nil
    }
}
