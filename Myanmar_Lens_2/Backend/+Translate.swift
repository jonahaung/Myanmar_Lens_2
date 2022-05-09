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
        let context = PersistenceController.shared.viewContext
        let x = Translate(context: context)
        x.from = source
        x.fromLanguage = sourceLanguage.rawValue
        x.to = target
        x.toLanguage = targetLanguage.rawValue
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
