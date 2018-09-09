//
//  MasterVC.swift
//  Turtles
//
//  Created by Blaine Solomon on 9/9/18.
//  Copyright © 2018 Solomon. All rights reserved.
//

import UIKit
import GiphyCoreSDK
import AlamofireImage
import Alamofire
import Messages

class MasterVC: UICollectionViewController, UISearchControllerDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSearchBar()
        setupGiphyCore()
        setupTrendingGIFs()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = true
    }

    // MARK: - Setup

    func setupGiphyCore() {
        GiphyCore.shared.apiKey = "COILmFBJEQEWZARFoCdE5DdvGXztL7TE"
    }

    func setupTrendingGIFs() {
        searchResults.removeAll()
        collectionView?.reloadData()
        GiphyCore.shared.trending(completionHandler: { [weak self] response, error in
            guard let serverItems = response?.data?.compactMap({
                return ImageItem(mediaItem: $0)
            }) else {
                return
            }

            OperationQueue.main.addOperation {
                self?.searchResults.append(contentsOf: serverItems)
                self?.collectionView?.reloadData()
            }
        })
    }

    func setupSearchBar() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.tintColor = navigationController?.navigationBar.tintColor
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.keyboardAppearance = .dark
        searchController.searchBar.placeholder = "Search Giphy"
        navigationItem.searchController = searchController
    }

    // MARK: - Collection View

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchResults.count
    }

    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as! CollectionViewCell
        cell.imageView.af_cancelImageRequest()
        cell.imageView.image = nil
        cell.stickerView.stopAnimating()
        cell.stickerView.sticker = nil
    }

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as! CollectionViewCell
        let item = searchResults[indexPath.item]

        guard let thumbnailURL = item.thumbnailURL else {
            return
        }

        guard let mediaID = item.mediaID else {
            return
        }

        guard let gifURL = item.gifURL else {
            return
        }

        cell.imageView.af_setImage(withURL: thumbnailURL, progressQueue: DispatchQueue.main, imageTransition: .crossDissolve(0.2), runImageTransitionIfCached: true)

        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let fileURL = FileManager.default.gifURL(with: mediaID)
            return (fileURL, [.createIntermediateDirectories])
        }

        Alamofire.download(gifURL, to: destination).responseData(completionHandler: { response in
            guard let imageURL = response.destinationURL else {
                return
            }

            guard let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell else {
                return
            }

            do {
                cell.stickerView.sticker = try MSSticker(contentsOfFileURL: imageURL, localizedDescription: "")
                cell.imageView.af_cancelImageRequest()
                cell.imageView.image = nil
                cell.stickerView.startAnimating()
            } catch  {

            }
        })
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let numberOfColumns: CGFloat = 3
        let canvasWidth = min(collectionView.frame.width, collectionView.frame.height)
        let insideMargins = layout.minimumInteritemSpacing * (numberOfColumns - 1)
        let outsideMargins = layout.sectionInset.left + layout.sectionInset.right

        let contentWidth = canvasWidth - outsideMargins - insideMargins
        let itemWidth = contentWidth/numberOfColumns

        return CGSize(width: itemWidth, height: itemWidth)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        return cell
    }

    // MARK: - Search

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        setupTrendingGIFs()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            setupTrendingGIFs()
            return
        }

        searchResults.removeAll()
        collectionView?.reloadData()

        GiphyCore.shared.search(searchText, completionHandler:{ [weak self] response, error in
            guard let serverItems = response?.data?.compactMap({
                return ImageItem(mediaItem: $0)
            }) else {
                return
            }

            OperationQueue.main.addOperation {
                if self?.navigationItem.searchController?.searchBar.text?.isEmpty == true {
                    self?.setupTrendingGIFs()
                    return
                }

                self?.searchResults.append(contentsOf: serverItems)
                self?.collectionView?.reloadData()
            }
        })
    }

    // MARK: - BTS

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let controller = segue.destination as? DetailVC else {
            return
        }

        guard let indexPath = collectionView?.indexPathsForSelectedItems?.first else {
            return
        }

        guard let mediaID = searchResults[indexPath.item].mediaID else {
            return
        }

        let fileURL = FileManager.default.gifURL(with: mediaID)

        do {
            controller.sticker = try MSSticker(contentsOfFileURL: fileURL, localizedDescription: "")
        } catch  {

        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Properties

    var didActivateOnLaunch = false
    var searchResults = [ImageItem]()
}

