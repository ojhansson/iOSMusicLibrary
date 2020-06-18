import UIKit
import Alamofire
import Kingfisher

class SearchViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var resultAlbums: [Album] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
    }
    
    //When search button or return is clicked, API for album gets called,
    //then API for all albums by artist gets called, so you can also search for artist name
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        var albumParameters = ["" : ""]
        var artistParameters = ["" : ""]
        self.resultAlbums = []
        if let searchText = searchBar.text {
            albumParameters = ["a": (searchText)]
            artistParameters = ["s": (searchText)]
        }
        
        getAlbums(albumParameters) { (albums, error) in
            if let error = error {
                print("failed to fetch albums: ", error)
                return
            }
            albums?.album.forEach( { (album) in
                self.resultAlbums.append(album)
            })
            self.collectionView.reloadData()
        }
        
        getAlbums(artistParameters) { (albums, error) in
            if let error = error {
                print("failed to fetch albums: ", error)
                return
            }
            albums?.album.forEach( { (album) in
                self.resultAlbums.append(album)
            })
            self.collectionView.reloadData()
        }
    }
    
    //API
    func getAlbums(_ parameters: [String : String], completion: @escaping (SearchAlbum?, Error?) -> Void) {
        let url = "https://theaudiodb.com/api/v1/json/1/searchalbum.php"
        AF.request(url, method: .get, parameters: parameters)
            .responseJSON { response in
                switch response.result {
                case .success:
                    if let jsonData = response.data {
                        let jsonDecoder = JSONDecoder()
                        do {
                            let albums = try jsonDecoder.decode(SearchAlbum.self, from: jsonData)
                            
                            completion(albums, nil)
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
    
    //COLLECTION VIEW
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return resultAlbums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCell", for: indexPath) as! TopAlbumCollectionViewCell
        
        cell.albumLabel?.text = resultAlbums[indexPath.item].strAlbum
        cell.artistLabel?.text = resultAlbums[indexPath.item].strArtist
        
        var imgUrl = ""
        if let jsonImgUrl: String = resultAlbums[indexPath.item].strAlbumThumb {
            imgUrl = jsonImgUrl
        }
        
        cell.albumImageView.kf.setImage(with: URL(string: imgUrl), placeholder: UIImage(named:"album_placeholder"))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVc = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController
        detailVc?.albumId = self.resultAlbums[indexPath.item].idAlbum
        detailVc?.albumName = self.resultAlbums[indexPath.item].strAlbum
        detailVc?.artistName = self.resultAlbums[indexPath.item].strArtist
        detailVc?.albumYear = self.resultAlbums[indexPath.item].intYearReleased
        detailVc?.albumImgUrl = self.resultAlbums[indexPath.item].strAlbumThumb ?? "placeholder"
        
        self.navigationController?.pushViewController(detailVc!, animated: true)
    }
}


