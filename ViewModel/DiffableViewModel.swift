//
//  DiffableViewModel.swift
//  Week16,17
//
//  Created by Mac Pro 15 on 2022/10/20.
//

import Foundation

class DiffableViewModel {
    
    var photoList: CObservable<SearchPhoto> = CObservable(SearchPhoto(total: 0, totalPages: 0, results: []))
    var randomPhoto: CObservable<RandomPhoto> = CObservable(RandomPhoto(description: "", urls: nil))
    //서치바텍스트 내용을 네트워크 통신요청->클로저로 받은 네트워트통신 내용을 photoList에 초기화->CObservable에서 값변경 인식하면서 snapshot에 데이터 추가하는 bind실행
    func requestSearchPhoto(query: String) {
        APIService.searchPhoto(query: query) { photo, statucCode, error in
            guard let photo = photo else { return }
            self.photoList.value = photo
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
