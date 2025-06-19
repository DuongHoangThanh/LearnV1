//
//  CoreDataStack.swift
//  NotepadTest
//
//  Created by Thạnh Dương Hoàng on 23/4/25.
//

import Foundation
import CoreData

class CoreDataStack {
    
    static let shared = CoreDataStack()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "NoteModel")
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func saveContext() {
        let context = viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func setupDefaultCategories() {
        let existingCategories = fetchCategories()
        
        // Nếu chưa có category nào thì thêm các category mặc định
        if existingCategories.isEmpty {
            let categories = ["Personal", "Office", "Study", "Other"]
            for name in categories {
                let category = Category(id: UUID(), name: name)
                _ = category.toCategoryEntity(context: viewContext)
            }
            print("Fetch category")
            saveContext()
        }
    }
    
    func fetchCategories() -> [Category] {
        let context = viewContext
        let request: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        
        do {
            let fetchedCategories = try context.fetch(request)
            return fetchedCategories.map { $0.toCategoryModel() }
        } catch {
            print("Failed to fetch categories: \(error)")
            return []
        }
    }
}
