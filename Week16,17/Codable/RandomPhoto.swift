//
//  RandomPhoto.swift
//  Week16,17
//
//  Created by Mac Pro 15 on 2022/10/22.
//

import Foundation

struct RandomPhoto: Codable, Hashable {
    var description: String?
    var urls: randomPhotoUrls?
}

// MARK: - randomPhotoUrls
struct randomPhotoUrls: Codable, Hashable {
    let raw, full, regular, small, thumb: String
}
