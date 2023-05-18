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
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
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
        
        txt_firstName.delegate = self
        txt_lastName.delegate = self
        txt_email.delegate = self
        
        txt_firstName.returnKeyType = .next
        txt_lastName.returnKeyType = .next
        txt_email.returnKeyType = .next
        
    }
    
    private func setupUI() {
        self.img_contact.makeRounded()
        saveButton.isEnabled = false
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
    @IBAction func firstNameEditing(_ sender: UITextField) {
        updateSaveButtonState()
    }
    @IBAction func lastNameEditing(_ sender: UITextField) {
        updateSaveButtonState()
    }
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        updateSaveButtonState()
    }
    
    @IBAction func dateOfBirthValueChanged(_ sender: UITextField) {
        updateSaveButtonState()
    }
    
    private func updateSaveButtonState() {
        let firstName = txt_firstName.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let lastName = txt_lastName.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let email = txt_email.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let dob = dateOfBirth.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        // Enable save button if first name and last name are filled
        saveButton.isEnabled = !firstName.isEmpty && !lastName.isEmpty
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
        let firstName = txt_firstName.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let lastName = txt_lastName.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let email = txt_email.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let dob = dateOfBirth.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

            // Check if first name and last name are filled
            if firstName.isEmpty || lastName.isEmpty {
                // Display an alert or error message indicating that first name and last name are mandatory
                let alertController = UIAlertController(title: "Missing Information", message: "First name and last name are mandatory.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alertController, animated: true, completion: nil)

                // Update UI to indicate missing values (red border)
                if firstName.isEmpty {
                    txt_firstName.layer.borderColor = UIColor.red.cgColor
                } else {
                    txt_firstName.layer.borderColor = UIColor.clear.cgColor
                }
                if lastName.isEmpty {
                    txt_lastName.layer.borderColor = UIColor.red.cgColor
                } else {
                    txt_lastName.layer.borderColor = UIColor.clear.cgColor
                }

                return
            }
        
    // Reset the border color of the text fields
        txt_firstName.layer.borderColor = UIColor.clear.cgColor
        txt_lastName.layer.borderColor = UIColor.clear.cgColor


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
                print("item saved ya")
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

extension ContactDetailVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case txt_firstName:
            txt_lastName.becomeFirstResponder()
        case txt_lastName:
            txt_email.becomeFirstResponder()
        case txt_email:
            dateOfBirth.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}
