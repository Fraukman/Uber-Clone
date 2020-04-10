//
//  SettingsController.swift
//  UberClone
//
//  Created by Juan Souza on 10/04/20.
//  Copyright © 2020 Juan Souza. All rights reserved.
//

import UIKit

private let reuseIdentifier = "LocationCell"

enum LocationType: Int, CaseIterable, CustomStringConvertible{
    
    case home
    case work
    
    var description: String{
        switch self {
        case .home: return "Home"
        case .work: return "Work"
        }
    }
    
    var subtitle: String{
        switch self {
        case .home: return "Add Home"
        case .work: return "Add Work"
        }
    }
}

class SettingsController: UITableViewController{
    //MARK: - Properties
    
    private let user: User
    
    private let locationManager = LocationHandler.shared.locationManager
    
    private lazy var infoHeader: UserInfoHeader = {
        let frame = CGRect(x: 0, y: 88, width: view.frame.width, height: 100)
        let view = UserInfoHeader(user: user, frame: frame)
        return view
    }()
    
    //MARK: - Lifeclycle
    
    init(user: User){
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        configureNavigationBar()
       
    }
    
    //MARK: - Helper Functions
    
    func configureTableView(){
        tableView.rowHeight = 60
        tableView.register(LocationInputCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.backgroundColor = .white
        tableView.tableHeaderView = infoHeader
        tableView.tableFooterView = UIView()
    }
    
    func configureNavigationBar(){
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barStyle = .black
        navigationItem.title = "Settings"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "baseline_clear_white_36pt_2x").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleDismissal))
    }
    
    //MARK: - Selectors
    
    @objc func handleDismissal(){
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: - UITableViewDelegate/DataSource

extension SettingsController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LocationType.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .backgroundColor
        
        let title = UILabel()
        title.font = UIFont.systemFont(ofSize: 16)
        title.textColor = .white
        title.text = "Favorites"
        view.addSubview(title)
        title.centerY(inView: view,leftAncor: view.leftAnchor, paddingLeft: 16)
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LocationInputCell
        
        guard let type = LocationType(rawValue: indexPath.row) else {return cell}
        cell.type = type
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let type = LocationType(rawValue: indexPath.row) else {return }
        guard let location = locationManager?.location else {return}
        let controller = AddLocationController(type: type, location: location )
        controller.delegate = self
        let nav = UINavigationController(rootViewController: controller)
        present(nav, animated: true, completion: nil)
    }
    
}

extension SettingsController: AddLocationControllerDelegate{
    func updateLocation(locationString: String, type: LocationType) {
        PassengerServices.shared.saveLocation(locationString: locationString, type: type) { (err, ref) in
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
}
