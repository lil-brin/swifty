//
//  ViewController.swift
//  SwiftyCompanion
//
//  Created by Brin on 6/6/19.
//  Copyright © 2019 Brin. All rights reserved.
//

import UIKit

var selectedUsers = [[String: UserModel]]()

class SearchViewController: UIViewController {

    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        api = Api()
//        api?.getToken(success: { (_tokenData) in
//            tokenData = _tokenData
//            print(tokenData!.access_token)
//        }) { (error) in
//            print("error: ", error)
//        }
        self.searchButton.layer.cornerRadius = 8
        infoView.setView()
        infoView.pulsate()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    @IBAction func onSearchButton(_ sender: UIButton) {
        guard (tokenData?.access_token) != nil else {
            return
        }
        dismissKeyboard()
        var inArray = false
        var index = 0
        let login = self.loginTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if login == "" {
            sender.emptyLine()
            return
        } // pop-up alert for empty string
//        print(login!)
        sender.isEnabled = false
        if selectedUsers.count != 0 {
            for i in 0..<selectedUsers.count {
                if (selectedUsers[i][login!] != nil) {
                    inArray = true
                    index = i
                }
            }
        }
        if inArray {
            sender.isEnabled = true
            pushUserView(userModel : selectedUsers[index][login!]!)
        } else {
            api?.getUser(login: login!, success: { (userModel) in
            
                sender.isEnabled = true
                selectedUsers.append([login! : userModel])
                self.pushUserView(userModel: userModel)
            }, error: { (error) in
                sender.isEnabled = true
                sender.emptyLine()
                print(error) // pop-up alert for no user
            })
        }
    }
    
    func pushUserView(userModel: UserModel) {
//        let userVc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserViewController") as! UserViewController
        let userVc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserViewController") as! UserViewController
        userVc.user = userModel
        self.loginTextField.text = ""
        self.view.endEditing(true)
        self.navigationController?.pushViewController(userVc, animated: true)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UIView {
    func setView() {
        layer.cornerRadius = 20
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: -5.0, height: 5.0)
        layer.shadowRadius = 15.0
        layer.shadowOpacity = 0.7
    }
    func pulsate() {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.5
        pulse.fromValue = 0.97
        pulse.toValue = 1.0
        pulse.autoreverses = true
        pulse.repeatCount = 1.8
        pulse.initialVelocity = 0.8
        pulse.damping = 1.0
        
        layer.add(pulse, forKey: nil)
    }
}

extension UIButton {
    func emptyLine() {
        print("empty")
        let shake = CABasicAnimation(keyPath: "position")
        shake.duration = 0.1
        shake.repeatCount = 2
        shake.autoreverses = true
        shake.fromValue = NSValue(cgPoint: CGPoint(x: center.x - 8, y: center.y - 1))
        shake.toValue = NSValue(cgPoint: CGPoint(x: center.x + 8, y: center.y + 1))
        
        layer.add(shake, forKey: nil)
    }
}
