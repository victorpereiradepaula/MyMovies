//
//  SearchTableViewController.swift
//  MyMovies
//
//  Created by Victor on 31/03/17.
//  Copyright © 2017 Victor. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift

class SearchTableViewController: UITableViewController, UISearchBarDelegate {
    
    struct movie {
        var imdbID: String!
        var title: String!
        var year: String!
        var poster: NSData!
    }
    
    let detailsViewController = DetailsViewController()
    var movies: [movie] = []
    var detailedMovie = Movie()
    
    let searchURL = "http://www.omdbapi.com/?s="
    let detailedURL = "http://www.omdbapi.com/?i="
    let typeURL = "&type=movie"
    let pageURL = "&page="
    var currentPage = 1
    var lastPage = 1
    var currentSearchText = ""
    
    var searchString = String()
    var searchBar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.placeholder = "Digite o nome de um filme"
        searchBar.delegate = self
        
        navigationItem.titleView = searchBar
        tableView.register(SearchTableViewCell.self, forCellReuseIdentifier: "searchCellIdentifier")
        
        tableView.tableFooterView = UIView()
        hideKeyboardWhenTappedAround()
    }
    
    func prepareURL() -> String {
        let fixText = currentSearchText.replacingOccurrences(of: " ", with: "+")
        let url = searchURL + fixText.lowercased() + typeURL + pageURL + String(currentPage)
        print(url)
        return url
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == (movies.count - 1) {
            if lastPage != currentPage {
                currentPage += 1
                fetchInformation(url: prepareURL(), details: false)
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        currentSearchText = searchBar.text!
        movies = []
        currentPage = 1
        lastPage = 1
        fetchInformation(url: prepareURL(), details: false)
        self.searchBar.resignFirstResponder()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCellIdentifier", for: indexPath) as! SearchTableViewCell
        if let moviePoster = movies[indexPath.row].poster {
            cell.poster.image =  UIImage(data: moviePoster as Data)
        } else {
            cell.poster.image = #imageLiteral(resourceName: "no_image")
        }
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
            self.detailsViewController.canFavorite = false
            let url = self.detailedURL + imdbID! + self.typeURL
            self.fetchInformation(url: url, details: true)
            self.detailsViewController.movie.imdbID = imdbID!
            self.detailsViewController.movie.title = self.movies[editActionsForRowAt.row].title
            self.detailsViewController.movie.year = self.movies[editActionsForRowAt.row].year
           // self.detailsViewController.movie.poster = self.movies[editActionsForRowAt.row].poster
            self.navigationController?.pushViewController(self.detailsViewController, animated: true)
        }
        more.backgroundColor = .orange
        let favorite: UITableViewRowAction
        let realm = try! Realm()
        if realm.objects(Movie.self).filter("imdbID = %@", imdbID!).count != 0 {
            favorite = UITableViewRowAction(style: .normal, title: "Descadastrar") { action, index in
                self.tableView.isEditing = false
                self.unfavorite(imdbID: self.movies[editActionsForRowAt.row].imdbID)
            }
        }
        else {
            favorite = UITableViewRowAction(style: .normal, title: "Cadastrar") { action, index in
                self.tableView.isEditing = false
                self.addFavorite(imdbID: self.movies[editActionsForRowAt.row].imdbID)
            }
        }
        favorite.backgroundColor = .black
        return [favorite, more]
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

extension SearchTableViewController {
    
    typealias JSONStandard = [String: AnyObject]
    
    func addFavorite(imdbID: String) {
        let url = self.detailedURL + imdbID + self.typeURL
        let favorite = Movie()
        favorite.imdbID = imdbID
        Alamofire.request(url).responseJSON(completionHandler: {
            response in
            do {
                let readableJSON = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! JSONStandard
                let dataCheck = readableJSON["Response"] as! String
                if dataCheck == "True" {
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
                    let addMovieAlert = UIAlertController(title: "Favorito adicionado", message: "\(favorite.title) adicionado aos favoritos com sucesso.", preferredStyle: .alert)
                    addMovieAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(addMovieAlert, animated: true, completion: nil)
                } else {
                    let failAddMoviesAlert = UIAlertController(title: "Falha ao tentar salvar favorito", message: "Problema desconhecido, verifique sua conexão.", preferredStyle: .alert)
                    failAddMoviesAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(failAddMoviesAlert, animated: true, completion: nil)
                }
            }
            catch {
                print(error)
            }
        })
    }
    
    func fetchInformation(url: String, details: Bool) {
        Alamofire.request(url).responseJSON(completionHandler: {
            response in
            if details {
                self.splitDetailsData(JSONData: response.data!)
            }
            else {
                self.splitData(JSONData: response.data!)
            }
        })
    }
    
    
    func splitDetailsData(JSONData: Data) {
        do {
            let readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! JSONStandard
            let dataCheck = readableJSON["Response"] as! String
            if dataCheck == "True" {
                detailedMovie.actors = readableJSON["Actors"] as! String
                detailedMovie.awards = readableJSON["Awards"] as! String
                detailedMovie.director = readableJSON["Director"] as! String
                detailedMovie.genre = readableJSON["Genre"] as! String
                detailedMovie.language = readableJSON["Language"] as! String
                detailedMovie.plot = readableJSON["Plot"] as! String
                self.detailsViewController.movie = self.detailedMovie
                self.detailsViewController.reloadData()
            } else {
                let noMoviesAlert = UIAlertController(title: "Falha ao carregar os detalhes", message: "Problema desconhecido, verifique sua conexão.", preferredStyle: .alert)
                noMoviesAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(noMoviesAlert, animated: true, completion: nil)
            }
        }
        catch {
            print(error)
        }
    }
    
    func splitData(JSONData: Data) {
        do {
            let readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! JSONStandard
            if let search = readableJSON["Search"] {
                
                if(currentPage == 1) {
                    let totalResults = Int(readableJSON["totalResults"] as! String)
                    lastPage = (totalResults!/10)
                    if totalResults!%10 != 0 {
                        lastPage += 1
                    }
                }
                
                for i in 0..<search.count {
                    let item = search.objectAt(i)
                    let imageURL = item["Poster"] as! String
                    if imageURL != "N/A" && imageURL != "" {
                        movies.append(movie.init(imdbID: item["imdbID"] as! String, title: item["Title"] as! String, year: item["Year"] as! String, poster: NSData(contentsOf: URL(string: imageURL)!)))
                    }
                    else {
                        movies.append(movie.init(imdbID: item["imdbID"] as! String, title: item["Title"] as! String, year: item["Year"] as! String, poster: UIImagePNGRepresentation(#imageLiteral(resourceName: "no_image"))! as NSData))
                    }
                }
            }
            else {
                movies = []
                let noMoviesAlert = UIAlertController(title: "Nenhum resultado encontrado", message: "Verifique o nome informado.\nLembre-se de fazer a busca pelo nome original do filme.", preferredStyle: .alert)
                noMoviesAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(noMoviesAlert, animated: true, completion: nil)
            }
        }
        catch {
            print(error)
        }
        self.tableView.reloadData()
    }
}

extension SearchTableViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SearchTableViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        self.searchBar.resignFirstResponder()
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.searchBar.resignFirstResponder()
    }
}
