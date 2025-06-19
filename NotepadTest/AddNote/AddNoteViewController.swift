// AddNoteViewController.swift

import UIKit
import PhotosUI

class AddNoteViewController: UIViewController {
    
    private let editorView = RichEditorView()
    private let toolbar = UIStackView()
    var checkboxButton = UIButton()
    var boldButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupEditor()
        setupToolbar()
        observeKeyboard()
    }
    
    private func setupEditor() {
        view.addSubview(editorView)
        view.addSubview(toolbar)
        editorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            editorView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            editorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            editorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            editorView.bottomAnchor.constraint(equalTo: toolbar.topAnchor)
        ])
    }
    
    private func setupToolbar() {
        toolbar.axis = .horizontal
        toolbar.distribution = .equalSpacing
        toolbar.alignment = .center
        toolbar.spacing = 8
        
        let scanButton = makeToolbarButton(systemName: "doc.viewfinder", action: #selector(scanTapped))
        
        checkboxButton = makeToolbarButton(systemName: "checkmark.square", action: #selector(addCheckboxTapped))
        checkboxButton.tintColor = .systemBlue
        let imageButton = makeToolbarButton(systemName: "photo", action: #selector(importImageTapped))
        let styleButton = makeToolbarButton(systemName: "textformat", action: #selector(openStyleSheet))
        boldButton = makeToolbarButton(systemName: "bold", action: #selector(bold))
        
        [scanButton, checkboxButton, imageButton, styleButton, boldButton].forEach { toolbar.addArrangedSubview($0) }
        
        
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func bold() {
        boldButton.isSelected.toggle()
        if boldButton.isSelected {
            boldButton.tintColor = .systemBlue
        } else {
            boldButton.tintColor = .label
        }
    }
    
    private func makeToolbarButton(systemName: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: systemName)
        button.setImage(image, for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    @objc private func scanTapped() {
        print("Get html")
        editorView.getHtml { string in
            print(string ?? "Can not get HTML")
        }
        
    }
    
    @objc private func addCheckboxTapped() {
        print("Checkbox tapped")
        checkboxButton.isSelected.toggle()
//        editorView.insertCheckbox()
    }
    
    @objc private func importImageTapped() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc private func openStyleSheet() {
        let styleVC = StyleOptionBottomSheet(editorView: editorView)
        if let sheet = styleVC.sheetPresentationController {
            sheet.detents = [.medium()]
        }
        present(styleVC, animated: true)
    }
    
    private func observeKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        toolbar.transform = CGAffineTransform(translationX: 0, y: -keyboardFrame.height + view.safeAreaInsets.bottom)
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        toolbar.transform = .identity
    }
}

extension AddNoteViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        print("Picker finished with results: \(results)")
        picker.dismiss(animated: true)
        guard let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) else { return }

        itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
            guard let self = self, let img = image as? UIImage,
                  let data = img.jpegData(compressionQuality: 0.8) else { return }

            let filename = "image_"+UUID().uuidString.prefix(8) + ".jpg"
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)

            do {
                try data.write(to: url)
                DispatchQueue.main.async {
                    print("Image saved to: \(url)")
                    self.editorView.insertImage(url: url.absoluteString)
                }
            } catch {
                print("Failed to save image")
            }
        }
    }
}

//extension AddNoteViewController: PHPickerViewControllerDelegate {
//    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
//        print("Picker finished with results: \(results)")
//        picker.dismiss(animated: true)
//        guard let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) else { return }
//        
//        itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
//            guard let self = self, let img = image as? UIImage,
//                  let data = img.jpegData(compressionQuality: 0.8) else { return }
//            
//            //            let filename = "image_"+UUID().uuidString.prefix(8) + ".jpg"
//            //            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)
//            
//            do {
//                //                try data.write(to: url)
//                DispatchQueue.main.async {
//                    let base64String = data.base64EncodedString()
//                    let htmlString = "<img src='data:image/jpeg;base64,\(base64String)' style='max-width:100%; height:auto;' />"
//                    print("Image saved to: \(htmlString)")
//                    print("hi")
//                    self.editorView.insertHTML(html: htmlString)
//                    //                    self.editorView.insertImage(url: url.absoluteString)
//                }
//            } catch {
//                print("Failed to save image")
//            }
//        }
//    }
//}
