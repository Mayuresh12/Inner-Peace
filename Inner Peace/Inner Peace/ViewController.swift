//
//  ViewController.swift
//  Inner Peace
//
//  Created by Mayuresh Rao on 4/25/21.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var background: UIImageView!
    @IBOutlet var quotes: UIImageView!
    
    let quote = Bundle.main.decode([Quote].self, from: "quotes.json")
    let images = Bundle.main.decode([String].self, from: "pictures.json")

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

}

extension Bundle{
    func decode<T: Decodable>(_ type: T.Type, from file: String) -> T {
        guard let url = Bundle.main.url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in app bundle.")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) in app bundle.")
        }
        
        let decoder = JSONDecoder()
        
        guard let loaded = try? decoder.decode(T.self, from: data) else {
            
            fatalError("Failed to decode \(file) from app bundle.")
        }
        
        return loaded
    }
    
}
