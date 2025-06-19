//
//  String+Extensions.swift
//  Pods
//
//  Created by Caesar Wirth on 10/9/16.
//
//

import Foundation

extension String {
    var escapedJS: String {
        replacingOccurrences(of: "`", with: "\\`")
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\n", with: "\\n")
    }
}

