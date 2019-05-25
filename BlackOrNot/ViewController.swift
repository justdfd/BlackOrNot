//
//  ViewController.swift
//  BlackOrNot
//
//  Created by Dave Dombrowski on 5/25/19.
//  Copyright © 2019 justDFD. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let safeAreaView = UIView()
    let imageView = ImageView()
    var uiColor = UIImage(named: "color.jpeg")
    var ciColor:CIImage!
    var ciGrayscale:CIImage!
    var ciBlackWhite:CIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.brown
        safeAreaView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safeAreaView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clearColor = UIColor.blue
        view.addSubview(imageView)
        setConstraints()
    }
    override func viewDidLayoutSubviews() {
        uiColor = uiColor!.resizeToBoundingSquare(640)
        ciColor = CIImage(image: uiColor!)!.rotateImage()
        //showColorImage()
        //showGrayscaleImage()
        showBlackWhiteImage()
    }
    func setConstraints() {
        if #available(iOS 11, *) {
            safeAreaView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            safeAreaView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
            safeAreaView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
            safeAreaView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        } else {
            safeAreaView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
            safeAreaView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
            safeAreaView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
            safeAreaView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
        }
        imageView.topAnchor.constraint(equalTo: safeAreaView.topAnchor, constant: 10).isActive = true
        imageView.bottomAnchor.constraint(equalTo: safeAreaView.bottomAnchor, constant: -10).isActive = true
        imageView.leadingAnchor.constraint(equalTo: safeAreaView.leadingAnchor, constant: 10).isActive = true
        imageView.trailingAnchor.constraint(equalTo: safeAreaView.trailingAnchor, constant: -10).isActive = true
    }
    func showColorImage() {
        imageView.image = ciColor
    }
    func showGrayscaleImage() {
        ciGrayscale = CIFilter(name: "CIPhotoEffectNoir", parameters: [kCIInputImageKey: ciColor!])?.outputImage
        imageView.image = ciGrayscale
    }
    func showBlackWhiteImage() {
        ciGrayscale = CIFilter(name: "CIPhotoEffectNoir", parameters: [kCIInputImageKey: ciColor!])?.outputImage
        let kernel = CIColorKernel( source:
            "kernel vec4 replaceGrayWithBlackOrWhite(__sample s) {" +
                "if (s.r > 0.25 && s.g > 0.25 && s.b > 0.25) {" +
                "    return vec4(0.0,0.0,0.0,1.0);" +
                "} else {" +
                "    return vec4(1.0,1.0,1.0,1.0);" +
                "}" +
            "}"
        )
        ciBlackWhite = kernel?.apply(extent: (ciGrayscale?.extent)!, arguments: [ciGrayscale as Any])
        imageView.image = ciBlackWhite
    }
}
extension UIImage {
    public func resizeToBoundingSquare(_ boundingSquareSideLength : CGFloat) -> UIImage {
        let imgScale = self.size.width > self.size.height ? boundingSquareSideLength / self.size.width : boundingSquareSideLength / self.size.height
        let newWidth = self.size.width * imgScale
        let newHeight = self.size.height * imgScale
        let newSize = CGSize(width: newWidth, height: newHeight)
        UIGraphicsBeginImageContext(newSize)
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return resizedImage!
    }
}
extension CIImage {
    public func rotateImage() -> CIImage {
        let image = UIImage(ciImage: self)
        if (image.imageOrientation == UIImage.Orientation.right) {
            return self.oriented(forExifOrientation: 6)
        } else if (image.imageOrientation == UIImage.Orientation.left) {
            return self.oriented(forExifOrientation: 6)
        } else if (image.imageOrientation == UIImage.Orientation.down) {
            return self.oriented(forExifOrientation: 3)
        } else if (image.imageOrientation == UIImage.Orientation.up) {
            return self.oriented(forExifOrientation: 1)
        }
        return self
    }
}

