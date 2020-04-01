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
        let sCont = UISearchController(searchResultsController: nil)
        return sCont
    }()
    
    lazy private var tableView: UITableView = {
        let table = UITableView()
        table.delegate = self
        table.dataSource = self
        table.rowHeight = self.config.cellRowHeight
        return table
    }()
    
    lazy private var countries: [ALCountry] = {
        return NSLocale.isoCountryCodes.compactMap({
            
            guard let name = self.locale?.localizedString(forRegionCode: $0) else {
                return nil
            }
            
            return ALCountry(name: name, isoCode: $0)
        }).sorted(by: <)
    }()
    
    lazy private var sectionedCountries: [ALSectionedCountries] = {
        let countries = self.countries
        let group = Dictionary(grouping: countries) { $0.name.first }
        
        let list = group.compactMap { (key, value) -> ALSectionedCountries? in
            guard let key = key else {
                return nil
            }
            return ALSectionedCountries(title: key.description, countries: value)
        }
        return list.sorted(by: <)
    }()
    
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
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isModal = isBeingPresented
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        tableView.frame = view.bounds
    }
    
    
    // MARK: - Helpers
    
    private func dismissPicker() {
        if isModal {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func getCountry(by indexPath: IndexPath) -> ALCountry {
        return config.sectionEnabled ? sectionedCountries[indexPath.section].countries[indexPath.row] : countries[indexPath.row]
    }
}


extension ALCountryPicker: UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        if config.sectionEnabled {
            return sectionedCountries.count
        }
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if config.sectionEnabled {
            return sectionedCountries[section].countries.count
        }
        return countries.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellID)
        
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: cellID)
            cell?.textLabel?.font = config.cellTitleFont
            cell?.detailTextLabel?.font = config.cellDetailFont
        }
        
        let country = getCountry(by: indexPath)
        
        cell?.textLabel?.text = country.name
        cell?.detailTextLabel?.text = country.isoCode
        return cell!
    }
}


extension ALCountryPicker: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let country = getCountry(by: indexPath)
        delegate?.countryPicker(picker: self, didSelect: country)
        dismissPicker()
    }
    
    public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if config.sectionEnabled {
            return sectionedCountries.map { $0.title }
        }
        return nil
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionedCountries[section].title
    }
}
