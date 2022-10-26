//
//  RxDiffableViewModel.swift
//  Week16,17
//
//  Created by Mac Pro 15 on 2022/10/26.
//

import Foundation
import RxSwift

enum SearchError: Error {
    case noPhoto
    case serverError
}

class RxDiffableViewModel {
    
    var photoList = PublishSubject<SearchPhoto>()
    var randomPhoto: CObservable<RandomPhoto> = CObservable(RandomPhoto(description: "", urls: nil)) //검색하기전에 아무것도 안보여주기 때문에 publish가 적합ㅂ
    
    //서치바텍스트 내용을 네트워크 통신요청->클로저로 받은 네트워트통신 내용을 photoList에 초기화->CObservable에서 값변경 인식하면서 snapshot에 데이터 추가하는 bind실행
    func requestSearchPhoto(query: String) {
        APIService.searchPhoto(query: query) { [weak self] photo, statucCode, error in
            guard let statucCode = statucCode, statucCode == 500 else {
                self?.photoList.onError(SearchError.serverError)
                return
            }

            guard let photo = photo else {
                self?.photoList.onError(error!)
                return
            }
            self?.photoList.onNext(photo)
        }
    }
    
    func requestRandomPhoto(query: String) {
        APIService.getRandomPhoto(query: query) { photo, statusCode, error in
            guard let photo = photo else { return }
            self.randomPhoto.value = photo
        }
    }
    
    func resetData() {
        randomPhoto.value.description = ""
        randomPhoto.value.urls = nil
        print(randomPhoto.value.urls)
    }
    
    func loadData(data: randomPhotoUrls) {
        randomPhoto.value.description = randomPhoto.value.description
        randomPhoto.value.urls = data
        print(randomPhoto.value.urls)
    }
}

