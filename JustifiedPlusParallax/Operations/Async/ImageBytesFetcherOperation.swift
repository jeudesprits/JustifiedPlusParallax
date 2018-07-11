//
//  FetchImageBytesOperation.swift
//  Tester
//
//  Created by Ruslan Lutfullin on 7/8/18.
//  Copyright © 2018 jeudesprits. All rights reserved.
//

import Foundation

final class ImageBytesFetcherOperation: AsyncOperation {
  
  private var session: URLSession!
  
  private var url: URL!
  
  private var range: CountableClosedRange<Int>!
  
  var receivedData: Data!
  
  // MARK: - Initialization
  
  init(session: URLSession, url: URL, range: CountableClosedRange<Int>) {
    self.session = session
    self.url = url
    self.range = range
  }
  
  // MARK: - Overrided Operation methods
  
  override func main() {
    startLoad()
  }
  
  // MARK: - Load image bytes
  
  private func startLoad() {
    var request = URLRequest(url: url)
    request.addValue("bytes=\(range.lowerBound)-\(range.upperBound)", forHTTPHeaderField: "Range")
    
    let task =  session.dataTask(with: request) { data, response, error in
      if let error = error {
        print("Client \(error)")
        return
      }
      guard let httpResponse = response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode) else {
          print("Server \(response.debugDescription)")
          return
      }
      if let mimeType = httpResponse.mimeType, mimeType == "image/jpeg",
         let data = data {
        self.receivedData = data
      }
      defer { self.state = .isFinished }
    }
    
    task.priority = 1.0
    task.resume()
  }
  
}
