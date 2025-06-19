//
//  File.swift
//  NotepadTest
//
//  Created by Thạnh Dương Hoàng on 24/4/25.
//

import Foundation
import CoreData
import Combine

class CategoryViewModel {
        
    func fetchCategories() -> [Category] {
        return CoreDataStack.shared.fetchCategories()
    }
    
    func addCategory(name: String) {
        let context = CoreDataStack.shared.viewContext
        let category = Category(id: UUID(), name: name)
        _ = category.toCategoryEntity(context: context)
        print("add category 1")
        CoreDataStack.shared.saveContext() // Lưu context sau khi thêm category
    }
}
