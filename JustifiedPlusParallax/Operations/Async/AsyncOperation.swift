//
//  AsyncOperation.swift
//  JustifiedPlusParallax
//
//  Created by Ruslan Lutfullin on 7/5/18.
//  Copyright © 2018 jeudesprits. All rights reserved.
//

import class Foundation.Operation

class AsyncOperation: Operation {
  
  // MARK: - Own state machine
  
  enum State: String {
    case isReady, isExecuting, isFinished
    var keyPath: String { return rawValue }
  }
  
  var state: State = .isReady {
    willSet {
      willChangeValue(forKey: newValue.keyPath)
      willChangeValue(forKey: state.keyPath)
    }
    didSet {
      didChangeValue(forKey: state.keyPath)
      didChangeValue(forKey: oldValue.keyPath)
    }
  }
  
  // MARK: - Overrided Operation states
  
  override var isAsynchronous: Bool {
    return true
  }
  
  override var isReady: Bool {
    return super.isReady && state == .isReady
  }
  
  override var isExecuting: Bool {
    return state == .isExecuting
  }
  
  override var isFinished: Bool {
    return state == .isFinished
  }
  
  // MARK: - Overrided Operation methods
  
  override func start() {
    guard !isCancelled else { state = .isFinished; return }
    main()
    state = .isExecuting
  }
  
  override func cancel() {
    super.cancel()
    state = .isFinished
  }
  
}
