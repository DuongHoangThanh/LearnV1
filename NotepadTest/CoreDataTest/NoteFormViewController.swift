//
//  NoteFormViewController.swift
//  NotepadTest
//
//  Created by Thạnh Dương Hoàng on 24/4/25.
//

import UIKit

class NoteFormViewController: UIViewController {

    private var note: Note?
    private var onSave: (String, String, Bool, Category) -> Void
    
    private let titleTextFied = UITextField()
    private let descriptionTextView = UITextView()
    private let isCompletedSwitch = UISwitch()
    private let categoryPicker = UIPickerView()
    private var categories: [Category] = []
    private let categoryViewModel = CategoryViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        loadCategories()
        selectCategoryForNote()
    }
    
    init(note: Note? = nil, onSave: @escaping (String, String, Bool, Category) -> Void) {
        self.note = note
        self.onSave = onSave
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = note == nil ? "New Note" : "Edit Note"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        
        let addCategoryButton = UIButton(type: .system)
        addCategoryButton.setTitle("Add Category", for: .normal)
        addCategoryButton.addTarget(self, action: #selector(addCategory), for: .touchUpInside)
        
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        titleTextFied.placeholder = "Title"
        titleTextFied.borderStyle = .roundedRect
        titleTextFied.text = note?.title
        
        descriptionTextView.layer.borderColor = UIColor.systemGray4.cgColor
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.cornerRadius = 5
        descriptionTextView.text = note?.description ?? "Description"
        descriptionTextView.textColor = note?.description == nil ? .placeholderText : .label
        
        let isCompletedLabel = UILabel()
        isCompletedLabel.text = "Completed"
        
        let isCompletedStackView = UIStackView(arrangedSubviews: [isCompletedLabel, isCompletedSwitch])
        isCompletedStackView.axis = .horizontal
        isCompletedStackView.spacing = 8
        
        isCompletedSwitch.isOn = note?.isCompleted ?? false
        
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        
        stackView.addArrangedSubview(titleTextFied)
        stackView.addArrangedSubview(descriptionTextView)
        stackView.addArrangedSubview(isCompletedStackView)
        stackView.addArrangedSubview(categoryPicker)
        stackView.addArrangedSubview(addCategoryButton)
                
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    private func loadCategories() {
        categories = categoryViewModel.fetchCategories()
        print(categories.count)
        categoryPicker.reloadAllComponents()
    }
    
    func selectCategoryForNote() {
        guard let noteCategoryUUID = note?.category.id else {
            return // Không có category liên kết với note
        }
        
        if let index = categories.firstIndex(where: { $0.id == noteCategoryUUID }) {
            categoryPicker.selectRow(index, inComponent: 0, animated: true)
        }
    }
    
    @objc private func save() {
        guard let title = titleTextFied.text, !title.isEmpty, let description = descriptionTextView.text, !description.isEmpty else {
            return
        }
        
        let selectedCategory = categories[categoryPicker.selectedRow(inComponent: 0)]
        print(selectedCategory.name)
        onSave(title, description, isCompletedSwitch.isOn, selectedCategory)
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func addCategory() {
        // Hiển thị một dialog hoặc form để thêm category mới
        let alert = UIAlertController(title: "New Category", message: "Enter category name", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Category Name"
        }
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak self] _ in
            guard let categoryName = alert.textFields?.first?.text, !categoryName.isEmpty else { return }
            self?.categoryViewModel.addCategory(name: categoryName)
            self?.loadCategories() // Tải lại danh sách category
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

extension NoteFormViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row].name
    }
}
