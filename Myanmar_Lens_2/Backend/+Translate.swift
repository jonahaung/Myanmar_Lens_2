//
//  +Translate.swift
//  Myanmar_Lens_2
//
//  Created by Aung Ko Min on 25/4/22.
//

import CoreData

extension Translate {
    
    static func createIfNeeded(from: String, to: String) {
        let from = from.lowercased().trimmed
        let to = to.lowercased().trimmed
        guard check(from: from, to: to) == nil else { return }
        let context = PersistenceController.shared.viewContext
        let x = Translate(context: context)
        x.from = from
        x.to = to
        PersistenceController.shared.save()
    }
    
    static func check(from: String, to: String) -> Translate? {
        let from = from.lowercased().trimmed
        let to = to.lowercased().trimmed
        let context = PersistenceController.shared.viewContext
        let request: NSFetchRequest<Translate> = Translate.fetchRequest()
        let fromPredicate = NSPredicate(format: "from == %@", from)
        let toPredicate = NSPredicate(format: "to == %@", to)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [fromPredicate, toPredicate])
        request.fetchLimit = 1
        do {
            return try context.fetch(request).first
        } catch {
            fatalError()
        }
    }
    
    static func find(string: String) -> String? {
        let string = string.lowercased().trimmed
        let context = PersistenceController.shared.viewContext
        let request: NSFetchRequest<Translate> = Translate.fetchRequest()
        let fromPredicate = NSPredicate(format: "from == %@", string)
        let toPredicate = NSPredicate(format: "to == %@", string)
        request.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [fromPredicate, toPredicate])
        request.fetchLimit = 1
        do {
            if let found = try context.fetch(request).first {
                return found.to == string ? found.from : found.to
            }
            return nil
        } catch {
            print(error)
            return nil
        }
    }
    
    static func displayText(string: String) -> String {
        return find(string: string) ?? string
    }
    
    static func deleteAll() {
        let context = PersistenceController.shared.viewContext
        let request: NSFetchRequest<NSFetchRequestResult> = Translate.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        do {
            try context.execute(deleteRequest)
        } catch {
            print(error)
        }
        PersistenceController.shared.save()
    }
    
    static func all() -> [Translate] {
        let context = PersistenceController.shared.viewContext
        let request: NSFetchRequest<Translate> = Translate.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            fatalError()
        }
    }
}
