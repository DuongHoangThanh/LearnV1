//
//  NoteViewController.swift
//  NotepadTest
//
//  Created by Thạnh Dương Hoàng on 23/4/25.
//

import UIKit
import Combine

class NoteViewController: UIViewController {

    private let viewModel = NoteViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let searchBar = UISearchBar()
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No Notes yet. Tap '+' to add one"
        label.textAlignment = .center
        label.textColor = .lightGray
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.isHidden = true
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        testCombine()
        setupUI()
        setupBindings()
    }
    
    private func testCombine() {
        let just = Just("Hello word")
        
        let keep = just.sink(receiveCompletion: { completion in
            print("Completion: \(completion)")
        }) { value in
            print("Value: \(value)")
        }
        keep.cancel()
        
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Note list"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNote))
        
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "NoteCell")
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(emptyStateLabel)
        emptyStateLabel.isHidden = !viewModel.notes.isEmpty
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupBindings() {
//        viewModel.onNotesChanged = { [weak self] notes in
//            self?.tableView.reloadData()
//            self?.emptyStateLabel.isHidden = !notes.isEmpty
//        }
        
        viewModel.$notes
            .receive(on: RunLoop.main)
            .sink { [weak self] notes in
                self?.tableView.reloadData()
                self?.emptyStateLabel.isHidden = !notes.isEmpty
                print("---- Note: \n\(notes)")
            }
            .store(in: &cancellables)
    }
    
    @objc private func addNote() {
        presentNoteSheet()
    }
    
    private func presentNoteSheet(note: Note? = nil) {
        let noteFormViewController = NoteFormViewController(note: note) { [weak self] title, description, isCompleted, category in
            if let note = note {
                self?.viewModel.updateNote(id: note.id, title: title, description: description, isCompleted: isCompleted, category: category)
                print("Update note1")
            } else {
                self?.viewModel.addNote(title: title, description: description, category: category)
                print("Add note2")
            }
        }
        
        let navigationController = UINavigationController(rootViewController: noteFormViewController)
        navigationController.modalPresentationStyle = .pageSheet
        
        present(navigationController, animated: true)
    }
}

extension NoteViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath)
        let note = viewModel.notes[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = note.title
        content.secondaryText = note.category.name
        content.secondaryTextProperties.color = .secondaryLabel
        content.secondaryTextProperties.numberOfLines = 1
        cell.contentConfiguration = content
        
        cell.accessoryType = note.isCompleted ? .checkmark : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let note = viewModel.notes[indexPath.row]
        presentNoteSheet(note: note)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let note = viewModel.notes[indexPath.row]
            viewModel.deleteNote(id: note.id)
        } else if editingStyle == .insert {
            print("insert")
        }
    }
}

extension NoteViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        viewModel.searchNotes(query: searchText)
    }
}
