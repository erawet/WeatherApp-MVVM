//
//  ImageCache.swift
//  WeatherApp
//
//  Created by Don Wettasinghe on 6/27/26.
//
//  Stores downloaded weather icons.
//

import UIKit

protocol ImageCache {
    func image(forKey key: String) -> UIImage?
    func saveImage(_ image: UIImage, forKey key: String)
}

final class NSCacheImageCache: ImageCache {
    private let cache = NSCache<NSString, UIImage>()

    func image(forKey key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }

    func saveImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}
