//
//  AsyncFetcherOperation.swift
//  JustifiedPlusParallax
//
//  Created by Ruslan Lutfullin on 7/5/18.
//  Copyright © 2018 jeudesprits. All rights reserved.
//

import UIKit
import Foundation

final class ImageFetcherOperation: Operation {
  
  let identifier: UUID
  
  private let url: URL
  
  private(set) var fetchedData: UIImage?
  
  // MARK: - Initialization
  
  init(identifier: UUID, url: URL) {
    self.identifier = identifier
    self.url = url
  }
  
  // MARK: - Overrided Operation methods
  
  override func main() {
    guard !isCancelled else { return }
    fetchedData = UIImage(data: try! Data(contentsOf: url))
  }
  
}
