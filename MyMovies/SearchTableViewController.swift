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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.placeholder = "Digite o nome do filme ou palavras chave"
        searchBar.delegate = self
        
        navigationItem.titleView = searchBar
        tableView.register(SearchTableViewCell.self, forCellReuseIdentifier: "searchCellIdentifier")
        
        tableView.tableFooterView = UIView()
        hideKeyboardWhenTappedAround()
    }
    
    func prepareSearchURL() -> String {
        let fixText = currentSearchText.replacingOccurrences(of: " ", with: "+")
        let url = searchURL + fixText.lowercased() + typeURL + pageURL + String(currentPage)
        print(url)
        return url
    }
    
    //MARK: - Load more data
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == (movies.count - 1) {
            if lastPage != currentPage {
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
    }
    
    //MARK: - Reloads tableview when text is deleted
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count == 0 {
            movies = []
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCellIdentifier", for: indexPath) as! SearchTableViewCell
        
        let moviePoster = movies[indexPath.row].poster
        cell.poster.image =  UIImage(data: moviePoster as! Data)
        if moviePoster != DEFAULT_IMAGE{
            cell.poster.contentMode = .scaleToFill
        } else {
            cell.poster.contentMode = .center
        }
        
        cell.title.text = movies[indexPath.row].title
        cell.year.text = String(movies[indexPath.row].year)
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
            
            self.navigationController?.pushViewController(self.detailsViewController, animated: true)
        }
        details.backgroundColor = .orange

        let favorite: UITableViewRowAction
        let realm = try! Realm()
        if realm.objects(Movie.self).filter("imdbID = %@", imdbID).count != 0 {
            favorite = UITableViewRowAction(style: .normal, title: "Descadastrar") { action, index in
                self.unfavorite(imdbID: imdbID)
            }
        }
        else {
            favorite = UITableViewRowAction(style: .normal, title: "Cadastrar") { action, index in
                self.addFavorite(imdbID: imdbID)
            }
        }
        favorite.backgroundColor = .black
        
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
                detailsViewController.setDetails(director: readableJSON["Actors"] as! String,
                                                 genre: readableJSON["Awards"] as! String,
                                                 awards: readableJSON["Director"] as! String,
                                                 plot: readableJSON["Genre"] as! String,
                                                 language: readableJSON["Language"] as! String,
                                                 actors: readableJSON["Plot"] as! String)

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
}
