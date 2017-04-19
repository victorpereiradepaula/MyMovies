//
//  Constants.swift
//  MyMovies
//
//  Created by Victor on 03/04/17.
//  Copyright © 2017 Victor. All rights reserved.
//

import RealmSwift
import UIKit

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

extension UITableViewController {
    
    func unfavorite(imdbID: String) {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(realm.object(ofType: Movie.self, forPrimaryKey: imdbID)!)
        }
        let addMovieAlert = UIAlertController(title: "Favorito removido", message: "Favorito rmovido com sucesso.", preferredStyle: .alert)
        addMovieAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(addMovieAlert, animated: true, completion: nil)
    }
}
