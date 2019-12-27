//
//  SliderItem.swift
//  RSliderGallery
//
//  Created by Ray on 2019/12/23.
//

import UIKit
import Kingfisher

// MARK: - 廣告選項
public protocol SliderGalleryItem {
    var imageURL: String { set get }
}

// MARK: - 廣告圖片
class SliderItem: NSObject {
    
    @objc dynamic var image: UIImage?
    
    private var reloadComplete: ((UIImage) -> Void)?
    
    init(_ imageUrl: String) {
        super.init()
        guard let url = URL(string: imageUrl) else {
            print("image's url fail")
            self.image = UIImage()
            return
        }
        KingfisherManager.shared.retrieveImage(with: url) { (result) in
            switch result {
            case .success(let value):
                self.image = value.image
                self.reloadComplete?(value.image)
            case .failure(let error):
                self.loadImage(url)
                print("show error = \(error.errorDescription ?? "")")
            }
        }
    }
    
    func reload(_ complete: ((UIImage) -> Void)?) {
        self.reloadComplete = complete
    }
    
    private func loadImage(_ imageUrl: URL) {
        let downloader = ImageDownloader.default
        downloader.downloadImage(with: imageUrl) { (result) in
            switch result {
            case .success(let value):
                self.image = value.image
                self.reloadComplete?(value.image)
            case .failure(let error):
                print("download failure: \(error.localizedDescription)")
            }
        }
    }
}
