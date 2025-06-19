//
//  UserViewController.swift
//  NotepadTest
//
//  Created by Thạnh Dương Hoàng on 5/5/25.
//

import UIKit
import Combine

class UserViewController: UIViewController {
    
    @Published var name = 0
    var cancellable: Set<AnyCancellable> = []
    
    let button = UIButton()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButton()
//        bind1()
//        bind2()
//        bind3()
//        bind4()
//        bind5()
        bind6()
//        bind7()
        
    }
    
    private func bind7() {
        let numbers = [1, 2, 5, 7].publisher
        
        numbers
            .scan(0) { sum, value in
                sum + value
            }
            .sink { value in
                print(value)
            }
            .store(in: &cancellable)
    }
    
    private func bind6() {
        struct Chatter {
            var name: String
            var message: CurrentValueSubject<String, Never>
            
            init(name: String, message: String) {
                self.name = name
                self.message = CurrentValueSubject(message)
            }
        }
        
        var ty = Chatter(name: "Ty", message: "- Ty has joined chat room -")
        var teo = Chatter(name: "Teo", message: "- Teo has joined chat room -")
        
        let chat = PassthroughSubject<Chatter, Never>()
        
//        chat
//            .flatMap({ chatter in
//                print("\(chatter) - type of: \(type(of: chatter))")
//                print("\(chatter.message) - type of: \(type(of: chatter.message))")
//                return chatter.message
//            })
//            .sink { value in
//                print("\(value) - type of: \(type(of: value))")
//            }
//            .store(in: &cancellable)
        
        chat
            .flatMap { chatter in
                chatter.message
            }
            .scan(0) { count, _ in
                count + 1
            }
            .sink { count in
                print("Count: \(count)")
            }
            .store(in: &cancellable)
            
        
        chat.send(ty)
        ty.message.value = "What is this?"
        
        chat.send(teo)
        
        ty.message.value = "Oh, hello teo"
        teo.message.value = "Hi ty"
        
        
        
    }
    
    private func bind5() {
        let p1 = [1, 2, 5, 5].publisher
        
        p1
            .map { value in
                value*2
            }
            .sink { value in
                print(value)
            }
    }
    
    private func bind4() {
        let future = Future<String, Never> { promise in
            promise(.success("Ye thanh cong roi ne"))
        }
        
        future
            .sink { value in
                print(value)
            }
        
        
    }
    
    private func createFuture(handler: @escaping (@escaping (Result<String, Never>) -> Void) -> Void) {
        handler { result in
            print("\(result)")
        }
    }
    
    private func bind3() {
        let just = Just([1,2,3])
        just
            .sink(receiveValue: { value in
                print(value)
            })
            .store(in: &cancellable)
    }
    
    private func bind2() {
        $name
            .sink { value in
                print(value)
            }
            .store(in: &cancellable)
    }
    
    private func bind1() {
        let numbers = [1, 4, 6, 8, 9]
        let pub1 = numbers.publisher
        
        let pub2 = pub1.map { value in
            return "\(value)"
        }
        
        pub1
            .reduce(0, +)
            .sink { value in
                print(value)
            }
        
        pub2
            .reduce("", +)
            .sink { value in
                print(value)
            }
    }
    
    private func setupButton() {
        button.frame.size = CGSize(width: 50, height: 30)
        button.setTitle("Click me", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.backgroundColor = .yellow
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(changeValue), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func changeValue() {
        name = Int.random(in: 1...10)
    }
}
