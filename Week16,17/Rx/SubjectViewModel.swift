//
//  SubjectViewModel.swift
//  Week16,17
//
//  Created by Mac Pro 15 on 2022/10/25.
//

import Foundation

import RxCocoa
import RxSwift

struct Contact {
    var name: String
    var age: Int
    var number: String
}

class SubjectViewModel {
    var contactData = [
        Contact(name: "Jack", age: 21, number: "01011112222"),
        Contact(name: "Jack2", age: 23, number: "01033334444"),
        Contact(name: "Jack3", age: 25, number: "01055556666")
    ]
    
    var list = PublishSubject<[Contact]>() //받은 이벤트를 처리할 수 있도록 PublishSubject로 list초기화
    
    func fetchData() {
        list.onNext(contactData) //list에서 contactData 방출
    }
    
    func resetData() {
        list.onNext([]) //list에서 빈배열 방출
    }
    
    func newData() {
        let new = Contact(name: "고래밥", age: Int.random(in: 1...50), number: "")
        contactData.append(new)
        list.onNext([new])
        list.onNext(contactData)
    }
    
    func filterData(query: String) {
        let result = query != "" ? contactData.filter { $0.name.contains(query) } : contactData
        list.onNext(result)
    }
}

