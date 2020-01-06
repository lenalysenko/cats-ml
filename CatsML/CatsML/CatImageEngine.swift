//
//  CatImageEngine.swift
//  CatsML
//
//  Created by CW2519 on 1/3/20.
//  Copyright © 2020 lena. All rights reserved.
//

import UIKit
import CoreML
import Vision

enum EngineError: Error {
    case notACat
    case noResults
}

extension EngineError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .notACat:
            return "Cat not found"
        case .noResults:
            return "Could not identify"
        }
    }
}

struct CatEngineResult {
    let title: String
    let accuracy: Float
    let displayString: String
}

class CatImageEngine {
    lazy var genericModel = SqueezeNet().model
    lazy var catModel = CatsML().model

    func scanImage(_ image: CGImage, completion: @escaping ((Result<CatEngineResult, Error>) -> ()) ) {
        runFor(image: image, withGenericModel: true) { result in
            switch result {
            case .success(let results):
                if self.containsCat(in: results) {
                    self.runFor(image: image, withGenericModel: false) { newResult in
                        switch newResult {
                        case .success(let results):
                            if let result = results.first {
                                let percent = Int(result.confidence * 100)
                                let resultText = "\(result.identifier) \(percent)%"
                                let fullResult = CatEngineResult(title: result.identifier, accuracy: result.confidence, displayString: resultText)
                                completion(.success(fullResult))
                            } else {
                                completion(.failure(EngineError.noResults))
                            }
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                } else {
                    completion(.failure(EngineError.notACat))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func runFor(image: CGImage, withGenericModel: Bool, completion: @escaping ((Result<[VNClassificationObservation], Error>) -> ())) {
        let coreModel = withGenericModel ? genericModel : catModel

        guard let model = try? VNCoreMLModel(for: coreModel) else { return }

        // Create a Vision request with completion handler
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation] else {
                completion(.failure(error ?? EngineError.noResults))
                return
            }

            for r in results{
                let percent = Int(r.confidence * 100)
                print("\(r.identifier) \(percent)%")
            }

            completion(.success(results))
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

    private func containsCat(in results: [VNClassificationObservation]) -> Bool {
        for result in results {
            if result.confidence > 0.01, result.identifier.lowercased().contains("cat") {
                return true
            }
        }

        return false
    }
}
