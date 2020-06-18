import UIKit
import Kingfisher
import Alamofire

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var albumLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var trackTableView: UITableView!
    
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    var albumTracksArray: [Track] = []
    
    var albumId = ""
    var artistName = ""
    var albumName = ""
    var albumYear = ""
    var albumImgUrl = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        albumLabel.text = albumName
        artistLabel.text = artistName
        yearLabel.text = albumYear
        albumImage.kf.setImage(with: URL(string: albumImgUrl), placeholder: UIImage(named:"album_placeholder"))
        
        getTracks { (tracks, error) in
            if let error = error {
                print("failed to fetch tracks: ", error)
                return
            }
            tracks?.track.forEach( { (track) in
                self.albumTracksArray.append(track)
            })
            self.trackTableView.reloadSections(IndexSet(integer: 0), with:UITableView.RowAnimation.none)
        }
    }
    
    //Get tracks on current album from API
    func getTracks(completion: @escaping (AlbumTrack?, Error?) -> Void) {
        
        let url = "https://theaudiodb.com/api/v1/json/1/track.php?m=\(albumId)"
        AF.request(url, method: .get)
            .responseJSON { response in
                switch response.result {
                case .success:
                    if let jsonData = response.data {
                        let jsonDecoder = JSONDecoder()
                        do {
                            let tracks = try jsonDecoder.decode(AlbumTrack.self, from: jsonData)
                            
                            completion(tracks, nil)
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
    
    //Turns the duration from API into a minute:seconds string format
    func formatDuration(_ msStringDuration: String) -> String {
        let msDuration = (Int(msStringDuration)! / 1000)
        if(msDuration == 0) {
            return "?"
        }
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        let formattedDuration = formatter.string(from: TimeInterval(msDuration))!
        
        return formattedDuration  
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albumTracksArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath) as! AlbumTrackTableViewCell
        
        cell.trackNameLabel.text = self.albumTracksArray[indexPath.item].strTrack
        cell.durationLabel.text = formatDuration(self.albumTracksArray[indexPath.item].intDuration)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            let newFavTrack = TrackEntity(context: context)
            newFavTrack.title = self.albumTracksArray[indexPath.item].strTrack
            newFavTrack.artist = self.albumTracksArray[indexPath.item].strArtist
            newFavTrack.duration = formatDuration(self.albumTracksArray[indexPath.item].intDuration)
            showToast(controller: self, message: "Track added to favorites")
            (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
        }
    }
    
    //Denne fikk jeg inspirasjon herfra til å lage en alert som minner om en toast fra andre språk: https://medium.com/@rushikeshT/displaying-simple-toast-in-ios-swift-57014cbb9ffa
    func showToast(controller: UIViewController, message : String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.view.backgroundColor = .gray
        alert.view.alpha = 0.5
        alert.view.layer.cornerRadius = 15
        controller.present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            alert.dismiss(animated: true)
        }
    }
}

