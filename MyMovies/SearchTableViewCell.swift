//
//  SearchTableViewCell.swift
//  MyMovies
//
//  Created by Victor on 04/04/17.
//  Copyright © 2017 Victor. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    
    var movie: Movie? = nil
    
    var poster: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .lightGray
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    let title: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.numberOfLines = 0
        label.sizeToFit()
        label.textAlignment = .center
        return label
    }()
    
    let labelYear: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: label.font.pointSize)
        label.text = "Ano:"
        return label
    }()
    
    let year: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .white
        
        let yearStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [labelYear, year])
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .horizontal
            stackView.spacing = 2
            return stackView
        }()
        
        let informationStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [title, yearStackView])
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .vertical
            stackView.spacing = 8
            return stackView
        }()
        
        let finalStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [poster, informationStackView])
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .horizontal
            stackView.spacing = 8
            return stackView
        }()
        
        addSubview(finalStackView)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[poster(200)]", options: [], metrics: nil, views: ["poster": poster]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[poster(150)]", options: [], metrics: nil, views: ["poster": poster]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[finalStackView]-|", options: [], metrics: nil, views: ["finalStackView": finalStackView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[finalStackView]", options: [], metrics: nil, views: ["finalStackView": finalStackView]))
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
