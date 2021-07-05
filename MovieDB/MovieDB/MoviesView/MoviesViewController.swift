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
    let image: UIImage
    let overview: String
    let voteAverage: Double
    let genres: [Int]
    
    var description: String {
        return "ID: \(id), Title: \(title), Overview: \(overview), Vote: \(voteAverage) \n"
    }
}

struct Genres {
    let id: Int
    let genre: String
}

struct MovieDBAPI{
    
    func requestGenres(completionHandler: @escaping ([Genres]) -> Void) {
        let urlString = "https://api.themoviedb.org/3/genre/movie/list?api_key=1b312813cf6df1bf51d1ada49057b17d&language=en-US"
        let url = URL(string: urlString)!
    
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed),
                  let dictionary = json as? [String: Any],
                  let genres = dictionary["genres"] as? [[String: Any]]
            else {
                completionHandler([])
                return
            }
            
            var localGenres: [Genres] = []
            
            for genreDictionary in genres {
                guard let id = genreDictionary["id"] as? Int,
                      let genre = genreDictionary["name"] as? String
                else { continue }
                
                let genres = Genres(id: id, genre: genre)
                localGenres.append(genres)
            }
            
//            print(genres)
            completionHandler(localGenres)
        }
        .resume()
    }
    
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
                    let voteAverage = filmDictionary["vote_average"] as? Double,
                    let genres = filmDictionary["genre_ids"] as? [Int],
                    let url = URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)"),
                    let data = try? Data(contentsOf: url),
                    let image = UIImage(data: data)
                else { continue }
                
                let film = Film(id: id, title: title, image: image, overview: overview, voteAverage: voteAverage, genres: genres)
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
                    let voteAverage = filmDictionary["vote_average"] as? Double,
                    let genres = filmDictionary["genre_ids"] as? [Int],
                    let url = URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)"),
                    let data = try? Data(contentsOf: url),
                    let image = UIImage(data: data)
                else { continue }
                
                
                let film = Film(id: id, title: title, image: image, overview: overview, voteAverage: voteAverage, genres: genres)
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
    let refreshControl = UIRefreshControl()
    var filmsNowPlaying: [Film] = []
    var filmsPopular: [Film] = []
    var searchFilmsNowPlaying: [Film] = []
    var searchFilmsPopular: [Film] = []
    var genres: [Genres] = []
    var searching = false
    var page: Int = 2
    var lineSelected: Int?
    var sectionSelected: Int?
    
    let movieAPI = MovieDBAPI()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.isHidden = true
        tableView.refreshControl = refreshControl
        tableView.delegate = self
        tableView.dataSource = self
        searchController.searchBar.delegate = self
        refreshControl.addTarget(self, action: #selector(refreshTable(_:)), for: .valueChanged)
        
        navigationItem.searchController = searchController
        navigationItem.searchController?.automaticallyShowsCancelButton = false
        navigationItem.searchController?.automaticallyShowsSearchResultsController = true
        navigationItem.hidesSearchBarWhenScrolling = false
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        movieAPI.requestGenres{ (genres) in
            self.genres = genres
        }
        
        movieAPI.requestPopularMovies{ (films) in
            self.filmsPopular = films
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        movieAPI.requestNowPlaying{ (films) in
            self.filmsNowPlaying = films
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableView.isHidden = false
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        lineSelected = indexPath.row
        sectionSelected = indexPath.section
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
                
                cell?.imageCell.image = film.image
                cell?.imageCell.layer.cornerRadius = 15
                cell?.titleCell.text = film.title
                cell?.textCell.text = film.overview
                cell?.starsCell.text = String(film.voteAverage)
            }else{
                let film = filmsNowPlaying[indexPath.row]
                
                cell?.imageCell.image = film.image
                cell?.imageCell.layer.cornerRadius = 15
                cell?.titleCell.text = film.title
                cell?.textCell.text = film.overview
                cell?.starsCell.text = String(film.voteAverage)
            }
        }else{
            if searching {
                let film = searchFilmsPopular[indexPath.row]
                
                cell?.imageCell.image = film.image
                cell?.imageCell.layer.cornerRadius = 15
                cell?.titleCell.text = film.title
                cell?.textCell.text = film.overview
                cell?.starCell.image = UIImage(systemName: "star")
                cell?.starsCell.text = String(film.voteAverage)
            }else{
                let film = filmsPopular[indexPath.row]
                
                cell?.imageCell.image = film.image
                cell?.imageCell.layer.cornerRadius = 15
                cell?.titleCell.text = film.title
                cell?.textCell.text = film.overview
                cell?.starCell.image = UIImage(systemName: "star")
                cell?.starsCell.text = String(film.voteAverage)
            }
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if (indexPath.section == 1 && indexPath.row == filmsNowPlaying.count - 10) {
            movieAPI.requestNowPlaying(page: self.page){ (films) in
                self.filmsNowPlaying.append(contentsOf: films)
                self.page += 1
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
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
    
    @objc private func refreshTable(_ sender: Any) {
        fetchTableData()
    }
    
    private func fetchTableData() {
        movieAPI.requestPopularMovies{ (films) in
            self.filmsPopular = films
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        movieAPI.requestNowPlaying{ (films) in
            self.filmsNowPlaying = films
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let detailsView = segue.destination as? DetailsViewController
        
        lineSelected = tableView.indexPathForSelectedRow?.row
        sectionSelected = tableView.indexPathForSelectedRow?.section
        
        if sectionSelected == 0{
            detailsView?.film = self.filmsPopular[lineSelected!]
            detailsView?.genres = self.genres
        }else{
            detailsView?.film = self.filmsNowPlaying[lineSelected!]
            detailsView?.genres = self.genres
        }
    }
    
}
