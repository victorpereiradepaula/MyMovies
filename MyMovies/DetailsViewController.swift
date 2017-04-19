//
//  DetailsViewController.swift
//  MyMovies
//
//  Created by Victor on 31/03/17.
//  Copyright © 2017 Victor. All rights reserved.
//

import UIKit
import RealmSwift

class DetailsViewController: UIViewController {

    var movie = Movie()
    let detailsView = DetailsView()
    var canFavorite = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailsView.frame = view.frame
        let scrollView = UIScrollView(frame: view.frame)
        scrollView.backgroundColor = .white
        scrollView.isPagingEnabled = true
        scrollView.contentSize = view.bounds.size
        scrollView.addSubview(detailsView)
        view.addSubview(scrollView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        detailsView.poster.image = UIImage(data: movie.poster as Data)
        detailsView.title.text = movie.title
        detailsView.year.text = movie.year
        if !canFavorite {
            detailsView.director.text = "Loading..."
            detailsView.genre.text = "Loading..."
            detailsView.awards.text = "Loading..."
            detailsView.plot.text = "Loading..."
            detailsView.language.text = "Loading..."
            detailsView.actors.text = "Loading..."
        } else {
            reloadData()
        }
        setupFavoriteButton()
    }
    
    func reloadData() {
        detailsView.director.text = movie.director
        detailsView.genre.text = movie.genre
        detailsView.awards.text = movie.awards
        detailsView.plot.text = movie.plot
        detailsView.language.text = movie.language
        detailsView.actors.text = movie.actors
        canFavorite = true
    }
    
}

extension DetailsViewController {
    func favorite() {
        if canFavorite {
            let realm = try! Realm()
            try! realm.write {
                realm.create(Movie.self, value: ["poster": movie.poster, "title": movie.title, "year": movie.year, "genre": movie.genre, "imdbID": movie.imdbID, "director": movie.director, "actors": movie.actors, "awards": movie.awards, "language": movie.language, "plot": movie.plot], update: false)
            }
            let setFavoriteAlert = UIAlertController(title: "Favorito adicionado", message: "Novo favorito adicionado com sucesso.", preferredStyle: .alert)
            setFavoriteAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(setFavoriteAlert, animated: true, completion: nil)
            setupFavoriteButton()
        } else {
            let setFavoriteAlert = UIAlertController(title: "Impossível adicionar favorito", message: "Aguarde que os dados sejam carregados antes de adicionar um filme como favorito.", preferredStyle: .alert)
            setFavoriteAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(setFavoriteAlert, animated: true, completion: nil)
        }
    }
    
    func unfavorite() {
        let setFavoriteAlert = UIAlertController(title: "Favorito removido", message: "Favorito removido com sucesso.", preferredStyle: .alert)
        setFavoriteAlert.addAction(UIAlertAction(title:"Ok", style:UIAlertActionStyle.default){ action in
            let realm = try! Realm()
            realm.refresh()
            try! realm.write {
                realm.delete(realm.object(ofType: Movie.self, forPrimaryKey: self.movie.imdbID)!)
            }
            _ = self.navigationController?.popToRootViewController(animated: true)
        })
        present(setFavoriteAlert, animated: true, completion: nil)
    }
    
    func setupFavoriteButton() {
        if Constants.isFavorite(imdbID: movie.imdbID) {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_favorite"), style: .plain, target: self, action: #selector(DetailsViewController.unfavorite))
        }
        else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_favorite_border"), style: .plain, target: self, action: #selector(DetailsViewController.favorite))
        }
    }
}
