//
//  LocationInputCell.swift
//  UberClone
//
//  Created by Juan Souza on 25/03/20.
//  Copyright © 2020 Juan Souza. All rights reserved.
//

import UIKit
import MapKit

class LocationInputCell: UITableViewCell {

    //MARK: - Properties
    
    var placemark: MKPlacemark?{
        didSet{
            titleLabel.text = placemark?.name
            addressLabel.text = placemark?.address
        }
    }
    
    var type: LocationType? {
        didSet{
            titleLabel.text = type?.description
            addressLabel.text = type?.subtitle
        }
    }
    
     let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private let addressLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        return label
    }()
    
    //MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        let stack = UIStackView(arrangedSubviews: [titleLabel,addressLabel])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 4
        
        addSubview(stack)
        stack.centerY(inView: self, leftAncor: leftAnchor, paddingLeft: 12)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
