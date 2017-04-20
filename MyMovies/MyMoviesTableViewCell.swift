//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Victor on 31/03/17.
//  Copyright © 2017 Victor. All rights reserved.
//

import UIKit
import RealmSwift

class MyMoviesTableViewCell: UITableViewCell {

    var movie: Movie? = nil
    
    var poster: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .lightGray
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
    
    let labelGenre: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: label.font.pointSize)
        label.text = "Gênero:"
        return label
    }()
    
    let genre: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let labelDirector: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: label.font.pointSize)
        label.text = "Diretor:"
        return label
    }()
    
    let director: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let labelLanguage: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: label.font.pointSize)
        label.text = "Idioma:"
        return label
    }()
    
    let language: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .white
        
        let labelStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [labelYear, labelGenre, labelDirector, labelLanguage])
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .vertical
            stackView.spacing = 8
            return stackView
        }()
        
        let stackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [year, genre, director, language])
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .vertical
            stackView.spacing = 8
            return stackView
        }()
        
        let otherStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [labelStackView, stackView])
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .horizontal
            stackView.spacing = 2
            return stackView
        }()
        
        let informationStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [title, otherStackView])
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
