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
  
  override func copy(with zone: NSZone?) -> Any {
    guard let attributes = super.copy(with: zone) as? JustifiedPlusParallaxLayoutAttributes else { return super.copy(with: zone) }
    attributes.parallax = parallax
    return attributes
  }
  
  override func isEqual(_ object: Any?) -> Bool {
    guard let attributes = object as? JustifiedPlusParallaxLayoutAttributes else { return false }
    guard NSValue(cgAffineTransform: attributes.parallax) == NSValue(cgAffineTransform: parallax) else { return false }
    return super.isEqual(object)
  }
  
}
