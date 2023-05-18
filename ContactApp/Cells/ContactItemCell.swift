//
//  ContactItemCell.swift
//  ContactApp
//
//  Created by Hamzhya Salsatinnov on 18/05/23.
//

import UIKit

class ContactItemCell: UICollectionViewCell {
    @IBOutlet weak var name_label: UILabel!
    @IBOutlet weak var shapeContact: UIView!
    @IBOutlet weak var stackView: UIStackView!
    
    static let identifier = "ContactItemCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        shapeContact.translatesAutoresizingMaskIntoConstraints = false
        name_label.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 14
        
        let screenWidth = UIScreen.main.bounds.width
            let shapeSize = screenWidth / 5
        
        shapeContact.layer.cornerRadius = shapeSize / 2
        shapeContact.backgroundColor = .orange
        
        stackView.addArrangedSubview(shapeContact)
        stackView.addArrangedSubview(name_label)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14),
            
            shapeContact.widthAnchor.constraint(equalToConstant: shapeSize),
            shapeContact.heightAnchor.constraint(equalTo: shapeContact.widthAnchor)
        ])
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "ContactItemCell", bundle: nil)
    }

}
