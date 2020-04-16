//
//  ALCityPicker.swift
//  ALCountryPickerKit
//
//  Created by Unal Celik on 16.04.2020.
//

import UIKit
public protocol ALCityPickerDelegate: class {
    func cityPicker(picker: ALCityPicker, didSelect city: ALCity)
}


final public class ALCityPicker: UIViewController {
    
    lazy private var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = config.searchBarTintColor
        searchController.searchBar.barTintColor = .white
        searchController.searchBar.isTranslucent = false
        extendedLayoutIncludesOpaqueBars = true
        
        if #available(iOS 13.0, *) {
            searchController.searchBar.searchTextField.backgroundColor = UIColor.lightText
            searchController.searchBar.isTranslucent = true
        } else {
            searchController.searchBar.barStyle = .blackOpaque
        }
        
        return searchController
    }()
    
    lazy private var tableView: UITableView = {
        let table = UITableView()
        table.delegate = self
        table.dataSource = self
        table.rowHeight = self.config.cellRowHeight
        table.keyboardDismissMode = .onDrag
        return table
    }()
    
    private var cellID = "cellIdentifier"
    
    
    // MARK: - Properties
    
    private var filteredCities: [ALCity]?
    
    private var cities: [ALCity] = []
    
    
    public var config: ALCityPickerConfig
    
    public weak var delegate: ALCityPickerDelegate?
    
    public init(config: ALCityPickerConfig? = nil) {
        self.config = config ?? ALCityPickerConfig()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View Life Cycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        
        if config.searchEnabled {
            setupSearchController()
        }
        
        getCitiesFromResources()
        
        tableView.reloadData()
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        tableView.frame = view.bounds
    }
    
    
    // MARK: - Setup
    
    private func setupSearchController() {
        if let customColor = config.searchBarTextColor {
            UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self])
                .defaultTextAttributes = [NSAttributedString.Key.foregroundColor: customColor]
        }
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.searchController = searchController
    }
    
    private func getCitiesFromResources() {
        let frameworkBundle = Bundle(for: ALCityPicker.self)
        let bundleURL = frameworkBundle.resourceURL?.appendingPathComponent("Resources.bundle")
        let resourceBundle = Bundle(url: bundleURL!)
        
        guard let path = resourceBundle?.path(forResource: "TurkeyCountries", ofType: "json") else {
            return
        }
        
        guard let data = try? NSData(contentsOfFile: path, options: NSData.ReadingOptions.mappedIfSafe) else {
            return
        }
        
        let json = try? JSONSerialization.jsonObject(with: Data(data), options: [])
        
        guard let cityDict = json as? [String: String] else { return }
        
        cities = cityDict.compactMap() {
            ALCity(name: $0.value, plateCode: Int($0.key) ?? 0)
        }.sorted(by: < )
        
        debugPrint(cities)
    }
    
    
    // MARK: - Helpers
    
    private func dismissPicker() {
        if isModal {
            if let nav = navigationController {
                nav.dismiss(animated: true, completion: nil)
            } else {
                dismiss(animated: true, completion: nil)
            }
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func relevantCities() -> [ALCity] {
        return filteredCities != nil ? filteredCities! : cities
    }
    
    private func searchCountry(text: String) {
        debugPrint("Searching: \(text)")
        
        if text.isEmpty {
            filteredCities = nil
            tableView.reloadData()
            return
        }
        
        let text = text.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        filteredCities = cities.filter({ (city) -> Bool in
            let target = city.name.uppercased()
            let val = target.range(of: text,
                                   options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive]) != nil
            return val
        })
        
        tableView.reloadData()
    }

}


// MARK: - TABLEVIEW DELEGATE & DATASOURCE
extension ALCityPicker: UITableViewDelegate, UITableViewDataSource {
    
    /// - DATASOURCE
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        relevantCities().count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellID)
        
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: cellID)
            cell?.textLabel?.font = config.cellTitleFont
            cell?.detailTextLabel?.font = config.cellDetailFont
        }
        
        let city = relevantCities()[indexPath.row]
        
        cell?.textLabel?.text = city.name
        cell?.detailTextLabel?.text = city.plateCode.description
        return cell!
    }
    
    /// - DELEGATE
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let city = relevantCities()[indexPath.row]
        delegate?.cityPicker(picker: self, didSelect: city)
        dismissPicker()
    }
}


// MARK: - UISEARCHCONTROLLER DELEGATE
extension ALCityPicker: UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {
        
    }
}

// MARK: - UISearchBarDelegate
extension ALCityPicker: UISearchBarDelegate {
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCountry(text: searchText)
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filteredCities = nil
        tableView.reloadData()
    }
}
