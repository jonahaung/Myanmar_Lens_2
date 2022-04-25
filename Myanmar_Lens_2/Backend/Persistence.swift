//
//  Persistence.swift
//  Myanmar_Lens_2
//
//  Created by Aung Ko Min on 25/4/22.
//

import CoreData

class PersistenceController {
    static var shared = PersistenceController()
    private let container: NSPersistentContainer

    lazy var viewContext: NSManagedObjectContext = container.newBackgroundContext()
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Myanmar_Lens_2")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
    
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func save() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print(error)
            }
        }
    }
}
