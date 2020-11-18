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
    private typealias DataSourceFavoriteRijks = UICollectionViewDiffableDataSource<Section, ArtObject>
    
    private typealias DataSourceFavoriteTM = UICollectionViewDiffableDataSource<Section, Event>
    
    private var dataSourceFavoriteRijks: DataSourceFavoriteRijks!
    
    private var dataSourceFavoriteTM: DataSourceFavoriteTM!
    
    let db = DatabaseService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemRed
        configure()
        configureCollectionView()
        favoriteView.collectionViewFavorite.delegate = self
    }
    
    func configure() {
        switch state {
        case .rijks:
            configureDataSourceFavoriteRijks()
            fetchFavoriteArtItems()
        case .ticketMaster:
            configureDataSourceFavoriteTM()
            fetchFavoriteEventItems()
        }
    }
    
    private func configureCollectionView() {
        favoriteView.collectionViewFavorite.register(FavoriteCell.self, forCellWithReuseIdentifier: FavoriteCell.reuseIdentifier)
    }
    
    private func fetchFavoriteArtItems() {
        db.getAllFavoriteRijksItems { (result) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let artObjects):
                self.updateFavoriteSnapshotRijks(favoriteArtItems: artObjects)
            }
        }
    }
    
    private func fetchFavoriteEventItems() {
        db.getAllFavoriteDatabaseItems { [weak self] (result) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let dbEvents):
                DispatchQueue.main.async {
                    self?.updateFavoriteEventsSnapshot(favoriteEventItems: dbEvents)
                }
            }
        }
    }
    
    private func updateFavoriteSnapshotRijks(favoriteArtItems: [ArtObject]) {
        var snapshot = dataSourceFavoriteRijks.snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections([.main])
        snapshot.appendItems(favoriteArtItems)
        dataSourceFavoriteRijks.apply(snapshot, animatingDifferences: false)
    }
    
    private func updateFavoriteEventsSnapshot(favoriteEventItems: [Event]) {
        var snapshot = dataSourceFavoriteTM.snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections([.main])
        snapshot.appendItems(favoriteEventItems)
        dataSourceFavoriteTM.apply(snapshot, animatingDifferences: false)
    }
    
    private func configureDataSourceFavoriteTM() {
        dataSourceFavoriteTM = UICollectionViewDiffableDataSource<Section, Event>(collectionView: favoriteView.collectionViewFavorite, cellProvider: { (collectionView, indexPath, eventItem) -> UICollectionViewCell? in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FavoriteCell.reuseIdentifier, for: indexPath) as? FavoriteCell else {
                fatalError()
            }
            
            cell.eventNameLabel.text = eventItem.name
            return cell
        })
        var snapshot = dataSourceFavoriteTM.snapshot()
        snapshot.appendSections([.main])
        dataSourceFavoriteTM.apply(snapshot, animatingDifferences: false)
    }
    
    private func configureDataSourceFavoriteRijks() {
        dataSourceFavoriteRijks = UICollectionViewDiffableDataSource<Section, ArtObject>(collectionView: favoriteView.collectionViewFavorite, cellProvider: { (collectionView, indexPath, artItem) -> UICollectionViewCell? in
            
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
        
        var snapshot = dataSourceFavoriteRijks.snapshot()
        snapshot.appendSections([.main])
        dataSourceFavoriteRijks.apply(snapshot, animatingDifferences: false)
    }
    
}

extension FavoritesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let detailRijksViewController = DetailRijksViewController()

        guard let artItem = dataSourceFavoriteRijks.itemIdentifier(for: indexPath) else {
            fatalError()
        }
        
        detailRijksViewController.currentArtItem = artItem
        self.navigationController?.pushViewController(detailRijksViewController, animated: true)
    }
}
