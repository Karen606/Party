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
    
//    func saveBookRoom(bookRoomModel: BookRoomModel, completion: @escaping (Error?) -> Void) {
//        let backgroundContext = persistentContainer.newBackgroundContext()
//        backgroundContext.perform {
//            do {
//                let bookRoom = BookRoom(context: backgroundContext)
//                bookRoom.id = bookRoomModel.id
//                bookRoom.roomID = bookRoomModel.roomId
//                bookRoom.startDate = bookRoomModel.startDate
//                bookRoom.endDate = bookRoomModel.endDate
//                bookRoom.numberOfGuests = bookRoomModel.numberOfGuests
//                bookRoom.name = bookRoomModel.name
//                bookRoom.surname = bookRoomModel.surname
//                bookRoom.email = bookRoomModel.email
//                bookRoom.phoneNumber = bookRoomModel.phoneNumber
//                bookRoom.photo = bookRoomModel.photo
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
//    
//    func fetchBookings(completion: @escaping ([BookRoomModel], Error?) -> Void) {
//        let backgroundContext = persistentContainer.newBackgroundContext()
//        backgroundContext.perform {
//            let fetchRequest: NSFetchRequest<BookRoom> = BookRoom.fetchRequest()
//            
//            do {
//                let results = try backgroundContext.fetch(fetchRequest)
//                var bookingsModel: [BookRoomModel] = []
//                for result in results {
//                    let bookingModel = BookRoomModel(id: result.id, roomId: result.roomID, photo: result.photo, startDate: result.startDate, endDate: result.endDate, numberOfGuests: result.numberOfGuests, name: result.name, surname: result.surname, email: result.email, phoneNumber: result.phoneNumber)
//                    bookingsModel.append(bookingModel)
//                }
//                completion(bookingsModel, nil)
//            } catch {
//                DispatchQueue.main.async {
//                    completion([], error)
//                }
//            }
//        }
//    }
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
