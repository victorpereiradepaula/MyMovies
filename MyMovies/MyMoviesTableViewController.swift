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
    
    let detailsViewController = DetailsViewController()
    var movies: [Movie]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Favoritos"
        tableView.register(MyMoviesTableViewCell.self, forCellReuseIdentifier: "myMoviesCellIdentifier")
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
        let index = indexPath.row
        cell.director.text = movies[index].director
        cell.genre.text = movies[index].genre
        cell.language.text = movies[index].language
        
        let moviePoster = movies[index].poster
        cell.poster.image =  UIImage(data: moviePoster as Data)
        if moviePoster != DEFAULT_IMAGE{
            cell.poster.contentMode = .scaleToFill
        } else {
            cell.poster.contentMode = .center
        }
        
        cell.title.text = movies[index].title
        cell.year.text = String(movies[index].year)
        
        cell.separatorInset = UIEdgeInsets.zero
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 224
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let imdbID = self.movies[editActionsForRowAt.row].imdbID
        
        let details = UITableViewRowAction(style: .normal, title: "Detalhes") { action, index in
            self.detailsViewController.setDetails(movie: self.movies[editActionsForRowAt.row])
            self.navigationController?.pushViewController(self.detailsViewController, animated: true)
        }
        details.backgroundColor = .black
        
        let favorite = UITableViewRowAction(style: .destructive, title: "Remover") { action, index in
            let setFavoriteAlert = UIAlertController(title: "Favorito removido", message: "Favorito removido com sucesso.", preferredStyle: .alert)
            setFavoriteAlert.addAction(UIAlertAction(title:"Ok", style:UIAlertActionStyle.default){ action in
                self.tableView.isEditing = false
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
        return [favorite, details]
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func loadRealmMovies() {
        movies = []
        let realm = try! Realm()
        movies.append(contentsOf: realm.objects(Movie.self))
        if movies.count == 0 {
            self.setMessageOnTableFooterView(text: "Você não possui nenhum favorito.")
        } else {
            self.setMessageOnTableFooterView(text: "")
        }
    }

}
