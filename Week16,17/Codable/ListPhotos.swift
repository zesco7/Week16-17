//
//  ListPhotos.swift
//  Week16,17
//
//  Created by Mac Pro 15 on 2022/10/22.
//

import Foundation

struct ListPhotos: Codable, Hashable {
    let user: ListURLS
}

// MARK: - ListURLS
struct ListURLS: Codable, Hashable {
    let raw, full, regular, small: String
    let thumb, smallS3: String
}
