//
//  ContactCell.swift
//  ContactApp
//
//  Created by Hamzhya Salsatinnov on 18/05/23.
//

import UIKit

extension UIImageView {
    
    func makeRounded() {
        self.layer.masksToBounds = false
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
    }
}

