//
//  Note.swift
//  NotepadTest
//
//  Created by Thạnh Dương Hoàng on 23/4/25.
//

import Foundation
import CoreData

struct Note: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let isCompleted: Bool
    let category: Category
    
    init(id: UUID = UUID(), title: String, description: String, isCompleted: Bool = false, category: Category) {
        self.id = id
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
        self.category = category
    }
}

extension Note {
    func toEntity(context: NSManagedObjectContext) -> NoteEntity {
        let entity = NoteEntity(context: context)
        entity.id = self.id
        entity.title = self.title
        entity.desc = self.description
        entity.isCompleted = self.isCompleted
        entity.category = self.category.toCategoryEntity(context: context)
        return entity
    }
}

