//
//  NewsViewModel.swift
//  Week16,17
//
//  Created by Mac Pro 15 on 2022/10/20.
//

import Foundation

class NewsViewModel {
    var pageNumber: CObservable<String> = CObservable("3000") //데이터 초기화를 뷰모델에서 처리
    
    var sample: CObservable<[News.NewsItem]> = CObservable(News.items) //데이터 초기화를 뷰모델에서 처리
    
    func changePageNumberFormat(text: String) {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let convertedNumber = text.replacingOccurrences(of: ",", with: "") //콤마 삭제해서 String->Int 변환 가능하도록 설정(한번 콤마가 생기면 String->Int 변환이 안되기 때문에 콤마 삭제해줘야 함)
        guard let number = Int(convertedNumber) else { return }
        let result = numberFormatter.string(for: number)!
        pageNumber.value = result
    }
    
    func resetSample() {
        sample.value = []
    }
    
    func loadSample() {
        sample.value = News.items
    }
}
