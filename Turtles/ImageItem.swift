//
//  ImageItem.swift
//  Turtles
//
//  Created by Blaine Solomon on 9/9/18.
//  Copyright © 2018 Solomon. All rights reserved.
//

import UIKit
import GiphyCoreSDK

class ImageItem {
    init?(mediaItem: GPHMedia) {

        guard let image = mediaItem.images?.fixedWidth else {
            return nil
        }

        guard let imageThumbnailURL = mediaItem.images?.fixedWidthStill?.gifUrl else {
            return nil
        }

        thumbnailURL = URL(string: imageThumbnailURL)
        gifURL = URL(string: image.gifUrl)
        mediaID = image.mediaId
        width = CGFloat(image.width)
        height = CGFloat(image.height)
    }

    var mediaID: String?
    var thumbnailURL: URL?
    var gifURL: URL?
    var height: CGFloat = 0
    var width: CGFloat = 0
}
