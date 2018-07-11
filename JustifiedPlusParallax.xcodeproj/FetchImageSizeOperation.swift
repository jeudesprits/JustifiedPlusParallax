//
//  FetchImageSizeOperation.swift
//  Tester
//
//  Created by Ruslan Lutfullin on 7/8/18.
//  Copyright © 2018 jeudesprits. All rights reserved.
//

import Foundation

class FetchImageSizeOperation: AsyncOperation {
  private var fetchImageBytesOperationQueue: OperationQueue!
  private var session: URLSession!
  private var url: URL!
  
  private var data = Data()
  private var range = 0...10000
  private var offset = 1
  private var currentBlockLength: UInt16 = 0x0000
  var size: CGSize?
  
  
  init(url: URL, session: URLSession, operationQueue: OperationQueue) {
    self.url = url
    self.session = session
    fetchImageBytesOperationQueue = operationQueue
  }
  
  override func main() {
    let operation = FetchImageBytesOperation(session: session, url: url, range: range)
    operation.completionBlock = {
      self.data.append(operation.receivedData)
      self.parse()
    }
    fetchImageBytesOperationQueue.addOperation(operation)
  }
  
  private enum Markers {
    case SOI, APP, SOF, DHT, DQT, COM
  }
  
  private func parseMarker(by byte: UInt8) -> Markers? {
    switch byte {
    case 0xD8:
      return .SOI
    case 0xE0...0xEF:
      return .APP
    case 0xC0...0xC3, 0xC5...0xC7, 0xC9...0xCF:
      return .SOF
    case 0xDB:
      return .DQT
    case 0xC4:
      return .DHT
    case 0xFE:
      return .COM
    default:
      return nil
    }
  }
  
  private func checkOffsetOutOfRange() {
    if offset + 7 > range.upperBound {
      print(#function)
      
      let newUpperBound = offset + 7 < 2 * range.upperBound ? 2 * range.upperBound : offset + 7 // TODO: мб как-то точнее
      range = range.upperBound + 1 ... newUpperBound
      let operation = FetchImageBytesOperation(session: session, url: url, range: range)
      operation.completionBlock  = {
        self.data.append(operation.receivedData)
        self.parse()
      }
      fetchImageBytesOperationQueue.addOperation(operation)
    } else {
      parse()
    }
  }
  
  private func parse() {
    guard let marker = parseMarker(by: data[offset]) else {
      print("Smth goes wrong...\n\(url)")
      state = .isFinished
      return
    }
    
    switch marker {
    case .SOI:
      offset += 2
      parse()
    case .APP, .DQT, .DHT, .COM:
      (data as NSData).getBytes(&currentBlockLength, range: NSRange(location: offset + 1, length: 2))
      offset += Int(NSSwapShort(currentBlockLength)) + 2
      checkOffsetOutOfRange()
    case .SOF:
      var height: UInt16 = 0x0000
      (data as NSData).getBytes(&height, range: NSRange(location: offset + 4, length: 2))
      
      var width: UInt16 = 0x0000
      (data as NSData).getBytes(&width, range: NSRange(location: offset + 6, length: 2))
      
      size = CGSize(width: Int(NSSwapShort(width)), height: Int(NSSwapShort(height)))
      state = .isFinished
    }
  }
}
