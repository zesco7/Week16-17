//
//  APIKey.swift
//  Week16,17
//
//  Created by Mac Pro 15 on 2022/10/20.
//

import Foundation

enum APIKey {
    static let baseURL = "https://api.unsplash.com"
    static let searchURL = "https://api.unsplash.com/search/photos?query=" //요청 프로토콜이 https이므로 ATS설정하지 않아도 됨
    static let listPhotosURL = "https://api.unsplash.com/photos?page="
    static let getSinglePhotoURL = "https://api.unsplash.com/photos/:id="
    static let getRandomPhotoURL = "https://api.unsplash.com/photos/random?query="
    static let authorization = "Client-ID dztTQySps03WXgKoiMc2EFsx4PnZOrL6uYNKOP6NjSk"
}

