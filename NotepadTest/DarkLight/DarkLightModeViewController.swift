//
//  DarkLightModeViewController.swift
//  NotepadTest
//
//  Created by Thạnh Dương Hoàng on 19/5/25.
//

import UIKit

class DarkLightModeViewController: UIViewController {
    
    @IBOutlet weak var italicButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        italicButton.setImage(UIImage(resource: .highlight), for: .normal)
    }

}
