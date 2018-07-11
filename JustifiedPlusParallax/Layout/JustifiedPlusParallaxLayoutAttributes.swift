//
//  JustifiedPlusParallaxLayoutAttributes.swift
//  JustifiedPlusParallax
//
//  Created by Ruslan Lutfullin on 7/1/18.
//  Copyright © 2018 jeudesprits. All rights reserved.
//

import UIKit

final class JustifiedPlusParallaxLayoutAttributes: UICollectionViewLayoutAttributes {
  
  var parallax: CGAffineTransform = .identity
  
  // MARK: - Ovveride NSCopying methods
  
  override func copy(with zone: NSZone?) -> Any {
    let attributes = super.copy(with: zone) as! JustifiedPlusParallaxLayoutAttributes
    attributes.parallax = parallax
    return attributes
  }
  
  
  // MARK: - Ovveride NSObjectProtocol methods
  
  override func isEqual(_ object: Any?) -> Bool {
    let attributes = object as! JustifiedPlusParallaxLayoutAttributes
    guard NSValue(cgAffineTransform: attributes.parallax) == NSValue(cgAffineTransform: parallax) else { return false }
    return super.isEqual(object)
  }
  
}
