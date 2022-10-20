//
//  NewsViewModel.swift
//  Week16,17
//
//  Created by Mac Pro 15 on 2022/10/20.
//

import Foundation

class NewsViewModel {
    var pageNumber: CObservable<String> = CObservable("3000") //pageNumber가 텍스트필드안에 보여져야함
    
    var sample: CObservable<[News.NewsItem]> = CObservable(News.items)
    
    func changePageNumberFormat(text: String) {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let text = text.replacingOccurrences(of: ",", with: "") //콤마 삭제해서 String->Int 변환 가능하도록 설정
        guard let number = Int(text) else { return } //한번 콤마가 생기면 String->Int 변환이 안되기 때문에 콤마 삭제해줘야 함
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
