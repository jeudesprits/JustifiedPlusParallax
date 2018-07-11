//
//  JustifiedPlusParallaxLayout.swift
//  JustifiedPlusParallax
//
//  Created by Ruslan Lutfullin on 7/1/18.
//  Copyright © 2018 jeudesprits. All rights reserved.
//

import UIKit
import Foundation

final class JustifiedPlusParallaxLayout: UICollectionViewLayout {
  weak var delegate: JustifiedPlusParallaxLayoutDelegate?
  
  private var cache = NSCache<NSIndexPath, JustifiedPlusParallaxLayoutAttributes>()
  private var numberOfItemsInRowCache = [Int]()
  private var visibleAttributes = [JustifiedPlusParallaxLayoutAttributes]()

  
  var lineSpacing: CGFloat = 5.0
  var interItemSpacing: CGFloat = 5.0
  var sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
  var minItemsInRow = 2
  var maxItemsInRow = 3
  private var maxParallaxOffset: CGFloat = 30.0
  
  private var totalHeight: CGFloat = 0.0
  
  override public class var layoutAttributesClass: AnyClass {
    return JustifiedPlusParallaxLayoutAttributes.self
  }
  
  override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
    return true
  }
  
  override func prepare() {
    cache.removeAllObjects()
    totalHeight = 0.0
    
    var randomItemsInRow = 0,
        nextIndex = 1,
        indexPaths = [IndexPath](),
        numberOfItems = collectionView!.numberOfItems(inSection: 0)
    
    guard numberOfItems != 0 else { return }
    
    if numberOfItemsInRowCache.isEmpty {
      var summ = 0
      repeat {
        let randomNumberOfItemsInRow = (minItemsInRow...maxItemsInRow).random
        summ += randomNumberOfItemsInRow
        
        if summ <= numberOfItems {
          numberOfItemsInRowCache.append(randomNumberOfItemsInRow)
        } else {
          let numberOfItemsInLastRow = randomNumberOfItemsInRow - (summ - numberOfItems)
          if numberOfItemsInLastRow != 0  {
            numberOfItemsInRowCache.append(numberOfItemsInLastRow)
          }
          break
        }
      } while (true)
    }
    
  
    randomItemsInRow = numberOfItemsInRowCache.first!
    for item in 0..<numberOfItems {
      indexPaths.append(IndexPath(item: item, section: 0))
      if indexPaths.count == randomItemsInRow || item == numberOfItems - 1 {
        let sizes = preferredSizes(forRowWithIndexPaths: indexPaths)
        var totalWidth: CGFloat = 0.0
        sizes.enumerated().forEach { size in
          let indexPath = indexPaths[size.offset]
          cache.setObject(
            { attribute in
              attribute.frame = CGRect(
                x: totalWidth,
                y: totalHeight,
                width: size.element.width,
                height: size.element.height - 60.0
              )
              return attribute
            }(JustifiedPlusParallaxLayoutAttributes(forCellWith: indexPath)),
            forKey: indexPath as NSIndexPath
          )
          
          totalWidth += size.element.width + lineSpacing
        }
        totalHeight += sizes.first!.height + lineSpacing - 60.0
        indexPaths.removeAll()
        
        if nextIndex + 1 != numberOfItemsInRowCache.count {
          randomItemsInRow = numberOfItemsInRowCache[nextIndex]
          nextIndex += 1
        }
        
      }
    }
  }
  
  override var collectionViewContentSize: CGSize {
    return CGSize(width: collectionView!.bounds.width, height: totalHeight)
  }
  
  override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    return cache.object(forKey: indexPath as NSIndexPath)
  }
  
  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    visibleAttributes.removeAll(keepingCapacity: true)
    let halfHeight = collectionView!.bounds.height / 2
    
    for itemNumber in 0..<collectionView!.numberOfItems(inSection: 0) {
      if let attribute = cache.object(forKey: IndexPath(item: itemNumber, section: 0) as NSIndexPath),
         attribute.frame.intersects(rect) {
        let cellDistanceFromCenter = attribute.center.y - collectionView!.contentOffset.y - halfHeight
        let parallaxOffset = -cellDistanceFromCenter * (maxParallaxOffset / halfHeight)
        let boundedParallaxOffset = min(max(-maxParallaxOffset, parallaxOffset), maxParallaxOffset)
        attribute.parallax = CGAffineTransform(translationX: 0, y: boundedParallaxOffset)
        visibleAttributes.append(attribute)
      }
    }
    
    return visibleAttributes
  }
  
  private func preferredSizes(forRowWithIndexPaths indexPaths: [IndexPath]) -> [CGSize] {
    var itemsImageSizes = [CGSize](),
    minItemHeight: CGFloat = .greatestFiniteMagnitude,
    allItemsWidth: CGFloat = 0.0
    
    for indexPath in indexPaths {
      let size = delegate!.collectionView(collectionView!, layout: self, sizeForItemImageAt: indexPath)
      itemsImageSizes.append(size)
      minItemHeight = size.height < minItemHeight ? size.height : minItemHeight
    }
    
    for (offset, item) in itemsImageSizes.enumerated() {
      itemsImageSizes[offset] = CGSize(width: minItemHeight * item.width / item.height, height: minItemHeight)
      allItemsWidth += itemsImageSizes[offset].width
    }
    
    let containerWidth = collectionView!.bounds.width
        - (sectionInset.left + sectionInset.right)
        - CGFloat(itemsImageSizes.count - 1) * lineSpacing,
    preferredHeight = containerWidth * minItemHeight / allItemsWidth
    
    return itemsImageSizes.map {
      let aspectRatio = $0.width / $0.height
      return CGSize(width: preferredHeight * aspectRatio, height: preferredHeight)
    }
  }
}

// MARK: - CountableClosedRange<Int> extension

extension CountableClosedRange where Bound == Int {
  var random: Int {
    let length = Int(self.upperBound - self.lowerBound + 1)
    return Int(arc4random()) % length + Int(self.lowerBound)
  }
}
