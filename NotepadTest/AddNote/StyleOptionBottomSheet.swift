//
//  StyleSheet.swift
//  NotepadTest
//
//  Created by Thạnh Dương Hoàng on 16/5/25.
//

// StyleOptionBottomSheet.swift

import UIKit

class StyleOptionBottomSheet: UIViewController {

    private let editorView: RichEditorView
    private let colors: [UIColor] = [
        .black, .darkGray, .gray, .lightGray, .white,
        .red, .green, .blue, .orange, .purple,
        UIColor.systemRed.withAlphaComponent(0.5),
        UIColor.systemGreen.withAlphaComponent(0.5),
        UIColor.systemBlue.withAlphaComponent(0.5),
        UIColor.systemOrange.withAlphaComponent(0.5),
        UIColor.systemPurple.withAlphaComponent(0.5),
        UIColor.systemYellow, .brown, .magenta, .cyan, .systemTeal
    ]

    init(editorView: RichEditorView) {
        self.editorView = editorView
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
    }

    private func setupUI() {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.topAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scroll.topAnchor, constant: 20),
            stack.bottomAnchor.constraint(equalTo: scroll.bottomAnchor, constant: -20),
            stack.leadingAnchor.constraint(equalTo: scroll.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: scroll.trailingAnchor, constant: -20),
            stack.widthAnchor.constraint(equalTo: scroll.widthAnchor, constant: -40)
        ])

        let textStyles = makeButtonRow([("H1", { self.editorView.header(1) }),
                                        ("H2", { self.editorView.header(2) }),
                                        ("Normal", { self.editorView.setNormalText() })])

        let formatStyles = makeButtonRow([("B", { self.editorView.bold() }),
                                          ("I", { self.editorView.italic() }),
                                          ("U", { self.editorView.underline() }),
                                          ("S", { self.editorView.strike() })])

        let listStyles = makeButtonRow([("• List", { self.editorView.unorderedList() }),
                                        ("1. List", { self.editorView.orderedList() })])

        let colorTitle = makeTitle("Text Color & Background")
        let colorStack = makeColorGrid()

        stack.addArrangedSubview(textStyles)
        stack.addArrangedSubview(formatStyles)
        stack.addArrangedSubview(listStyles)
        stack.addArrangedSubview(colorTitle)
        stack.addArrangedSubview(colorStack)
    }

    private func makeButtonRow(_ items: [(String, () -> Void)]) -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 12
        row.distribution = .fillEqually

        for (title, action) in items {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = .boldSystemFont(ofSize: 16)
            button.addAction(UIAction { _ in action() }, for: .touchUpInside)
            row.addArrangedSubview(button)
        }
        return row
    }

    private func makeTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }

    private func makeColorGrid() -> UIStackView {
        let grid = UIStackView()
        grid.axis = .vertical
        grid.spacing = 8

        for i in stride(from: 0, to: colors.count, by: 5) {
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 8
            row.distribution = .fillEqually

            for color in colors[i..<min(i+5, colors.count)] {
                let button = UIButton(type: .system)
                button.backgroundColor = color
                button.layer.cornerRadius = 4
                button.layer.borderWidth = 1
                button.layer.borderColor = UIColor.black.withAlphaComponent(0.2).cgColor
                button.heightAnchor.constraint(equalToConstant: 32).isActive = true
                button.addAction(UIAction { [weak self] _ in
                    self?.editorView.setTextColor(hex: color.toHexString())
//                    self?.editorView.setTextBackgroundColor(hex: color.toHexString())
                }, for: .touchUpInside)
                row.addArrangedSubview(button)
            }
            grid.addArrangedSubview(row)
        }
        return grid
    }
}

private extension UIColor {
    func toHexString() -> String {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return String(format: "#%02lX%02lX%02lX", lroundf(Float(red * 255)), lroundf(Float(green * 255)), lroundf(Float(blue * 255)))
    }
}
