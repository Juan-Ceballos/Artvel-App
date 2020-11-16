//
//  FavotitesViewController.swift
//  ARTvel-App
//
//  Created by Juan Ceballos on 10/28/20.
//

import UIKit
import Kingfisher

class FavoritesViewController: UIViewController {

    let favoriteView = FavoritesView()
    
    override func loadView() {
        view = favoriteView
    }
    
    var state: AppState.State
    
    init(state: AppState.State) {
        self.state = state
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private enum Section {
        case main
    }
    
    // item in this, favorite model?
    // app state...
    private typealias DataSourceFavorite = UICollectionViewDiffableDataSource<Section, ArtObject>
    
    private var dataSourceFavorite: DataSourceFavorite!
    
    let db = DatabaseService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemRed
        configureCollectionView()
        configure()
        favoriteView.collectionViewFavorite.delegate = self
    }
    
    func configure() {
        fetchFavoriteArtItems()
        configureDataSourceFavorite()
    }
    
    private func configureCollectionView() {
        favoriteView.collectionViewFavorite.register(FavoriteCell.self, forCellWithReuseIdentifier: FavoriteCell.reuseIdentifier)
        configure()
    }
    
    private func fetchFavoriteArtItems() {
        db.getAllFavoriteRijksItems { (result) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let artObjects):
                self.updateFavoriteSnapshot(favoriteArtItems: artObjects)
            }
        }
    }
    
    private func fetchFavoriteEventItems() {
        
    }
    
    private func updateFavoriteSnapshot(favoriteArtItems: [ArtObject]) {
        var snapshot = dataSourceFavorite.snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections([.main])
        snapshot.appendItems(favoriteArtItems)
        dataSourceFavorite.apply(snapshot, animatingDifferences: false)
    }
    
    private func configureDataSourceFavorite() {
        dataSourceFavorite = UICollectionViewDiffableDataSource<Section, ArtObject>(collectionView: favoriteView.collectionViewFavorite, cellProvider: { (collectionView, indexPath, artItem) -> UICollectionViewCell? in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FavoriteCell.reuseIdentifier, for: indexPath) as? FavoriteCell else {
                fatalError()
            }
            
            let url = URL(string: artItem.webImage.url)
            cell.imageView.kf.indicatorType = .activity
            cell.imageView.kf.setImage(with: url, placeholder: UIImage(systemName: "book"), options: [.transition(.fade(0.2))], completionHandler:  { (result) in
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let kfImage):
                    print("done \(kfImage.source.url?.absoluteString ?? "")")
                }
            })
            cell.eventNameLabel.text = artItem.title
            return cell
        })
        
        var snapshot = dataSourceFavorite.snapshot()
        snapshot.appendSections([.main])
        dataSourceFavorite.apply(snapshot, animatingDifferences: false)
    }
    
}

extension FavoritesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let detailRijksViewController = DetailRijksViewController()

        guard let artItem = dataSourceFavorite.itemIdentifier(for: indexPath) else {
            fatalError()
        }
        
        detailRijksViewController.currentArtItem = artItem
        self.navigationController?.pushViewController(detailRijksViewController, animated: true)
    }
}
