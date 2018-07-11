//
//  AsyncImageSizeParserDelegate.swift
//  JustifiedPlusParallax
//
//  Created by Ruslan Lutfullin on 7/9/18.
//  Copyright © 2018 jeudesprits. All rights reserved.
//

import struct CoreGraphics.CGSize

protocol AsyncImageSizeParserDelegate: AnyObject { func asyncImageSizeParserDidParsed(_ sizes: [CGSize?]) }
