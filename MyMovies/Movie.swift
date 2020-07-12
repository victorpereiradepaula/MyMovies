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
    
    @objc dynamic var imdbID: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var year: String = ""
    @objc dynamic var genre: String = ""
    @objc dynamic var director: String = ""
    @objc dynamic var language: String = ""
    @objc dynamic var actors: String = ""
    @objc dynamic var awards: String = ""
    @objc dynamic var plot: String = ""
    @objc dynamic var poster = NSData()
    
    override static func primaryKey() -> String? {
        return "imdbID"
    }
}
