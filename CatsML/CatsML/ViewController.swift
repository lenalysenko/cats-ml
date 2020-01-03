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

    override func viewDidLoad() {
        super.viewDidLoad()

        setTestImage()
        scanImage()
    }

    func scanImage() {
        guard let image = imageView.image?.cgImage else { return }

        scanImage(image)
    }

    func setTestImage() {
        let image = UIImage(named: "IMG_0352.JPG")
        imageView.image = image
    }

    func scanImage(_ image: CGImage) {
        guard let model = try? VNCoreMLModel(for: CatsML().model) else { return }

        // Create a Vision request with completion handler
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            guard let self = self else { return }

            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("unexpected result type from VNCoreMLRequest")
            }

            for r in results{
                let percent = Int(r.confidence * 100)
                print("\(r.identifier) \(percent)%")
            }

            if let result = results.first {
                let percent = Int(result.confidence * 100)
                DispatchQueue.main.async {
                    self.resultLabel.text = "\(result.identifier) \(percent)%"
                }
            } else {
                self.resultLabel.text = "Not found"
            }
        }

        // Run the Core ML GoogLeNetPlaces classifier on global dispatch queue
        let handler = VNImageRequestHandler(cgImage: image)
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([request])
            } catch {
                print(error)
            }
        }
    }

    @IBAction func selectButtonPressed(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self
            myPickerController.sourceType = .photoLibrary
            present(myPickerController, animated: true, completion: nil)
        }
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
