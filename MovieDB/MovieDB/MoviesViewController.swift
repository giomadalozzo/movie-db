//
//  MoviesViewController.swift
//  MovieDB
//
//  Created by Giovanni Madalozzo on 02/07/21.
//

import UIKit

struct Film: CustomStringConvertible{
    let id: Int
    let title: String
    let posterPath: String
    let overview: String
    let voteAverage: Double
    
    var description: String {
        return "ID: \(id), Title: \(title), Poster path: \(posterPath), Overview: \(overview), Vote: \(voteAverage) \n"
    }
}

struct MovieDBAPI{
    
    func requestNowPlaying(page: Int = 1, completionHandler: @escaping ([Film]) -> Void) {
        if page < 1 {fatalError("The page should be bigger than 1")}
        
        let urlString = "https://api.themoviedb.org/3/movie/now_playing?api_key=1b312813cf6df1bf51d1ada49057b17d&language=en-US&page=\(page)"
        let url = URL(string: urlString)!
        
        URLSession.shared.dataTask(with:  url) { (data, response, error) in
            
            typealias RMFilm = [String: Any]
            
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed),
                  let dictionary = json as? [String: Any],
                  let films = dictionary["results"] as? [RMFilm]
            else {
                completionHandler([])
                return
            }
            
            var localFilms: [Film] = []
            
            for filmDictionary in films {
                guard let id = filmDictionary["id"] as? Int,
                    let title = filmDictionary["title"] as? String,
                    let posterPath = filmDictionary["poster_path"] as? String,
                    let overview = filmDictionary["overview"] as? String,
                    let voteAverage = filmDictionary["vote_average"] as? Double
                else { continue }
                let film = Film(id: id, title: title, posterPath: posterPath, overview: overview, voteAverage: voteAverage)
                localFilms.append(film)
                
            }
            
            completionHandler(localFilms)
//            print(localFilms)
        }
        .resume()
        
    }
    
    func requestPopularMovies(page: Int = 1, completionHandler: @escaping ([Film]) -> Void) {
        if page < 1 {fatalError("The page should be bigger than 1")}
        
        let urlString = "https://api.themoviedb.org/3/movie/popular?api_key=1b312813cf6df1bf51d1ada49057b17d&language=en-US&page=\(page)"
        let url = URL(string: urlString)!
        
        URLSession.shared.dataTask(with:  url) { (data, response, error) in
            
            typealias RMFilm = [String: Any]
            
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed),
                  let dictionary = json as? [String: Any],
                  let films = dictionary["results"] as? [RMFilm]
            else {
                completionHandler([])
                return
            }
            
            var localFilms: [Film] = []
            
            for filmDictionary in films {
                guard let id = filmDictionary["id"] as? Int,
                    let title = filmDictionary["title"] as? String,
                    let posterPath = filmDictionary["poster_path"] as? String,
                    let overview = filmDictionary["overview"] as? String,
                    let voteAverage = filmDictionary["vote_average"] as? Double
                else { continue }
                let film = Film(id: id, title: title, posterPath: posterPath, overview: overview, voteAverage: voteAverage)
                localFilms.append(film)
                
            }
            
            completionHandler(localFilms)
//            print(localFilms)
        }
        .resume()
        
    }
}

class MoviesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    var filmsNowPlaying: [Film] = []
    var filmsPopular: [Film] = []
    var searchFilmsNowPlaying: [Film] = []
    var searchFilmsPopular: [Film] = []
    var searching = false
    
    let movieAPI = MovieDBAPI()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        
        tableView.refreshControl = refreshControl
        tableView.delegate = self
        tableView.dataSource = self
        searchController.searchBar.delegate = self
        
        navigationItem.searchController = searchController
        navigationItem.searchController?.automaticallyShowsCancelButton = false
        navigationItem.searchController?.automaticallyShowsSearchResultsController = true
        navigationItem.hidesSearchBarWhenScrolling = false
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        movieAPI.requestNowPlaying{ (films) in
            self.filmsNowPlaying = films
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        movieAPI.requestPopularMovies{ (films) in
            self.filmsPopular = films
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "Popular Movies"
        }else{
            return "Now Playing"
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).contentView.backgroundColor = UIColor.white
        (view as! UITableViewHeaderFooterView).textLabel?.font = UIFont(name: "System Bold", size: 17)
        (view as! UITableViewHeaderFooterView).textLabel?.textColor = UIColor.black
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            if searching{
                return self.searchFilmsPopular.count
            }else{
                return self.filmsPopular.count
            }
        }else{
            if searching{
                return self.searchFilmsNowPlaying.count
            }else{
                return self.filmsNowPlaying.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath) as? MoviesTableViewCell
        
        if indexPath.section == 1{
            if searching {
                let film = searchFilmsNowPlaying[indexPath.row]
                let url = URL(string: "https://image.tmdb.org/t/p/w500\(film.posterPath)")
                
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                    DispatchQueue.main.async {
                        cell?.imageCell.image = UIImage(data: data!)
                        cell?.imageCell.layer.cornerRadius = 15
                    }
                }
                
                cell?.titleCell.text = film.title
                cell?.textCell.text = film.overview
                cell?.starsCell.text = "􀋂 " + String(film.voteAverage)
            }else{
                let film = filmsNowPlaying[indexPath.row]
                let url = URL(string: "https://image.tmdb.org/t/p/w500\(film.posterPath)")
                
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                    DispatchQueue.main.async {
                        cell?.imageCell.image = UIImage(data: data!)
                        cell?.imageCell.layer.cornerRadius = 15
                    }
                }
                
                cell?.titleCell.text = film.title
                cell?.textCell.text = film.overview
                cell?.starsCell.text = "􀋂 " + String(film.voteAverage)
            }
        }else{
            if searching {
                let film = searchFilmsPopular[indexPath.row]
                let url = URL(string: "https://image.tmdb.org/t/p/w500\(film.posterPath)")
                
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                    DispatchQueue.main.async {
                        cell?.imageCell.image = UIImage(data: data!)
                        cell?.imageCell.layer.cornerRadius = 15
                    }
                }
                
                cell?.titleCell.text = film.title
                cell?.textCell.text = film.overview
                cell?.starsCell.text = "􀋂 " + String(film.voteAverage)
            }else{
                let film = filmsPopular[indexPath.row]
                let url = URL(string: "https://image.tmdb.org/t/p/w500\(film.posterPath)")
                
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                    DispatchQueue.main.async {
                        cell?.imageCell.image = UIImage(data: data!)
                        cell?.imageCell.layer.cornerRadius = 12
                    }
                }
                
                cell?.titleCell.text = film.title
                cell?.textCell.text = film.overview
                cell?.starsCell.text = "􀋂 " + String(film.voteAverage)
            }
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60.0
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searching = true
        searchFilmsPopular = []
        searchFilmsNowPlaying = []
        if searchBar.text == ""{
            searching = false
        }else{
            for film in filmsPopular {
                if film.title.lowercased().prefix(searchText.count) == searchText.lowercased() {
                    searchFilmsPopular.append(film)
                }
            }
            
            for film in filmsNowPlaying {
                if film.title.lowercased().prefix(searchText.count) == searchText.lowercased() {
                    searchFilmsNowPlaying.append(film)
                }
            }
        }
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = ""
        searchFilmsPopular = []
        searchFilmsNowPlaying = []
        tableView.reloadData()
    }
}
