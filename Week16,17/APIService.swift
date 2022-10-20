//
//  APIService.swift
//  Week16,17
//
//  Created by Mac Pro 15 on 2022/10/20.
//

import Foundation
import Alamofire

class APIService {
    static func searchPhoto(query: String, completion: @escaping (SearchPhoto?, Int?, Error?) -> Void) { //서치바 내용을 매개변수로 네트워크 요청
        let url = "\(APIKey.searchURL)\(query)"
        let header: HTTPHeaders = ["Authorization": APIKey.authorization]
        AF.request(url, method: .get, headers: header).responseDecodable(of: SearchPhoto.self) { response in
            let statusCode = response.response?.statusCode
            switch response.result {
            case .success(let value): completion(value, statusCode ,nil)
            case .failure(let error): completion(nil, statusCode ,error)
            }
        }
    }
    
    private init() { }
}
