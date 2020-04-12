//
//  MenuHeader.swift
//  UberClone
//
//  Created by Juan Souza on 08/04/20.
//  Copyright © 2020 Juan Souza. All rights reserved.
//

import UIKit

class MenuHeader: UIView {
    
    //MARK: - Properties
    
    
    private let user: User
    
    private lazy var profileImageView: UIView = {
       let view = UIView()
        view.backgroundColor = .black
        
        view.addSubview(initalLabel)
        initalLabel.centerX(inView: view)
        initalLabel.centerY(inView: view)
        
        return view
    }()
    
    private lazy var initalLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 42)
        label.textColor = .white
        label.text = user.firstInitial
        return label
    }()
    
    private lazy var fullNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        label.text = user.fullname
        return label
    }()
    
    private lazy var emailLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = user.email
        label.textColor = .lightGray
        return label
    }()
    
    //MARK: - Lifecycle
    
    init(user: User, frame: CGRect) {
        self.user = user
        super.init(frame: frame)
        
        backgroundColor = .backgroundColor
               
               addSubview(profileImageView)
               profileImageView.anchor(top: topAnchor, left: leftAnchor, paddingTop: 4, paddingLeft: 12, width: 64, height: 64)
               profileImageView.layer.cornerRadius = 64 / 2
               
               let stack = UIStackView(arrangedSubviews: [fullNameLabel,emailLabel])
               stack.distribution = .fillEqually
               stack.spacing = 4
               stack.axis = .vertical
               addSubview(stack)
               stack.centerY(inView: profileImageView, leftAncor: profileImageView.rightAnchor, paddingLeft: 12)
    }
    

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Selectors
    
    
}
