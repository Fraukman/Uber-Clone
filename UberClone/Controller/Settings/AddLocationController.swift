//
//  AddLocationController.swift
//  UberClone
//
//  Created by Juan Souza on 10/04/20.
//  Copyright © 2020 Juan Souza. All rights reserved.
//

import UIKit
import MapKit

private let reuseIdentifier = "Cell"

protocol AddLocationControllerDelegate: class{
    func updateLocation(locationString: String, type: LocationType)
}

class AddLocationController: UITableViewController {
    
    
    //MARK: - Properties
    
    private let searchBar = UISearchBar()
    private let searchCompleter = MKLocalSearchCompleter()
    private var searchResults = [MKLocalSearchCompletion](){
        didSet{
            tableView.reloadData()
        }
    }
    
    weak var delegate: AddLocationControllerDelegate?
    
    private let type: LocationType
    private let location: CLLocation
    
    //MARK: - Lifecycle
    
    init(type: LocationType, location: CLLocation){
        self.type = type
        self.location = location
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
           super.viewDidLoad()
           configureTableView()
        configureSeachBar()
        configureSearchCompleter()
       }
    
    //MARK: - Helper Functions

    func configureTableView(){
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 60
        
        tableView.addShadow()
    }
    
    func configureSeachBar(){
        searchBar.sizeToFit()
        searchBar.delegate = self
        navigationItem.titleView = searchBar
    }
    
    func configureSearchCompleter(){
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
        searchCompleter.region = region
        searchCompleter.delegate = self
    }
}

//MARK: - UITableView Delegate/DataSource

extension AddLocationController{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: reuseIdentifier)
        let result = searchResults[indexPath.row]
        cell.textLabel?.text = result.title
        cell.detailTextLabel?.text = result.subtitle
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let result = searchResults[indexPath.row]
        let title = result.title
        let subtitle = result.subtitle
        let locationString = title + " " + subtitle
        let timmedLocation = locationString.replacingOccurrences(of: ", Brazil", with: "")
        delegate?.updateLocation(locationString: timmedLocation, type: type)
    }
    
}

//MARK: - UISearchBarDelegate

extension AddLocationController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchText
    }
}

//MARK: - MKSearchCompleterDelegate

extension AddLocationController: MKLocalSearchCompleterDelegate{
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results

    }
}
