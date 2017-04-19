//
//  Movie.swift
//  MyMovies
//
//  Created by Victor on 31/03/17.
//  Copyright © 2017 Victor. All rights reserved.
//

import RealmSwift
import  UIKit

class Movie: Object {
    
    dynamic var imdbID: String = ""
    dynamic var title: String = ""
    dynamic var year: String = ""
    dynamic var genre: String = ""
    dynamic var director: String = ""
    dynamic var language: String = ""
    dynamic var actors: String = ""
    dynamic var awards: String = ""
    dynamic var plot: String = ""
    dynamic var poster: NSData = UIImagePNGRepresentation(#imageLiteral(resourceName: "no_image"))! as NSData
    
    override static func primaryKey() -> String? {
        return "imdbID"
    }
    
}
