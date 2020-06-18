import Alamofire
import UIKit
import Kingfisher

class TopViewController: UIViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    //Here tableView or CollectionView gets hidden when you toggle the segmented control
    @IBAction func valueChanged(_ sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            tableView.alpha = 0
            collectionView.alpha = 1
        case 1:
            tableView.alpha = 1
            collectionView.alpha = 0
        default:
            break;
        }
    }
    
    var topAlbumsArray: [Loved] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "TopAlbumTableViewCell", bundle: nil), forCellReuseIdentifier: "TableCell")
        
        tableView.alpha = 0
        collectionView.alpha = 1
        
        //Calls on getAlbums and adds to array
        getAlbums { (albums, error) in
            if let error = error {
                print("failed to fetch albums: ", error)
                return
            }
            albums?.loved.forEach( { (album) in
                self.topAlbumsArray.append(album)
            })
            self.collectionView.reloadData()
            self.tableView.reloadData()
        }
    }
    
    //Call API
    func getAlbums(completion: @escaping (TopAlbum?, Error?) -> Void) {
        
        AF.request("https://theaudiodb.com/api/v1/json/1/mostloved.php?format=album", method: .get)
            .responseJSON { response in
                switch response.result {
                case .success:
                    if let jsonData = response.data {
                        let jsonDecoder = JSONDecoder()
                        do {
                            let albums = try jsonDecoder.decode(TopAlbum.self, from: jsonData)
                            
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
}

//COLLECTION VIEW
extension TopViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.topAlbumsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCell", for: indexPath) as! TopAlbumCollectionViewCell
        
        cell.albumLabel.text = self.topAlbumsArray[indexPath.item].strAlbum
        cell.artistLabel.text = self.topAlbumsArray[indexPath.item].strArtist
        let imageUrl: String = self.topAlbumsArray[indexPath.item].strAlbumThumb ?? "album_placeholder"
        cell.albumImageView.kf.setImage(with: URL(string: imageUrl), placeholder: UIImage(named:"album_placeholder"))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let detailVc = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController
        detailVc?.albumId = self.topAlbumsArray[indexPath.item].idAlbum
        detailVc?.albumName = self.topAlbumsArray[indexPath.item].strAlbum
        detailVc?.artistName = self.topAlbumsArray[indexPath.item].strArtist
        detailVc?.albumYear = self.topAlbumsArray[indexPath.item].intYearReleased
        detailVc?.albumImgUrl = self.topAlbumsArray[indexPath.item].strAlbumThumb!
        
        self.navigationController?.pushViewController(detailVc!, animated: true)
    }
}

//TABLE VIEW
extension TopViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.topAlbumsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath) as! TopAlbumTableViewCell
        
        cell.albumLabel.text = topAlbumsArray[indexPath.row].strAlbum
        cell.artistLabel.text = topAlbumsArray[indexPath.row].strArtist
        let imageUrl: String = topAlbumsArray[indexPath.row].strAlbumThumb ?? "placeholder"
        cell.albumImage.kf.setImage(with: URL(string: imageUrl), placeholder: UIImage(named:"album_placeholder"))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVc = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController
        detailVc?.albumId = self.topAlbumsArray[indexPath.item].idAlbum
        detailVc?.albumName = self.topAlbumsArray[indexPath.item].strAlbum
        detailVc?.artistName = self.topAlbumsArray[indexPath.item].strArtist
        detailVc?.albumYear = self.topAlbumsArray[indexPath.item].intYearReleased
        detailVc?.albumImgUrl = self.topAlbumsArray[indexPath.item].strAlbumThumb!
        
        self.navigationController?.pushViewController(detailVc!, animated: true)
    }
}


