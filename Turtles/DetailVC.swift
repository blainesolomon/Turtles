//
//  DetailVC.swift
//  Turtles
//
//  Created by Blaine Solomon on 9/9/18.
//  Copyright © 2018 Solomon. All rights reserved.
//

import UIKit
import Messages

class DetailVC: UIViewController {

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()

        stickerView.sticker = sticker
        stickerView.startAnimating()
    }

    // MARK: - Action

    @IBAction func shareAction(_ sender: UIBarButtonItem) {
        let controller = UIActivityViewController(activityItems: [sticker.imageFileURL], applicationActivities: nil)
        controller.popoverPresentationController?.barButtonItem = sender
        present(controller, animated: true, completion: nil)
    }

    // MARK: - Properties

    var sticker: MSSticker!
    @IBOutlet private weak var stickerView: MSStickerView!
}
