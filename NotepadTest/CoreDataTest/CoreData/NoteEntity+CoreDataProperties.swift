//
//  NoteEntity+CoreDataProperties.swift
//  
//
//  Created by Thạnh Dương Hoàng on 24/4/25.
//
//

import Foundation
import CoreData


extension NoteEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NoteEntity> {
        return NSFetchRequest<NoteEntity>(entityName: "NoteEntity")
    }

    @NSManaged public var desc: String?
    @NSManaged public var id: UUID?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var title: String?
    @NSManaged public var category: CategoryEntity?

}

extension NoteEntity {
    func toNoteModel() -> Note {
        print(self.id!)
        return Note(
            id: self.id ?? UUID(),
            title: self.title ?? "",
            description: self.desc ?? "",
            isCompleted: self.isCompleted,
            category: self.category?.toCategoryModel() ?? Category(id: UUID(), name: "Uncategorized"))
    }
}
