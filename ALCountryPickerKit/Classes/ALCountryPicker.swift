//
//  ALCountryPicker.swift
//  ALCountryPicker
//
//  Created by Soner Güler on 1.04.2020.
//  Copyright © 2020 Applogist. All rights reserved.
//

import UIKit

public protocol ALCountryPickerDelegate: class {
    func countryPicker(picker: ALCountryPicker, didSelect country: ALCountry)
}


final public class ALCountryPicker: UIViewController {
    
    lazy private var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = .white
        searchController.searchBar.barTintColor = .white
        searchController.searchBar.isTranslucent = false
        
        if #available(iOS 13.0, *) {
            searchController.searchBar.searchTextField.backgroundColor = UIColor.lightText
            searchController.searchBar.isTranslucent = true
            extendedLayoutIncludesOpaqueBars = true
        } else {
            searchController.searchBar.barStyle = .blackOpaque
            searchController.searchBar.tintColor = .white
        }
        
        return searchController
    }()
    
    lazy private var tableView: UITableView = {
        let table = UITableView()
        table.delegate = self
        table.dataSource = self
        table.rowHeight = self.config.cellRowHeight
        return table
    }()
    
    /// Raw country list
    lazy private var countries: [ALCountry] = {
        return NSLocale.isoCountryCodes.compactMap({
            
            guard let name = self.locale?.localizedString(forRegionCode: $0) else {
                return nil
            }
            
            return ALCountry(name: name, isoCode: $0)
        }).sorted(by: <)
    }()
    
    /// Searched country list
    private var filteredCountries: [ALCountry]?
    
    private var sectionedCountries: [ALSectionedCountries]?
    
    
    private let cellID = "CountryCell"
    
    private var isModal: Bool = false
    
    
    // MARK: - Public
    
    public var locale: Locale?
    
    public var config: ALCountryPickerConfig
    
    public weak var delegate: ALCountryPickerDelegate?
    
    
    public init(locale: Locale = .current, config: ALCountryPickerConfig? = nil) {
        self.locale = locale
        self.config = config ?? ALCountryPickerConfig()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        
        if config.searchEnabled {
            setupSearchController()
        }
        
        if config.sectionEnabled {
            sectionedCountries = getSectionedCountries()
        }
        
        tableView.reloadData()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isModal = isBeingPresented
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        tableView.frame = view.bounds
    }
    
    
    // MARK: - Setup
    
    private func setupSearchController() {
        navigationItem.searchController = searchController
    }
    
    
    // MARK: - Helpers
    
    private func dismissPicker() {
        if isModal {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    
    private func getCountry(by indexPath: IndexPath) -> ALCountry? {
        
        if config.sectionEnabled {
            return sectionedCountries?[indexPath.section].countries[indexPath.row]
        } else {
            return self.filteredCountries?[indexPath.row] ?? self.countries[indexPath.row]
        }
    }
    
    private func searchCountry(text: String) {
        debugPrint("Searching: \(text)")
        
        if text.isEmpty {
            filteredCountries = nil
            tableView.reloadData()
            return
        }
        
        let text = text.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        filteredCountries = countries.filter({ (country) -> Bool in
            let target = country.name.uppercased()
            let val = target.range(of: text,
                                   options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive]) != nil
            return val
        })
        
        if config.sectionEnabled {
            sectionedCountries = getSectionedCountries()
        }
        
        tableView.reloadData()
    }
    
    /// Returns sectioned country list according o raw countries
    private func getSectionedCountries() -> [ALSectionedCountries] {
        let countries = self.filteredCountries ?? self.countries
        let group = Dictionary(grouping: countries) { $0.name.first }
        
        let list = group.compactMap { (key, value) -> ALSectionedCountries? in
            guard let key = key else {
                return nil
            }
            return ALSectionedCountries(title: key.description, countries: value)
        }
        return list.sorted(by: <)
    }
}


extension ALCountryPicker: UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        if config.sectionEnabled {
            return sectionedCountries?.count ?? 0
        }
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if config.sectionEnabled {
            return sectionedCountries?[section].countries.count ?? 0
        }
        return filteredCountries?.count ?? countries.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellID)
        
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: cellID)
            cell?.textLabel?.font = config.cellTitleFont
            cell?.detailTextLabel?.font = config.cellDetailFont
        }
        
        let country = getCountry(by: indexPath)
        
        cell?.textLabel?.text = country?.name
        cell?.detailTextLabel?.text = country?.isoCode
        return cell!
    }
}


extension ALCountryPicker: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let country = getCountry(by: indexPath) {
            delegate?.countryPicker(picker: self, didSelect: country)
        }
        dismissPicker()
    }
    
    public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if config.sectionEnabled {
            return sectionedCountries?.map { $0.title }
        }
        return nil
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionedCountries?[section].title
    }
}

extension ALCountryPicker: UISearchBarDelegate {
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCountry(text: searchText)
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filteredCountries = nil
        if config.sectionEnabled {
            sectionedCountries = getSectionedCountries()
        }
        tableView.reloadData()
    }
}

extension ALCountryPicker: UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {
        
    }
}
