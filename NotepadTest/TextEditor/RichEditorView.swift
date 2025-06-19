// MiniRichEditorView.swift
// Rich Text Editor (UIKit + WKWebView)

import UIKit
import WebKit

class RichEditorView: UIView {

    private(set) var webView: WKWebView!

    var html: String {
        get {
            assertionFailure("⚠️ Use getText(completion:) instead of accessing .text directly.")
            return ""
        }
        set { evaluateJSVoid("RE.setHtml(`\(newValue.escapedJS)`);") }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupWebView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupWebView()
    }

    private func setupWebView() {
        let config = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        config.userContentController = userContentController
        
        webView = WKWebView(frame: bounds, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: topAnchor),
            webView.leadingAnchor.constraint(equalTo: leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        if let htmlPath = Bundle.main.path(forResource: "rich_editor", ofType: "html"),
           let htmlString = try? String(contentsOfFile: htmlPath, encoding: .utf8) {
            webView.loadHTMLString(htmlString, baseURL: Bundle.main.bundleURL)
        }
    }

    func evaluateJSVoid(_ js: String) {
        webView.evaluateJavaScript(js, completionHandler: nil)
    }

    // MARK: - Editor Actions

    func bold() { evaluateJSVoid("RE.setBold();") }
    func italic() { evaluateJSVoid("RE.setItalic();") }
    func underline() { evaluateJSVoid("RE.setUnderline();") }
    func strike() { evaluateJSVoid("RE.setStrikeThrough();") }
    func header(_ level: Int) { evaluateJSVoid("RE.setHeading(\"\(level)\");") }
    func setNormalText() { evaluateJSVoid("RE.removeFormat();") }
    func unorderedList() { evaluateJSVoid("RE.setUnorderedList();") }
    func orderedList() { evaluateJSVoid("RE.setOrderedList();") }
    func blockquote() { evaluateJSVoid("RE.setBlockquote();") }
    func indent() { evaluateJSVoid("RE.setIndent();") }
    func outdent() { evaluateJSVoid("RE.setOutdent();") }
    func alignLeft() { evaluateJSVoid("RE.setJustifyLeft();") }
    func alignCenter() { evaluateJSVoid("RE.setJustifyCenter();") }
    func alignRight() { evaluateJSVoid("RE.setJustifyRight();") }
    func undo() { evaluateJSVoid("RE.undo();") }
    func redo() { evaluateJSVoid("RE.redo();") }

    func setTextColor(hex: String) {
        evaluateJSVoid("RE.setTextColor(\"\(hex)\");")
    }

    func setTextBackgroundColor(hex: String) {
        evaluateJSVoid("RE.setTextBackgroundColor(\"\(hex)\");")
    }

    func insertImage(url: String) {
        evaluateJSVoid("RE.insertImage(\"\(url)\", 'image');")
    }
    
    func insertHTML(html: String) {
        evaluateJSVoid("RE.insertHTML(\"\(html.escapedJS)\");")
    }

    func insertCheckbox() {
        evaluateJSVoid("RE.insertCheckbox();")
    }

    func insertLink(url: String, title: String) {
        evaluateJSVoid("RE.insertLink(\"\(url)\", \"\(title)\");")
    }

    func focus() {
        evaluateJSVoid("RE.focus();")
    }

    func blur() {
        evaluateJSVoid("RE.blurFocus();")
    }

    func setPlaceholder(_ text: String) {
        evaluateJSVoid("RE.setPlaceholderText(\"\(text.escapedJS)\");")
    }
    
    func getHtml(completion: @escaping (String?) -> Void) {
        webView.evaluateJavaScript("RE.getHtml();") { result, error in
            completion(result as? String)
        }
    }
}
