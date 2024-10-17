//
//  CoreDataManager.swift
//  Party
//
//  Created by Karen Khachatryan on 15.10.24.
//

import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Party")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func saveParty(partyModel: PartyModel, completion: @escaping (Error?) -> Void) {
        let id = partyModel.id ?? UUID()
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.perform {
            let fetchRequest: NSFetchRequest<Party> = Party.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)

            do {
                let results = try backgroundContext.fetch(fetchRequest)
                let party: Party

                if let existingParty = results.first {
                    party = existingParty
                } else {
                    party = Party(context: backgroundContext)
                    party.id = id
                }
                party.name = partyModel.name
                party.location = partyModel.location
                party.theme = partyModel.theme
                party.date = partyModel.date
                
                if let guestsModel = partyModel.guests {
                    var guests = Set<Guest>()
                    for guest in guestsModel {
                        let guestEntity = Guest(context: backgroundContext)
                        guestEntity.id = guest.id
                        guestEntity.name = guest.name
                        guestEntity.email = guest.email
                        guestEntity.phone = guest.phone
                        guestEntity.photo = guest.photo
                        guestEntity.isConfirmed = guest.isConfirmed
                        guests.insert(guestEntity)
                    }
                    party.guests = guests as NSSet
                } else {
                    party.guests = nil
                }
                try backgroundContext.save()
                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }
    
    func fetchParties(completion: @escaping ([PartyModel], Error?) -> Void) {
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.perform {
            let fetchRequest: NSFetchRequest<Party> = Party.fetchRequest()
            
            do {
                let results = try backgroundContext.fetch(fetchRequest)
                var partyModels: [PartyModel] = []
                for result in results {
                    let partyModel = PartyModel(id: result.id, name: result.name, location: result.location, theme: result.theme, date: result.date)
                    partyModels.append(partyModel)
                }
                completion(partyModels, nil)
            } catch {
                DispatchQueue.main.async {
                    completion([], error)
                }
            }
        }
    }
    
    func saveGuest(guestModel: GuestModel, completion: @escaping (Error?) -> Void) {
        let id = guestModel.id ?? UUID()
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.perform {
            let fetchRequest: NSFetchRequest<Guest> = Guest.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)

            do {
                let results = try backgroundContext.fetch(fetchRequest)
                let guest: Guest

                if let existingGuest = results.first {
                    guest = existingGuest
                } else {
                    guest = Guest(context: backgroundContext)
                    guest.id = id
                }
                guest.name = guestModel.name
                guest.phone = guestModel.phone
                guest.email = guestModel.email
                guest.photo = guestModel.photo
                guest.isConfirmed = guestModel.isConfirmed
                try backgroundContext.save()
                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }
    
    func fetchGuests(completion: @escaping ([GuestModel], Error?) -> Void) {
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.perform {
            let fetchRequest: NSFetchRequest<Guest> = Guest.fetchRequest()
            
            do {
                let results = try backgroundContext.fetch(fetchRequest)
                var guestsModel: [GuestModel] = []
                for result in results {
                    let guestModel = GuestModel(id: result.id, photo: result.photo, name: result.name, phone: result.phone, email: result.email, isConfirmed: result.isConfirmed)  
                    guestsModel.append(guestModel)
                }
                completion(guestsModel, nil)
            } catch {
                DispatchQueue.main.async {
                    completion([], error)
                }
            }
        }
    }
    
//    func addGuestToParty(guestModel: GuestModel, partyID: UUID, completion: @escaping (Error?) -> Void) {
//        let backgroundContext = persistentContainer.newBackgroundContext()
//        backgroundContext.perform {
//            let fetchRequest: NSFetchRequest<Party> = Party.fetchRequest()
//            fetchRequest.predicate = NSPredicate(format: "id == %@", partyID as CVarArg)
//
//            do {
//                let results = try backgroundContext.fetch(fetchRequest)
//                if let party = results.first {
//                    if (party.guests ?? []).contains(where: { $0.id == guestModel.id }) {
//                        completion(nil)
//                    } else {
//                        let guest = Guest(context: backgroundContext)
//                        guest.id = guestModel.id
//                        guest.name = guestModel.name
//                        guest.phone = guestModel.phone
//                        guest.email = guestModel.email
//                        guest.photo = guestModel.photo
//                        guest.isConfirmed = guestModel.isConfirmed
//                        party.guests?.append(guest)
//                    }
//                }
//                try backgroundContext.save()
//                DispatchQueue.main.async {
//                    completion(nil)
//                }
//            } catch {
//                DispatchQueue.main.async {
//                    completion(error)
//                }
//            }
//        }
//    }
    
    func addGuestToParty(guestModel: GuestModel, partyID: UUID, completion: @escaping (Error?) -> Void) {
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.perform {
            let partyFetchRequest: NSFetchRequest<Party> = Party.fetchRequest()
            partyFetchRequest.predicate = NSPredicate(format: "id == %@", partyID as CVarArg)

            do {
                guard let party = try backgroundContext.fetch(partyFetchRequest).first else {
                    throw NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Party not found"])
                }

                let guestFetchRequest: NSFetchRequest<Guest> = Guest.fetchRequest()
                guestFetchRequest.predicate = NSPredicate(format: "id == %@", guestModel.id as CVarArg? ?? UUID() as CVarArg)

                let guest: Guest
                if let existingGuest = try backgroundContext.fetch(guestFetchRequest).first {
                    guest = existingGuest
                } else {
                    guest = Guest(context: backgroundContext)
                    guest.id = guestModel.id ?? UUID()
                }

                guest.name = guestModel.name
                guest.phone = guestModel.phone
                guest.email = guestModel.email
                guest.photo = guestModel.photo
                guest.isConfirmed = guestModel.isConfirmed

                party.addToGuests(guest)

                try backgroundContext.save()
                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }
    
    func fetchGuests(forPartyId partyId: UUID, completion: @escaping ([GuestModel], Error?) -> Void) {
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.perform {
            let fetchRequest: NSFetchRequest<Party> = Party.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", partyId as CVarArg)
            fetchRequest.relationshipKeyPathsForPrefetching = ["guests"]

            do {
                guard let party = try backgroundContext.fetch(fetchRequest).first,
                      let guests = party.guests?.allObjects as? [Guest] else {
                    throw NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Party or Guests not found"])
                }

                let guestModels = guests.map { guest in
                    GuestModel(
                        id: guest.id,
                        photo: guest.photo,
                        name: guest.name,
                        phone: guest.phone,
                        email: guest.email,
                        isConfirmed: guest.isConfirmed
                    )
                }

                DispatchQueue.main.async {
                    completion(guestModels, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion([], error)
                }
            }
        }
    }
    
    func updateGuestConfirmationStatus(partyID: UUID, guestID: UUID, isConfirmed: Bool, completion: @escaping (Error?) -> Void) {
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.perform {
            let partyFetchRequest: NSFetchRequest<Party> = Party.fetchRequest()
            partyFetchRequest.predicate = NSPredicate(format: "id == %@", partyID as CVarArg)

            do {
                guard let party = try backgroundContext.fetch(partyFetchRequest).first else {
                    throw NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Party not found"])
                }

                let guestFetchRequest: NSFetchRequest<Guest> = Guest.fetchRequest()
                guestFetchRequest.predicate = NSPredicate(format: "id == %@ AND party == %@", guestID as CVarArg, party)

                guard let guest = try backgroundContext.fetch(guestFetchRequest).first else {
                    throw NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Guest not found in the selected party"])
                }

                guest.isConfirmed = isConfirmed

                try backgroundContext.save()
                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }

//    
//    func removeBooking(id: UUID, completion: @escaping (Error?) -> Void) {
//        let backgroundContext = persistentContainer.newBackgroundContext()
//        backgroundContext.perform {
//            let fetchRequest: NSFetchRequest<BookRoom> = BookRoom.fetchRequest()
//            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
//            
//            do {
//                let results = try backgroundContext.fetch(fetchRequest)
//                if let bookingToDelete = results.first {
//                    backgroundContext.delete(bookingToDelete)
//                    
//                    do {
//                        try backgroundContext.save()
//                        DispatchQueue.main.async {
//                            completion(nil)
//                        }
//                    } catch {
//                        DispatchQueue.main.async {
//                            completion(error)
//                        }
//                    }
//                } else {
//                    DispatchQueue.main.async {
//                        let error = NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Booking with id \(id) not found."])
//                        completion(error)
//                    }
//                }
//            } catch {
//                DispatchQueue.main.async {
//                    completion(error)
//                }
//            }
//        }
//    }


}
