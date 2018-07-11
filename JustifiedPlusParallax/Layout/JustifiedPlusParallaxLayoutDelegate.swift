//
//  JustifiedPlusParallaxLayoutDelegate.swift
//  JustifiedPlusParallax
//
//  Created by Ruslan Lutfullin on 7/1/18.
//  Copyright © 2018 jeudesprits. All rights reserved.
//

import UIKit

protocol JustifiedPlusParallaxLayoutDelegate: AnyObject {
  
  func collectionView(
    _ collectionView: UICollectionView,
    layout justifiedPlusParallaxLayout: JustifiedPlusParallaxLayout,
    sizeForItemImageAt indexPath: IndexPath
  ) -> CGSize
  
}
