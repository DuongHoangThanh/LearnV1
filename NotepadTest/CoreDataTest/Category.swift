//
//  Category.swift
//  NotepadTest
//
//  Created by Thạnh Dương Hoàng on 24/4/25.
//

import Foundation
import CoreData

struct Category {
    let id: UUID
    let name: String
    
    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}

extension Category {
    func toCategoryEntity(context: NSManagedObjectContext) -> CategoryEntity {
        let categoryEntity = CategoryEntity(context: context)
        categoryEntity.id = self.id
        categoryEntity.name = self.name
        return categoryEntity
    }
}

extension Category {
    static func fetchAll() -> [Category] {
        let context = CoreDataStack.shared.viewContext
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
