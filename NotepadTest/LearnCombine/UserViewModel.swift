//
//  UserViewModel.swift
//  NotepadTest
//
//  Created by Thạnh Dương Hoàng on 5/5/25.
//

import Foundation
import Combine

class UserViewModel {
    @Published var username: String = ""
    @Published var isLoading: Bool = false
    let fetchUserObject = PassthroughSubject<Void, Never>()
    let userFetchResult = PassthroughSubject<String, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        
    }
    
    func setupBindings() {
        
    }
}
