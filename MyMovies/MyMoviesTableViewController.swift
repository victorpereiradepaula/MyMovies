//
//  MyMoviesTableViewController.swift
//  MyMovies
//
//  Created by Victor on 31/03/17.
//  Copyright © 2017 Victor. All rights reserved.
//

import UIKit
import RealmSwift

class MyMoviesTableViewController: UITableViewController {
    
    var movies: [Movie]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Favoritos"
        tableView.register(MyMoviesTableViewCell.self, forCellReuseIdentifier: "myMoviesCellIdentifier")
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadRealmMovies()
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myMoviesCellIdentifier", for: indexPath) as! MyMoviesTableViewCell
        cell.director.text = movies[indexPath.row].director
        cell.genre.text = movies[indexPath.row].genre
        cell.language.text = movies[indexPath.row].language
        cell.poster.image =  UIImage(data: movies[indexPath.row].poster as Data)
        cell.title.text = movies[indexPath.row].title
        cell.year.text = String(movies[indexPath.row].year)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 224
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let imdbID = self.movies[editActionsForRowAt.row].imdbID
        let more = UITableViewRowAction(style: .normal, title: "Detalhes") { action, index in
            let detailsViewController = DetailsViewController()
            detailsViewController.movie = self.movies[editActionsForRowAt.row]
            detailsViewController.canFavorite = true
            self.navigationController?.pushViewController(detailsViewController, animated: true)
        }
        more.backgroundColor = .orange
        
        let favorite = UITableViewRowAction(style: .normal, title: "Remover") { action, index in
            let setFavoriteAlert = UIAlertController(title: "Favorito removido", message: "Favorito removido com sucesso.", preferredStyle: .alert)
            setFavoriteAlert.addAction(UIAlertAction(title:"Ok", style:UIAlertActionStyle.default){ action in
                let realm = try! Realm()
                realm.refresh()
                try! realm.write {
                    realm.delete(realm.object(ofType: Movie.self, forPrimaryKey: imdbID)!)
                }
                self.loadRealmMovies()
                tableView.deleteRows(at: [index], with: .automatic)
            })
            self.present(setFavoriteAlert, animated: true, completion: nil)
            
        }
        favorite.backgroundColor = .black
        return [favorite, more]
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func loadRealmMovies() {
        movies = []
        let realm = try! Realm()
        movies.append(contentsOf: realm.objects(Movie.self))
    }

}
