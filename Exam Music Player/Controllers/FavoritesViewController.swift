import UIKit
import Alamofire

class FavoritesViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var editBtn: UIBarButtonItem!
    @IBAction func onEditTap(_ sender: Any) {
        if(self.tableView.isEditing == false) {
            self.tableView.isEditing = true
            self.editBtn.title = "Done"
        } else {
            self.tableView.isEditing = false
            self.editBtn.title = "Edit"
        }
    }
    
    var recommendedArtists = [Results]()
    var favTracks = [TrackEntity]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getTracks()
        if !self.favTracks.isEmpty {
            fetchRecommendedArtists()
        }
    }
    
    func getTracks() {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            if let coreDataTracks = try? context.fetch(TrackEntity.fetchRequest()) {
                if let tracks = coreDataTracks as? [TrackEntity] {
                    self.favTracks = tracks
                    tableView.reloadData()
                }
            }
        }
    }
    
    func fetchRecommendedArtists() {
        self.recommendedArtists = []
        getRecommendedArtists{ (artists, error) in
            if let error = error {
                print("failed to fetch artists: ", error)
                return
            }
            artists?.similar.results.forEach( { (artist) in
                if(artist.mediaType == "music") {
                    self.recommendedArtists.append(artist)
                }
            })
            self.collectionView.reloadData()
        }
    }
    
    func getRecommendedArtists(completion: @escaping (RecommendedArtist?, Error?) -> Void) {
        
        let url = "https://tastedive.com/api/similar?k=291717-MusicOrg-PXN2W11D"
        
        let parameters = ["q": (getRecommendedParameters())]
        
        AF.request(url, method: .get, parameters: parameters)
            .responseJSON { response in
                switch response.result {
                case .success:
                    if let jsonData = response.data {
                        let jsonDecoder = JSONDecoder()
                        do {
                            let artists = try jsonDecoder.decode(RecommendedArtist.self, from: jsonData)
                            completion(artists, nil)
                        }catch let error{
                            print("error: ", error)
                        }
                    }
                case .failure(let error):
                    print("Error: \(error)")
                    completion(nil, error)
                }
        }
    }
    
    //Formats the parameters for API request
    func getRecommendedParameters() -> String {
        var parameters = ""
        
        var favArtists: [String] = []
        
        for track in favTracks {
            if let trackArtist = track.artist {
                favArtists.append(trackArtist)
            }
        }
        //Makes sure there are no duplicate parameters by adding artists into set
        let noDuplicateFavArtists = Array(Set(favArtists))
        
        for artist in noDuplicateFavArtists {
            parameters.append("\(artist), ")
        }
        let resultParameters = String(parameters.dropLast(2))
        return resultParameters
    }
}

//Favorites Table View
extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favTracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath) as! FavoriteTableViewCell
        
        cell.trackLabel.text = favTracks[indexPath.row].title
        cell.artistLabel.text = favTracks[indexPath.row].artist
        cell.durationLabel.text = favTracks[indexPath.row].duration
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = self.favTracks[sourceIndexPath.row]
        favTracks.remove(at: sourceIndexPath.row)
        favTracks.insert(movedObject, at: destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Track deleted")
            
            if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
                context.delete(favTracks[indexPath.row])
                (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
                self.favTracks.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            }
            if self.favTracks.isEmpty {
                self.recommendedArtists = []
                self.collectionView.reloadData()
            } else {
                self.fetchRecommendedArtists()
            }
        }
    }
}

//Recommended Collection View
extension FavoritesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recommendedArtists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecommendedCell", for: indexPath) as! RecommendedCollectionViewCell
        
        cell.recommendedArtistLabel.text = recommendedArtists[indexPath.item].name
        return cell
    }
}
