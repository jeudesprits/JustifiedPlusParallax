//
//  JustifiedPlusParallaxCollectionViewCell.swift
//  JustifiedPlusParallax
//
//  Created by Ruslan Lutfullin on 7/2/18.
//  Copyright © 2018 jeudesprits. All rights reserved.
//

import UIKit

final class JustifiedPlusParallaxCollectionViewCell: UICollectionViewCell {
  static let reuseIdentifier = "\(Bundle.main.bundleIdentifier!).\(typeName)"
  
  var representedId: UUID?
  
  @IBOutlet var imageView: UIImageView!
  
  override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
    guard let attributes = layoutAttributes as? JustifiedPlusParallaxLayoutAttributes  else { return }
    imageView.transform = attributes.parallax
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    imageView.transform = .identity
    imageView.image = nil
  }
  
  func configure(with image: UIImage?) {
    imageView.image = image
  }
}

// MARK: - UIImage extension

//extension UIImage {
//  func resizeImage(withSize size: CGSize) -> UIImage {
//    UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
//    draw(in: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
//    defer { UIGraphicsEndImageContext() }
//    return UIGraphicsGetImageFromCurrentImageContext()!
//  }
//}
