//
//  ViewController.swift
//  CatsML
//
//  Created by CW2519 on 1/3/20.
//  Copyright © 2020 lena. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var resultLabel: UILabel!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!

    lazy var engine = CatImageEngine()

    var result: CatEngineResult?

    override func viewDidLoad() {
        super.viewDidLoad()

        setTestImage()
        scanImage()
    }

    func scanImage() {
        guard let image = imageView.image?.cgImage else { return }

        engine.scanImage(image) { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let result):
                    self.result = result
                    self.resultLabel.text = result.displayString
                    self.moreButton.isHidden = false
                case .failure(let error):
                    self.resultLabel.text = error.localizedDescription
                    self.moreButton.isHidden = true
                    self.result = nil
                }
            }
        }
    }

    func setTestImage() {
        let image = UIImage(named: "IMG_0352.JPG")
        imageView.image = image
    }

    @IBAction func selectButtonPressed(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self
            myPickerController.sourceType = .photoLibrary
            present(myPickerController, animated: true, completion: nil)
        }
    }

    @IBAction func moreButtonPressed(_ sender: Any) {
        guard let result = result, !result.title.isEmpty else { return }

        openTagsFor(result.title)
    }

    func openTagsFor(_ tag: String) {
        let urlString = "https://www.instagram.com/explore/tags/" + tag.replacingOccurrences(of: " ", with: "") + "cat"
        guard let url = URL(string: urlString) else {
            return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
            scanImage()
        } else{
            print("Something went wrong")
        }

        dismiss(animated: true, completion: nil)
    }
}
