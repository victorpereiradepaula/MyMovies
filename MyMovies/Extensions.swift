//
//  Extensions.swift
//  MyMovies
//
//  Created by Victor on 19/04/17.
//  Copyright © 2017 Victor. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire

extension UITableViewController {
    
    func unfavorite(imdbID: String) {
        self.tableView.isEditing = false
        let realm = try! Realm()
        try! realm.write {
            realm.delete(realm.object(ofType: Movie.self, forPrimaryKey: imdbID)!)
        }
        let addMovieAlert = UIAlertController(title: "Favorito removido", message: "Favorito removido com sucesso.", preferredStyle: .alert)
        addMovieAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(addMovieAlert, animated: true, completion: nil)
    }
    
    func addFavorite(imdbID: String) {
        self.tableView.isEditing = false
        let url = detailedURL + imdbID + typeURL
        let favorite = Movie()
        favorite.imdbID = imdbID
        Alamofire.request(url).responseJSON(completionHandler: {
            response in
            do {
                let readableJSON = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! JSONStandard
                let dataCheck = readableJSON["Response"] as! String
                if dataCheck == "True" {
                    let imageURL = readableJSON["Poster"] as! String
                    if let poster = NSData(contentsOf: URL(string: imageURL)!) {
                        favorite.poster = poster
                    } else {
                        favorite.poster = DEFAULT_IMAGE
                    }
                    favorite.title = readableJSON["Title"] as! String
                    favorite.year = readableJSON["Year"] as! String
                    favorite.actors = readableJSON["Actors"] as! String
                    favorite.awards = readableJSON["Awards"] as! String
                    favorite.director = readableJSON["Director"] as! String
                    favorite.genre = readableJSON["Genre"] as! String
                    favorite.language = readableJSON["Language"] as! String
                    favorite.plot = readableJSON["Plot"] as! String
                    let realm = try! Realm()
                    try realm.write {
                        realm.add(favorite, update: true)
                    }
                    let addMovieAlert = UIAlertController(title: "Favorito adicionado", message: "\(favorite.title) adicionado aos favoritos.", preferredStyle: .alert)
                    addMovieAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(addMovieAlert, animated: true, completion: nil)
                } else {
                    let failAddMoviesAlert = UIAlertController(title: "Falha ao tentar adicionar favorito", message: "Problema desconhecido, verifique sua conexão.", preferredStyle: .alert)
                    failAddMoviesAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(failAddMoviesAlert, animated: true, completion: nil)
                }
            }
            catch {
                print(error)
            }
        })
    }
}


