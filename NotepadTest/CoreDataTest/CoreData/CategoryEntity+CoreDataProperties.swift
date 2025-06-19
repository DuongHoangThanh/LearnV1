//
//  CategoryEntity+CoreDataProperties.swift
//  
//
//  Created by Thạnh Dương Hoàng on 24/4/25.
//
//

import Foundation
import CoreData


extension CategoryEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CategoryEntity> {
        return NSFetchRequest<CategoryEntity>(entityName: "CategoryEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var notes: NSSet?

}

// MARK: Generated accessors for notes
extension CategoryEntity {

    @objc(addNotesObject:)
    @NSManaged public func addToNotes(_ value: NoteEntity)

    @objc(removeNotesObject:)
    @NSManaged public func removeFromNotes(_ value: NoteEntity)

    @objc(addNotes:)
    @NSManaged public func addToNotes(_ values: NSSet)

    @objc(removeNotes:)
    @NSManaged public func removeFromNotes(_ values: NSSet)

}

extension CategoryEntity {
    func toCategoryModel() -> Category {
        return Category(id: self.id ?? UUID(), name: self.name ?? "")
    }
}
