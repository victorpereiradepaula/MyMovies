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
        if !canFavorite {
            detailsView.director.text = "Loading..."
            detailsView.genre.text = "Loading..."
            detailsView.awards.text = "Loading..."
            detailsView.plot.text = "Loading..."
            detailsView.language.text = "Loading..."
            detailsView.actors.text = "Loading..."
        }
        setupFavoriteButton()
    }
    
    func setMainInformation(imdbID: String, poster: NSData, title: String, year: String) {
        movie.imdbID = imdbID
        movie.poster = poster
        movie.title = title
        movie.year = year
        
        detailsView.poster.image = UIImage(data: poster as Data)
        if poster != DEFAULT_IMAGE {
            detailsView.poster.contentMode = .scaleToFill
        } else {
            detailsView.poster.contentMode = .center
        }
        
        detailsView.title.text = title
        detailsView.year.text = year
        
        canFavorite = false
    }
    
    private func setDetails() {
        detailsView.director.text = movie.director
        detailsView.genre.text = movie.genre
        detailsView.awards.text = movie.awards
        detailsView.plot.text = movie.plot
        detailsView.language.text = movie.language
        detailsView.actors.text = movie.actors
    }
    
    func setDetails(movie: Movie) {
        
        setMainInformation(imdbID: movie.imdbID, poster: movie.poster, title: movie.title, year: movie.year)
        
        self.movie.director = movie.director
        self.movie.genre = movie.genre
        self.movie.awards = movie.awards
        self.movie.plot = movie.plot
        self.movie.language = movie.language
        self.movie.actors = movie.actors
        
        setDetails()
        
        canFavorite = true
    }
    
    func setDetails(director: String, genre: String, awards: String, plot: String, language: String, actors: String) {
        self.movie.director = director
        self.movie.genre = genre
        self.movie.awards = awards
        self.movie.plot = plot
        self.movie.language = language
        self.movie.actors = actors
        
        setDetails()
        
        canFavorite = true
    }
    
}

extension DetailsViewController {
    @objc func addFavorite() {
        if canFavorite {
            let realm = try! Realm()
            try! realm.write {
                realm.add(movie)
            }
            let setFavoriteAlert = UIAlertController(title: "Favorito adicionado", message: "\(movie.title) adicionado aos favoritos.", preferredStyle: .alert)
            setFavoriteAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(setFavoriteAlert, animated: true, completion: nil)
            setupFavoriteButton()
        } else {
            let setFavoriteAlert = UIAlertController(title: "Impossível adicionar favorito", message: "Aguarde que os dados sejam carregados antes de adicionar um filme como favorito.", preferredStyle: .alert)
            setFavoriteAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(setFavoriteAlert, animated: true, completion: nil)
        }
    }
    
    @objc func unfavorite() {
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
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_favorite_border"), style: .plain, target: self, action: #selector(DetailsViewController.addFavorite))
        }
    }
}
