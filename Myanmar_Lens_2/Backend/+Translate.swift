//
//  +Translate.swift
//  Myanmar_Lens_2
//
//  Created by Aung Ko Min on 25/4/22.
//

import CoreData
import NaturalLanguage

extension Translate {
    
    static func createIfNeeded(source: String, sourceLanguage: NLLanguage, target: String, targetLanguage: NLLanguage) {
        let from = source.lowercased().trimmed
        let to = target.lowercased().trimmed
        guard check(from: from, fromLanguage: sourceLanguage, to: to, toLanguage: targetLanguage) == nil else { return }
        let context = PersistenceController.shared.viewContext
        let x = Translate(context: context)
        x.from = from
        x.fromLanguage = sourceLanguage.rawValue
        x.to = to
        x.toLanguage = targetLanguage.rawValue
    }
    
    static func check(from: String, fromLanguage: NLLanguage, to: String, toLanguage: NLLanguage) -> Translate? {
        let from = from.lowercased().trimmed
        let to = to.lowercased().trimmed
        let context = PersistenceController.shared.viewContext
        let request: NSFetchRequest<Translate> = Translate.fetchRequest()
        let fromPredicate = NSPredicate(format: "from ==[c] %@ && fromLanguage == %@", argumentArray: [from, fromLanguage.rawValue])
        let toPredicate = NSPredicate(format: "to ==[c] %@ && toLanguage == %@", argumentArray: [to, toLanguage.rawValue])
        
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [fromPredicate, toPredicate])
        request.fetchLimit = 1
        do {
            return try context.fetch(request).first
        } catch {
            fatalError()
        }
    }
    
    static func find(from: String, toLanguage: NLLanguage) -> String? {
        let string = from.lowercased().trimmed
        let context = PersistenceController.shared.viewContext
        let request: NSFetchRequest<Translate> = Translate.fetchRequest()
        request.predicate = NSPredicate(format: "from ==[c] %@ && toLanguage == %@ ", argumentArray: [string, toLanguage.rawValue])
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
    
    static func deleteAll() {
        let context = PersistenceController.shared.viewContext
        let request: NSFetchRequest<NSFetchRequestResult> = Translate.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        do {
            try context.execute(deleteRequest)
        } catch {
            print(error)
        }
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
