//
//  UserViewController.swift
//  SwiftyCompanion
//
//  Created by Brin on 6/6/19.
//  Copyright © 2019 Brin. All rights reserved.
//

import Foundation
import UIKit

class UserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var user : UserModel?
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var barButton: UIBarButtonItem?
    @IBOutlet weak var skillTable: UITableView!
    @IBOutlet weak var projectTable: UITableView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var loginLagel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var mobileLabel: UILabel!
    @IBOutlet weak var walletLabel: UILabel!
    @IBOutlet weak var corrPointsLevel: UILabel!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var skillTitleLabel: UILabel!
    @IBOutlet weak var projectTitleLabel: UILabel!
    
    
    override func viewDidLoad() {
        super .viewDidLoad()
        
        self.skillTitleLabel.text = "Skills table"
        self.prepareTable(table: skillTable)
        self.projectTitleLabel.text = "Projects table"
        self.prepareTable(table: projectTable)

        profileImageView.layer.borderWidth = 0.5
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.borderColor = UIColor.black.cgColor
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        profileImageView.clipsToBounds = true
        
        self.displayNameLabel.text = self.user?.displayname
        self.loginLagel.text = self.user?.login ?? ""
        self.emailLabel.text = "📧 \(self.user?.email ?? "")"
        self.mobileLabel.text = "📱 \(self.user?.phone ?? "*none*")"
        self.walletLabel.text = "\(self.user?.wallet ?? 0)₳"
        self.corrPointsLevel.text = "🏅 \(self.user?.correctionPoint ?? 0)"
        self.locationLabel.text = "🏕 \(user?.location ?? " Unavailable")"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView === skillTable ? (user?.cursusUsers?[0].skills?.count)! : (user?.projectsUsers?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView === self.skillTable {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "skillCellIdentifier",
                for: indexPath) as! SkillCell
            let skill = self.user?.cursusUsers?[0].skills?[indexPath.row]
            cell.skillLabel.text = skill?.name
            cell.levelLabel.text = "\(skill?.level ?? 0) lvl"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "ProjectCellIdentifier",
                for: indexPath) as!
            ProjectCell
            let project = self.user?.projectsUsers?[indexPath.row]
            cell.nameLabel?.text = project?.project?.slug
            cell.markLabel?.text = "\(project?.finalMark ?? 0)"
            project?.status.map {
                switch $0 {
                case .finished:
                    project?.validated.map {
                        if $0 {
                            cell.backgroundColor = #colorLiteral(red: 0.5965349078, green: 0.9177438617, blue: 0.5940704942, alpha: 1)
                        } else {
                            cell.backgroundColor = #colorLiteral(red: 0.8726013303, green: 0.08616990596, blue: 0.05866009742, alpha: 0.8504120291)
                        }
                    }
                case .inProgress:
                    cell.backgroundColor = .lightGray
                case .creatingGroup:
                    cell.backgroundColor = .lightGray
                case .searchingGroup:
                    cell.backgroundColor = .lightGray
                default:
                    break
                }
            }
            return cell
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        profileImageView.downloaded(from: self.user?.imageURL ?? "")
    }
    
    @IBAction func onBackButton(_ sender: UIBarButtonItem) {
        self.user = nil
        navigationController?.popViewController(animated: true)
    }

    func prepareTable(table: UITableView) {
        table.dataSource = self
        table.delegate = self
        table.tableFooterView = UIView()
    }

}

extension UIImageView {
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage.init(data: data)
                else { return }
            DispatchQueue.main.async() {
                let size = image.size.width > image.size.height ? image.size.height : image.size.width
                self.image = image.croppedInRect(rect: CGRect(x: 0, y: 0, width: size, height: size))
            }
            }.resume()
    }
}

extension UIImage {
    func croppedInRect(rect: CGRect) -> UIImage {
        func rad(_ degree: Double) -> CGFloat {
            return CGFloat(degree / 180.0 * .pi)
        }
        
        var rectTransform: CGAffineTransform
        switch imageOrientation {
        case .left:
            rectTransform = CGAffineTransform(rotationAngle: rad(90)).translatedBy(x: 0, y: -self.size.height)
        case .right:
            rectTransform = CGAffineTransform(rotationAngle: rad(-90)).translatedBy(x: -self.size.width, y: 0)
        case .down:
            rectTransform = CGAffineTransform(rotationAngle: rad(-180)).translatedBy(x: -self.size.width, y: -self.size.height)
        default:
            rectTransform = .identity
        }
        rectTransform = rectTransform.scaledBy(x: self.scale, y: self.scale)
        
        let imageRef = self.cgImage!.cropping(to: rect.applying(rectTransform))
        let result = UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
        return result
    }
}
