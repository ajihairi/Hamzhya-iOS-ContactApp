//
//  ContactsListVC.swift
//  ContactApp
//
//  Created by Hamzhya Salsatinnov on 18/05/23.

import UIKit

class ContactsListVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet weak var grid_contact: UICollectionView!
    var contacts: [Contact] = []
    var isSearchBarVisible = false
    var searchBar: UISearchBar?
    var isSearchBarActive = false
    var refreshControl = UIRefreshControl()
    
var filteredContacts: [Contact] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.doGetContacts()
        
    // Add refresh control to collection view
        refreshControl.addTarget(self, action: #selector(refreshContacts), for: .valueChanged)
        grid_contact.refreshControl = refreshControl
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.viewDidLoad()
    }
    
    @objc private func refreshContacts() {
        // Perform data fetch or update operation
        
        // Example: Call doGetContacts() to fetch the contacts again
        doGetContacts()
    }
    
    private func handleDataFetchComplete() {
        
        // Stop the refresh control animation
        self.refreshControl.endRefreshing()
//        DispatchQueue.main.async {
//            // Stop the refresh control animation
//            self.refreshControl.endRefreshing()
//
//            // Reload the collection view data
//            self.grid_contact.reloadData()
//        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ContactDetailVC {
            if let indexPath = sender as? IndexPath {
                let contact: Contact
                if isSearching() {
                    contact = filteredContacts[indexPath.row]
                } else {
                    contact = contacts[indexPath.row]
                }
                vc.contacts = contacts // Pass the contacts array to ContactDetailVC
                vc.isEditingContact = true
                vc.firstName = contact.firstName
                vc.lastName = contact.lastName
                vc.email = contact.email
                vc.dob = contact.dob
            } else {
                vc.contacts = contacts // Pass the contacts array to ContactDetailVC
                vc.isEditingContact = false
            }
        }
    }
    
    private func setupUI() {
        self.grid_contact.register(ContactItemCell.nib(), forCellWithReuseIdentifier: ContactItemCell.identifier)

            let layout = GridViewLayout()
            grid_contact.collectionViewLayout = layout

            grid_contact.dataSource = self
            grid_contact.delegate = self

            searchButton.target = self
            searchButton.action = #selector(searchButtonTapped)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if searchBar.text?.isEmpty ?? true {
            searchBar.isHidden = true
            navigationItem.title = "Contacts"
        }
    }
    
    @objc private func searchButtonTapped() {
    // Activate the search bar
        if searchBar == nil {
            searchBar = UISearchBar()
            searchBar?.delegate = self
            searchBar?.placeholder = "Search Contacts"
        }
        
        if let searchBar = searchBar {
            searchBar.becomeFirstResponder()
            searchBar.isHidden = !searchBar.isHidden
            if searchBar.isHidden {
                navigationItem.titleView = nil
                navigationItem.title = "Contacts"
                isSearchBarVisible = false
                filteredContacts = contacts
                grid_contact.reloadData()
            } else {
                navigationItem.titleView = searchBar
                isSearchBarVisible = true
            }
        }
    }
    private func showSearchBar() {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.placeholder = "Search Contacts"
        navigationItem.titleView = searchBar
        
        searchBar.becomeFirstResponder()
    }

    private func hideSearchBar() {
        navigationItem.titleView = nil
    }
    
    private func doGetContacts() {
    
        guard let path = Bundle.main.path(forResource: "data", ofType: "json") else { return }
            let url = URL(fileURLWithPath: path)
            
            DispatchQueue.global().async { [weak self] in
                do {
                    let jsonData = try Data(contentsOf: url)
                    let contacts = try JSONDecoder().decode([Contact].self, from: jsonData)
                    
                    DispatchQueue.main.async {
                        self?.contacts = contacts
                        if !(self?.isSearchBarVisible ?? false) {
                            self?.filteredContacts = contacts
                        }
                        self?.handleDataFetchComplete() // Call the helper function to handle data fetch completion
                        
                        // Reload the collection view data here
                        self?.grid_contact.reloadData()
                    }
                } catch {
                    print("ERROR: \(error)")
                    DispatchQueue.main.async {
                        self?.handleDataFetchComplete() // Call the helper function to handle data fetch completion
                    }
                }
            }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isSearching() {
            return filteredContacts.count
        } else {
            return contacts.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContactItemCell", for: indexPath) as? ContactItemCell else {
            fatalError("ContactCell not found")
        }
        
        let contact: Contact
        if isSearching() {
            contact = filteredContacts[indexPath.row]
        } else {
            contact = contacts[indexPath.row]
        }
        
        if let firstName = contact.firstName,
           let lastName = contact.lastName {
            cell.name_label.text = "\(firstName) \(lastName)"
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "goToDetails", sender: indexPath)
        print("item clicked")
    }
    
    @objc func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredContacts = contacts.filter { contact in
            if let firstName = contact.firstName, let lastName = contact.lastName {
                let fullName = "\(firstName) \(lastName)"
                return fullName.lowercased().contains(searchText.lowercased())
            }
            return false
        }
        
        grid_contact.reloadData()
    }
    
    @IBAction func add(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "goToDetails", sender: nil)
    }
    
    private func isSearching() -> Bool {
        if let searchBar = navigationItem.titleView as? UISearchBar {
            return searchBar.text?.isEmpty == false
        }
        return false
    }
}

class GridViewLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }
        
        let availableWidth = collectionView.bounds.width - sectionInset.left - sectionInset.right - minimumInteritemSpacing
        let itemWidth = availableWidth / 2
    
        itemSize = CGSize(width: itemWidth, height: itemWidth)
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.layoutAttributesForItem(at: indexPath) else { return nil }
           
        if let cell = collectionView?.cellForItem(at: indexPath) as? ContactItemCell {
            let targetSize = CGSize(width: itemSize.width, height: CGFloat.greatestFiniteMagnitude)
            let fittedSize = cell.contentView.systemLayoutSizeFitting(targetSize,
                                                                      withHorizontalFittingPriority: .required,
                                                                      verticalFittingPriority: .fittingSizeLevel)
            attributes.frame.size = fittedSize
        }
           
        return attributes
    }
}
