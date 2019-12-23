//
//  SliderItem.swift
//  RSliderGallery
//
//  Created by Ray on 2019/12/23.
//

import UIKit

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
        
    }
    
    func reload(_ complete: ((UIImage) -> Void)?) {
        self.reloadComplete = complete
    }
    
    private func loadImage(_ imageUrl: String) {
        
    }
}
