//
//  AsyncFetcher.swift
//  JustifiedPlusParallax
//
//  Created by Ruslan Lutfullin on 7/5/18.
//  Copyright © 2018 jeudesprits. All rights reserved.
//

import UIKit

final class AsyncImageFetcher {
  
  private var completionHandlers = [UUID: [(UIImage?) -> Void]]()
  
  private var cache = NSCache<NSUUID, UIImage>()
  
  // MARK: - Opertation queues
  
  private let serialOperationQueue: OperationQueue = {
    $0.maxConcurrentOperationCount = 1
    return $0
  }(OperationQueue())
  
  private let fetchOperationQueue: OperationQueue = {
    $0.qualityOfService = .userInitiated
    return $0
  }(OperationQueue())
  
  // MARK: - Fetch control methods
  
  func fetch(_ identifier: UUID, url: URL, completion: ((UIImage?) -> Void)? = nil) {
    serialOperationQueue.addOperation {
      if let completion = completion {
        let handlers = self.completionHandlers[identifier, default: []]
        self.completionHandlers[identifier] = handlers + [completion]
      }
      self.fetchData(with: identifier, for: url)
    }
  }
  
  func cancelFetch(_ identifier: UUID) {
    serialOperationQueue.addOperation {
      self.fetchOperationQueue.isSuspended = true
      self.operation(for: identifier)?.cancel()
      self.completionHandlers[identifier] = nil
      defer { self.fetchOperationQueue.isSuspended = false }
    }
  }
  
  func fetchedData(for identifier: UUID) -> UIImage? {
    return cache.object(forKey: identifier as NSUUID)
  }
  
  private func fetchData(with identifier: UUID, for url: URL) {
    guard operation(for: identifier) == nil else { return }
    
    if let data = fetchedData(for: identifier) {
      invokeCompletionHandlers(for: identifier, with: data)
    } else {
      let operation = ImageFetcherOperation(identifier: identifier, url: url)
      operation.completionBlock = { [weak operation] in
        guard let fetchedData = operation?.fetchedData else { return }
        self.cache.setObject(fetchedData, forKey: identifier as NSUUID)
        self.serialOperationQueue.addOperation {
          self.invokeCompletionHandlers(for: identifier, with: fetchedData)
        }
      }
      fetchOperationQueue.addOperation(operation)
    }
  }
  
  private func operation(for identifier: UUID) -> ImageFetcherOperation? {
    for case let fetchOperation as ImageFetcherOperation in fetchOperationQueue.operations
        where !fetchOperation.isCancelled && fetchOperation.identifier == identifier {
      return fetchOperation
    }
    return nil
  }
  
  private func invokeCompletionHandlers(for identifier: UUID, with fetchedData: UIImage) {
    let completionHandlers = self.completionHandlers[identifier, default: []]
    self.completionHandlers[identifier] = nil
    completionHandlers.forEach { $0(fetchedData) }
  }
  
}
