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
    
    var currentPage = 1
    var lastPage = 1
    var currentSearchText = ""
    var searchBar = UISearchBar()
    
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.placeholder = "Digite o nome do filme ou palavras chave"
        searchBar.delegate = self
        
        navigationItem.titleView = searchBar
        tableView.register(SearchTableViewCell.self, forCellReuseIdentifier: "searchCellIdentifier")
        
        self.setMessageOnTableFooterView(text: "")
        hideKeyboardWhenTappedAround()
    }
    
    func prepareSearchURL() -> String {
        let fixText = currentSearchText.replacingOccurrences(of: " ", with: "+")
        let url = searchURL + fixText.lowercased() + typeURL + pageURL + String(currentPage)
        return url
    }
    
    func startActivityIndicator() {
        let size = UIScreen.main.bounds
        let width = size.width
        let height = size.height
        activityIndicator.center = CGPoint(x: width/2, y: height/3)
        activityIndicator.hidesWhenStopped = true
        self.tableView.tableFooterView?.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    func stopActivityIndicator() {
        activityIndicator.stopAnimating()
    }
    
    //MARK: - Load more data
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == (movies.count - 1) {
            if lastPage != currentPage {
               startActivityIndicator()
                currentPage += 1
                fetchInformation(url: prepareSearchURL(), details: false)
            }
        }
    }
    
    //MARK: - Search
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        currentSearchText = searchBar.text!
        movies = []
        currentPage = 1
        lastPage = 1
        fetchInformation(url: prepareSearchURL(), details: false)
        self.searchBar.resignFirstResponder()
        setMessageOnTableFooterView(text: "")
        startActivityIndicator()
    }
    
    //MARK: - Reloads tableview when text is deleted
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count == 0 {
            movies = []
            tableView.reloadData()
            setMessageOnTableFooterView(text: "")
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCellIdentifier", for: indexPath) as! SearchTableViewCell
        
        if Constants.isFavorite(imdbID: movies[indexPath.row].imdbID) {
            cell.backgroundColor = .orange
        } else {
            cell.backgroundColor = .white
        }
        
        let moviePoster = movies[indexPath.row].poster
        cell.poster.image =  UIImage(data: moviePoster as! Data)
        if moviePoster != DEFAULT_IMAGE{
            cell.poster.contentMode = .scaleToFill
        } else {
            cell.poster.contentMode = .center
        }
        
        cell.title.text = movies[indexPath.row].title
        cell.year.text = String(movies[indexPath.row].year)
        
        cell.separatorInset = UIEdgeInsets.zero
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 224
    }
    
    //MARK: - Swipe buttons
    override func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let imdbID = self.movies[editActionsForRowAt.row].imdbID!
        
        let details = UITableViewRowAction(style: .normal, title: "Detalhes") { action, index in
            
            let url = detailedURL + imdbID + typeURL
            self.fetchInformation(url: url, details: true)
            
            self.detailsViewController.setMainInformation(imdbID: imdbID,
                                                          poster: self.movies[editActionsForRowAt.row].poster,
                                                          title: self.movies[editActionsForRowAt.row].title,
                                                          year: self.movies[editActionsForRowAt.row].year)
        }
        details.backgroundColor = .black

        let favorite: UITableViewRowAction
        if Constants.isFavorite(imdbID: imdbID) {
            favorite = UITableViewRowAction(style: .destructive, title: "Remover") { action, index in
                self.unfavorite(imdbID: imdbID)
                tableView.beginUpdates()
                tableView.cellForRow(at: editActionsForRowAt)?.backgroundColor = .white
                tableView.endUpdates()
            }
        }
        else {
            favorite = UITableViewRowAction(style: .normal, title: "Adicionar") { action, index in
                self.addFavorite(imdbID: imdbID)
                tableView.beginUpdates()
                tableView.cellForRow(at: editActionsForRowAt)?.backgroundColor = .orange
                tableView.endUpdates()
            }
            favorite.backgroundColor = .orange
        }
        
        
        return [favorite, details]
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

extension SearchTableViewController {
    
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
                detailsViewController.setDetails(director: readableJSON["Director"] as! String,
                                                 genre: readableJSON["Genre"] as! String,
                                                 awards: readableJSON["Actors"] as! String,
                                                 plot: readableJSON["Plot"] as! String,
                                                 language: readableJSON["Language"] as! String,
                                                 actors: readableJSON["Actors"] as! String)

            } else {
                self.tableView.isEditing = false
                let noMoviesAlert = UIAlertController(title: "Falha ao carregar os dados", message: "Verifique sua conexão, caso o problema persista, tente mais tarde...", preferredStyle: .alert)
                noMoviesAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(noMoviesAlert, animated: true, completion: nil)
                return
            }
        }
        catch {
            self.tableView.isEditing = false
            let noMoviesAlert = UIAlertController(title: "Falha ao carregar os dados", message: "Verifique sua conexão, caso o problema persista, tente mais tarde...", preferredStyle: .alert)
            noMoviesAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(noMoviesAlert, animated: true, completion: nil)
            return
        }
        self.navigationController?.pushViewController(self.detailsViewController, animated: true)
    }
    
    func splitData(JSONData: Data) {
        do {
            let readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! JSONStandard
            if let search = readableJSON["Search"] {
                
                setLastPage(totalResults: Int(readableJSON["totalResults"] as! String)!)
                
                for i in 0..<search.count {
                    let item = search.objectAt(i)
                    let imageURL = item["Poster"] as! String
                    if let poster = NSData(contentsOf: URL(string: imageURL)!) {
                        self.movies.append(movie.init(imdbID: item["imdbID"] as! String,
                                                      title: item["Title"] as! String,
                                                      year: item["Year"] as! String,
                                                      poster: poster))
                    } else {
                        self.movies.append(movie.init(imdbID: item["imdbID"] as! String,
                                                      title: item["Title"] as! String,
                                                      year: item["Year"] as! String,
                                                      poster: DEFAULT_IMAGE))
                    }
                    if currentPage != 1 {
                        //tableView.beginUpdates()
                        tableView.insertRows(at: [IndexPath(row: (movies.count - 1), section: 0)], with: .none)
                        //tableView.endUpdates()
                    }
                }
            }
            else {
                movies = []
                stopActivityIndicator()
                setMessageOnTableFooterView(text: "Nenhum resultado encontrado")
            }
        }
        catch {
            let noMoviesAlert = UIAlertController(title: "Falha ao carregar os dados", message: "Verifique sua conexão, caso o problema persista, tente mais tarde...", preferredStyle: .alert)
            noMoviesAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        }
        stopActivityIndicator()
        if currentPage == 1 && movies.count != 0{
            stopActivityIndicator()
            setMessageOnTableFooterView(text: "")
            self.tableView.reloadData()
        }
    }
    
    func setLastPage(totalResults: Int) {
        if(currentPage == 1) {
            lastPage = (totalResults/10)
            if totalResults%10 != 0 {
                lastPage += 1
            }
        }
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
                    let noMoviesAlert = UIAlertController(title: "Falha ao tentar adicionar favorito", message: "Verifique sua conexão, caso o problema persista, tente mais tarde...", preferredStyle: .alert)
                    noMoviesAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(noMoviesAlert, animated: true, completion: nil)
                }
            }
            catch {
                let noMoviesAlert = UIAlertController(title: "Falha ao tentar adicionar favorito", message: "Verifique sua conexão, caso o problema persista, tente mais tarde...", preferredStyle: .alert)
                noMoviesAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(noMoviesAlert, animated: true, completion: nil)
            }
        })
    }
}
