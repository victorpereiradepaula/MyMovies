//
//  DetailsView.swift
//  MyMovies
//
//  Created by Victor on 31/03/17.
//  Copyright © 2017 Victor. All rights reserved.
//

import UIKit

class DetailsView: UIView {
    
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
    
    let labelActors: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: label.font.pointSize)
        label.text = "Atores:"
        return label
    }()
    
    let actors: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.sizeToFit()
        return label
    }()
    
    let labelAwards: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: label.font.pointSize)
        label.text = "Prêmios:"
        return label
    }()
    
    let awards: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.sizeToFit()
        return label
    }()
    
    let labelPlot: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: label.font.pointSize)
        label.text = "Enrredo:"
        return label
    }()
    
    let plot: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.sizeToFit()
        return label
    }()
    
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        backgroundColor = .white
        
        let labelStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [labelYear, labelDirector, labelLanguage])
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .vertical
            stackView.spacing = 8
            return stackView
        }()
        
        let stackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [year, director, language])
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .vertical
            stackView.spacing = 8
            return stackView
        }()
        
        let otherStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [labelStackView, stackView])
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .horizontal
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
        addSubview(labelGenre)
        addSubview(genre)
        addSubview(labelActors)
        addSubview(actors)
        addSubview(labelAwards)
        addSubview(awards)
        addSubview(labelPlot)
        addSubview(plot)
        let views = ["finalStackView": finalStackView, "labelActors": labelActors, "actors": actors, "labelAwards": labelAwards, "awards": awards, "labelPlot": labelPlot, "plot": plot, "labelGenre": labelGenre, "genre": genre] as [String : Any]
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[finalStackView]-[labelGenre]-2-[genre]-[labelActors]-2-[actors]-[labelAwards]-2-[awards]-[labelPlot]-2-[plot]", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[labelGenre]-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[genre]-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[labelActors]-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[actors]-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[labelAwards]-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[awards]-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[labelPlot]-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[plot]-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[poster(200)]", options: [], metrics: nil, views: ["poster": poster]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[poster(150)]", options: [], metrics: nil, views: ["poster": poster]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[finalStackView]-|", options: [], metrics: nil, views: views))

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
