//
//  TypeName.swift
//  JustifiedPlusParallax
//
//  Created by Ruslan Lutfullin on 7/1/18.
//  Copyright © 2018 jeudesprits. All rights reserved.
//

import class Foundation.NSObject

// Swift Classes
protocol TypeName: AnyObject { static var typeName: String { get } }

extension TypeName { static var typeName: String { return String(describing: self) } }

// Objc Classes
extension NSObject { static var typeName: String { return String(describing: self) } }
