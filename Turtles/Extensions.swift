//
//  URLExtension.swift
//  Turtles
//
//  Created by Blaine Solomon on 9/9/18.
//  Copyright © 2018 Solomon. All rights reserved.
//

import Foundation

extension FileManager {
    func gifURL(with mediaID: String) -> URL {
        var fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(mediaID)
        fileURL.appendPathExtension("gif")
        return fileURL
    }
}

extension URL {
    init?(string: String?) {
        guard let string = string else {
            return nil
        }

        self.init(string: string)
    }
}
