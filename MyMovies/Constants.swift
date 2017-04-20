//
//  Constants.swift
//  MyMovies
//
//  Created by Victor on 03/04/17.
//  Copyright © 2017 Victor. All rights reserved.
//

import UIKit
import RealmSwift
class Constants {
    
    static func isFavorite(imdbID: String) -> Bool {
        let realm = try! Realm()
        let predicate = NSPredicate(format: "imdbID = %@", imdbID)
        let check = realm.objects(Movie.self).filter(predicate)
        if check.count != 0 {
            return true
        }
        return false
    }
    
}

let IMAGE_BACKGROUND = UIColor.lightGray
let DEFAULT_BACKGROUNDCOLOR = UIColor.black
let DEFAULT_TEXT_COLOR = UIColor.orange
let DEFAULT_IMAGE = NSData(data: UIImagePNGRepresentation(#imageLiteral(resourceName: "no_image"))!)

let searchURL = "http://www.omdbapi.com/?s="
let detailedURL = "http://www.omdbapi.com/?i="
let typeURL = "&type=movie"
let pageURL = "&page="


typealias JSONStandard = [String: AnyObject]


