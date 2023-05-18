//
//  ContactDetailVC.swift
//  ContactApp
//
//  Created by Hamzhya Salsatinnov on 18/05/23.

import UIKit

class ContactDetailVC: UIViewController {
    
    @IBOutlet weak var img_contact: UIImageView!
    @IBOutlet weak var txt_firstName: UITextField!
    @IBOutlet weak var txt_lastName: UITextField!
    @IBOutlet weak var txt_email: UITextField!
    
    @IBOutlet weak var dateOfBirth: UITextField!
    
    var isEditingContact: Bool = false
    var firstName: String?
    var lastName: String?
    var email: String?
    var dob: String?
    var contacts: [Contact] = [] // Add the contacts array property

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.loadContactDetail()
        addCalendarIconToTextField()
    }
    
    private func setupUI() {
        self.img_contact.makeRounded()
    }
    
    private func loadContactDetail() {
        DispatchQueue.main.async {
            self.txt_firstName.text = self.firstName
            self.txt_lastName.text = self.lastName
            self.dateOfBirth.text = self.dob
            self.txt_email.text = self.email
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.showDatePicker))
                    self.dateOfBirth.addGestureRecognizer(tapGesture)
        }
    }
    
    private func loadContactData() {
        guard let fileURL = Bundle.main.url(forResource: "data", withExtension: "json") else {
               print("Contacts JSON file not found.")
               return
           }
           
           do {
               let jsonData = try Data(contentsOf: fileURL)
               contacts = try JSONDecoder().decode([Contact].self, from: jsonData)
           } catch {
               print("Error decoding contacts data: \(error)")
           }
    }
    
    @objc private func showDatePicker() {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(self.datePickerValueChanged), for: .valueChanged)
        
        let alertController = UIAlertController(title: "Select Date", message: nil, preferredStyle: .actionSheet)
        alertController.view.addSubview(datePicker)
        
        let doneAction = UIAlertAction(title: "Done", style: .default) { _ in
            self.updateSelectedDate(datePicker.date)
        }
        alertController.addAction(doneAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }

    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        updateSelectedDate(sender.date)
    }

    private func updateSelectedDate(_ date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let formattedDate = dateFormatter.string(from: date)
        
        dateOfBirth.text = formattedDate
    }
    
    private func addCalendarIconToTextField() {
            let calendarIcon = UIImage(systemName: "calendar")
            let calendarImageView = UIImageView(image: calendarIcon)
            calendarImageView.contentMode = .scaleAspectFit

            let iconContainerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
            iconContainerView.addSubview(calendarImageView)

            dateOfBirth.rightView = iconContainerView
            dateOfBirth.rightViewMode = .always
        }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        guard let firstName = txt_firstName.text, !firstName.isEmpty,
          let lastName = txt_lastName.text, !lastName.isEmpty,
          let email = txt_email.text, !email.isEmpty,
          let dob = dateOfBirth.text, !dob.isEmpty else {
        // Display an alert or error message indicating that required fields are missing
        return
    }

    if isEditingContact, var contact = contacts.first {
        // Update existing contact
        contact.firstName = firstName
        contact.lastName = lastName
        contact.email = email
        contact.dob = dob

        // Update the JSON data in the "data.json" file
        if let jsonData = JSONEncoderHelper.encode(contacts) {
            guard let fileURL = Bundle.main.url(forResource: "data", withExtension: "json") else {
                print("Data JSON file not found.")
                return
            }
            do {
                try jsonData.write(to: fileURL)
            } catch {
                print("Error updating contact data: \(error)")
            }
        }
    } else {
        // Create new contact
        let newContact = Contact(id: self.randomString(length: 10), firstName: firstName, lastName: lastName, email: email, dob: dob)
        contacts.append(newContact)

        // Save the new contact to the "data.json" file
        if let jsonData = JSONEncoderHelper.encode(contacts) {
            guard let fileURL = Bundle.main.url(forResource: "data", withExtension: "json") else {
                print("Data JSON file not found.")
                return
            }
            do {
                try jsonData.write(to: fileURL)
            } catch {
                print("Error saving contact data: \(error)")
            }
        }
    }

    // Display a success message or perform any other necessary actions
    print("Item saved")

    // Dismiss the view controller
    dismiss(animated: true)
    }
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    @IBAction func dismiss(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    
}
