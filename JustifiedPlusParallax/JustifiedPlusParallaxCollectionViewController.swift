//
//  CollectionViewController.swift
//  JustifiedPlusParallax
//
//  Created by Ruslan Lutfullin on 7/1/18.
//  Copyright © 2018 jeudesprits. All rights reserved.
//

import UIKit

final class JustifiedPlusParallaxCollectionViewController: UICollectionViewController {
  
  // MARK: - Model
  
  private let models = images.map { Model(imageURL: $0) }
  
  private var sizes: [CGSize?]?
  
  // MARK: - Fetchers & Parsers
  
  private let asyncFetcher = AsyncImageFetcher()
  
  private let asyncImageSizeParser = AsyncImageSizeParser()
  
  // MARK: - Layout
  
  private let layout = JustifiedPlusParallaxLayout()
  
  // MARK: - Lifecycle methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    collectionView?.register(
      UINib(nibName: "JustifiedPlusParallaxCollectionViewCell", bundle: nil),
      forCellWithReuseIdentifier: JustifiedPlusParallaxCollectionViewCell.reuseIdentifier
    )
    collectionView?.setCollectionViewLayout(self.layout, animated: false)
    collectionView?.alpha = 0.0
    
    layout.delegate = self
    asyncImageSizeParser.delegate = self
    
    DispatchQueue.global(qos: .userInitiated).async {
      self.asyncImageSizeParser.parse()
    }
  }
  
  // MARK: - UICollectionViewDataSource
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return sizes != nil ? models.count : 0
  }
  
  override func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: JustifiedPlusParallaxCollectionViewCell.reuseIdentifier,
      for: indexPath
    ) as! JustifiedPlusParallaxCollectionViewCell

    let model = models[indexPath.row]
    let id = model.id
    cell.representedId = id

    // Check if the `asyncFetcher` has already fetched data for the specified identifier.
    if let fetchedData = asyncFetcher.fetchedData(for: id) {
      // The data has already been fetched and cached; use it to configure the cell.
      cell.configure(with: fetchedData)
    } else {
      // There is no data available; clear the cell until we've fetched data.
      //cell.configure(with: nil)
      
      // Ask the `asyncFetcher` to fetch data for the specified identifier.
      asyncFetcher.fetch(id, url: URL(string: models[indexPath.item].imageURL)!) { fetchedData in
        DispatchQueue.main.async {
          /*
           The `asyncFetcher` has fetched data for the identifier. Before
           updating the cell, check if it has been recycled by the
           collection view to represent other data.
           */
          guard cell.representedId == id else { return }
          
          // Configure the cell with the fetched image.
          cell.configure(with: fetchedData)
        }
      }
    }
    
    return cell
  }
  
}



// MARK: - UICollectionViewDataSourcePrefetching

extension JustifiedPlusParallaxCollectionViewController: UICollectionViewDataSourcePrefetching {
  func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
    for indexPath in indexPaths {
      let id = models[indexPath.item].id
      asyncFetcher.fetch(id, url: URL(string: models[indexPath.item].imageURL)!)
    }
  }

  func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
    for indexPath in indexPaths {
      let id = models[indexPath.item].id
      asyncFetcher.cancelFetch(id)
    }
  }
}

// MARK: - JustifiedPlusParallaxLayoutDelegate

extension JustifiedPlusParallaxCollectionViewController: JustifiedPlusParallaxLayoutDelegate {
  func collectionView(
    _ collectionView: UICollectionView,
    layout justifiedPlusParallaxLayout: JustifiedPlusParallaxLayout,
    sizeForItemImageAt indexPath: IndexPath
  ) -> CGSize {
    return sizes![indexPath.item]!
  }
}

// MARK: - AsyncImageSizeParserDelegate

extension JustifiedPlusParallaxCollectionViewController: AsyncImageSizeParserDelegate {
  func asyncImageSizeParserDidParsed(_ sizes: [CGSize?]) {
    DispatchQueue.main.async {
      self.collectionView?.alpha = 1.0
      self.sizes = sizes
      self.collectionView?.reloadData()
    }
  }
}








