//
//  NoteViewModel.swift
//  NotepadTest
//
//  Created by Thạnh Dương Hoàng on 23/4/25.
//

import Foundation
import CoreData
import Combine

class NoteViewModel {
    
    @Published private(set) var notes: [Note] = []
//    {
//        didSet {
//            onNotesChanged?(notes)
//        }
//    }
    
//    var onNotesChanged: (([Note]) -> Void)?
    
    private let context = CoreDataStack.shared.viewContext
    
    init () {
        fetchNotes()
    }
    
    private func fetchNotes() {
        let request: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        do {
            let fetchedNotes = try context.fetch(request)
            notes = fetchedNotes.map({ $0.toNoteModel() })
        } catch {
            print("Failed to fetch todos: \(error)")
        }
    }
    
    func fetchCategories() -> [Category] {
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
    
    func addNote(title: String, description: String, category: Category) {
        let newNote = NoteEntity(context: context)
        newNote.id = UUID()
        newNote.title = title
        newNote.desc = description
        newNote.isCompleted = true
        print(newNote.isCompleted)
        let categoryEntity = fetchCategoryById(category.id)
        newNote.category = categoryEntity
        
        saveContext()
        print("add new")
        fetchNotes()
    }
    
    func updateNote(id: UUID,title: String, description: String, isCompleted: Bool, category: Category) {
        let request: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let fetchedNotes = try context.fetch(request)
            if let noteUpdate = fetchedNotes.first {
                noteUpdate.title = title
                noteUpdate.desc = description
                noteUpdate.isCompleted = isCompleted
                let categoryEntity = fetchCategoryById(category.id)
                noteUpdate.category = categoryEntity
                
                saveContext()
                fetchNotes()
            }
        } catch {
            print("Failed to update todo: \(error)")
        }
    }
    
    func deleteNote(id: UUID) {
        let request: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let fetchedNote = try context.fetch(request)
            if let noteDelete = fetchedNote.first {
                context.delete(noteDelete)
                
                saveContext()
                fetchNotes()
            }
            
        } catch {
            print("Failed to delete todo: \(error)")
        }
    }
    
    func deleteAllNotes() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NoteEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            fetchNotes()
        } catch {
            print("Failed to delete all notes: \(error)")
        }
    }
    
    func fetchCategoryById(_ id: UUID) -> CategoryEntity? {
        let request: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let categories = try context.fetch(request)
            return categories.first
        } catch {
            print("Failed to fetch category: \(error)")
            return nil
        }
    }
    
    func searchNotes(query: String) {
        if query.isEmpty {
            fetchNotes()
        } else {
            let request: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
            request.predicate = NSPredicate(format: "title CONTAINS[cd] %@ OR desc CONTAINS[cd] %@", query, query)
            do {
                let fetchedNotes = try context.fetch(request)
                notes = fetchedNotes.map({ $0.toNoteModel() })
            } catch {
                print("Failed to fetch notes: \(error)")
            }
        }
    }

    
    private func saveContext() {
        CoreDataStack.shared.saveContext()
    }
}
