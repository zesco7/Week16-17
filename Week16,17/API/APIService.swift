//
//  APIService.swift
//  Week16,17
//
//  Created by Mac Pro 15 on 2022/10/20.
//

import Foundation
import Alamofire

class APIService {
    static func searchPhoto(query: String, completion: @escaping (SearchPhoto?, Int?, Error?) -> Void) { //통신요청내용(SearchPhoto), 상태코드(Int), 에러케이스 클로저 전달
        let url = "\(APIKey.searchURL)\(query)"
        let header: HTTPHeaders = ["Authorization": APIKey.authorization]
        AF.request(url, method: .get, headers: header).responseDecodable(of: SearchPhoto.self) { response in //responseDecodable에 decode 대상 추가
            let statusCode = response.response?.statusCode
            switch response.result {
            case .success(let value): completion(value, statusCode ,nil) //성공했을때 클로저로 통신요청내용, 상태코드 전달
                print(value)
            case .failure(let error): completion(nil, statusCode ,error) //실패했을때 클로저로 상태코드, 에러케이스 전달
            }
        }
    }
    
    static func getRandomPhoto(query: String, completion: @escaping (RandomPhoto?, Int?, Error?) -> Void) { //통신요청내용(RandomPhoto), 상태코드(Int), 에러케이스 클로저 전달
        let url = "\(APIKey.getRandomPhotoURL)\(query)"
        let header: HTTPHeaders = ["Authorization": APIKey.authorization]
        AF.request(url, method: .get, headers: header).responseDecodable(of: RandomPhoto.self) { response in //responseDecodable에 decode 대상 추가
            let statusCode = response.response?.statusCode
            switch response.result {
            case .success(let value): completion(value, statusCode ,nil) //성공했을때 클로저로 통신요청내용, 상태코드 전달
                print(value)
            case .failure(let error): completion(nil, statusCode ,error) //실패했을때 클로저로 상태코드, 에러케이스 전달
                print(error)
            }
        }
    }
    
    private init() { } //???
}
