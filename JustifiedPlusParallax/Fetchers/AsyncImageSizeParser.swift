//
//  AsyncImageSizeParser.swift
//  JustifiedPlusParallax
//
//  Created by Ruslan Lutfullin on 7/9/18.
//  Copyright © 2018 jeudesprits. All rights reserved.
//

import UIKit
import Foundation

final class AsyncImageSizeParser {
  
  // MARK: - Delegation
  
  weak var delegate: AsyncImageSizeParserDelegate?
  
  // MARK: - Operation Queues
  
  private let serialOperationQueue: OperationQueue = {
    $0.maxConcurrentOperationCount = 1
    return $0
  }(OperationQueue())
  
  private lazy var imageSizeParseOperationQueue: OperationQueue = {
    observation = $0.observe(\.operationCount, options: [.new]) { [unowned self] queue, change in
      if change.newValue == 0 {
        self.serialOperationQueue.addOperation {
          self.delegate?.asyncImageSizeParserDidParsed(self.imageSizes)
        }
        self.observation = nil
      }
    }
    
    $0.qualityOfService = .userInitiated
    return $0
  }(OperationQueue())
  
  private let imageBytesFetcherOperationQueue : OperationQueue = {
    $0.qualityOfService = .userInitiated
    return $0
  }(OperationQueue())
  
  // MARK: - Observers
  
  private var observation : NSKeyValueObservation?
  
  // MARK: - Seesion for image bytes fetch
  
  private lazy var session: URLSession = {
    let config = URLSessionConfiguration.default
    config.httpMaximumConnectionsPerHost = 10
    return URLSession(configuration: config)
  }()
  
  // MARK: - Limit per image bytes fetch
  
  private let limit = 100000
  
  // MARK: - Fetched sizes
  
  private lazy var imageSizes = [CGSize?](repeating: CGSize.zero, count: images.count)
  
  // MARK: - Parse
  
  func parse() {
    for image in images.enumerated() {
      let url = URL(string: image.element)!
      let operation = ImageSizeParseOperation(
        url: url,
        session: session,
        operationQueue: imageBytesFetcherOperationQueue
      )
      operation.completionBlock = { [index = image.offset] in
        self.serialOperationQueue.addOperation {
          self.imageSizes[index] = operation.size
        }
      }
      imageSizeParseOperationQueue.addOperation(operation)
      usleep(100000)
    }
  }
  
}
