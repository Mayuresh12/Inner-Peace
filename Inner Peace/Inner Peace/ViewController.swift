//
//  ViewController.swift
//  Inner Peace
//
//  Created by Mayuresh Rao on 4/25/21.
//

import UIKit
import UserNotifications

class ViewController: UIViewController {
    @IBOutlet var background: UIImageView!
    @IBOutlet var quotes: UIImageView!
    
    var shareQuote: Quote?
    
    let quote = Bundle.main.decode([Quote].self, from: "quotes.json")
    let images = Bundle.main.decode([String].self, from: "pictures.json")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (allowed, error) in
            if allowed {
                self.configureAlerts()
            }
        }
    }
    func configureAlerts() {
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()
        let shuffled = quote.shuffled()
        
        for i in 1...5 {
            let content = UNMutableNotificationContent()
            content.title = "Inner Peace"
            content.body = shuffled[i].text
            
            let alertDate = Date().byAdding(days: i)
            
            var dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: alertDate)
            dateComponents.hour = 10
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            
            center.add(request) { error in
                if let e = error {
                    print("Error \(e.localizedDescription)")
                }
            }
            
        }
    }
    
    func updateQuote() {
        guard let backgroundImageName = images.randomElement() else {
            fatalError("Unable to read an image.")
            
        }
        
        background.image = UIImage(named: backgroundImageName)
        
        guard let selectedQuote = quote.randomElement() else {
            fatalError("Unable to read a quote.")
        }
        shareQuote = selectedQuote
        let drawBounds = quotes.bounds.inset(by: UIEdgeInsets(top: 250, left: 250, bottom: 250, right: 250))
        
        var quoteRect = CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        var fontSize: CGFloat = 120
        var font: UIFont!
        
        var attrs: [NSAttributedString.Key: Any]!
        var str: NSAttributedString!
        
        while true {
            
            font = UIFont(name: "Georgia-Italic", size: fontSize)!
            attrs = [.font: font, .foregroundColor: UIColor.white]
            str = NSAttributedString(string: selectedQuote.text, attributes: attrs)
            quoteRect = str.boundingRect(with: CGSize(width: drawBounds.width, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
            
            if quoteRect.height > drawBounds.height {
                fontSize -= 4
            } else {
                break
            }
            
        }
        let format = UIGraphicsImageRendererFormat()
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(bounds: quoteRect.insetBy(dx: -30, dy: -30), format: format)
        quotes.image = renderer.image { ctx in
            for i in 1...5 {
                ctx.cgContext.setShadow(offset: .zero, blur: CGFloat(i * 2), color: UIColor.black.cgColor)
                str.draw(in: quoteRect)
            }
            str.draw(in: quoteRect)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateQuote()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        updateQuote()
    }
    
    @IBAction func shareTapped(_ sender: UIButton) {
        guard let quote = shareQuote else {
            fatalError("Attempted to share a quote that didn't exist.")
        }
        
        let shareMessage = "\"\(quote.text)\" — \(quote.author)"
        let ac = UIActivityViewController(activityItems: [quote.shareMessage], applicationActivities: nil)
        ac.popoverPresentationController?.sourceView = sender
        present(ac, animated: true)
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

extension Date {
    func byAdding(days: Int, to date: Date = Date()) -> Date {
        var dateComponents = DateComponents()
        dateComponents.day = days
        
        return Calendar.current.date(byAdding: dateComponents, to: date) ?? date
    }
}
