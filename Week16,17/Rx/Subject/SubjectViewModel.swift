//
//  SubjectViewModel.swift
//  Week16,17
//
//  Created by Mac Pro 15 on 2022/10/25.
//

import Foundation

import RxCocoa
import RxSwift
import Alamofire

//뷰모델이 공통적으로 가지고 있는 구조를 프로토콜 만들기(associated type 사용-제네릭과 비슷한 특성)
protocol CommonViewModel {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}

struct Contact {
    var name: String
    var age: Int
    var number: String
}

class SubjectViewModel: CommonViewModel {
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
    
    struct Input {
        let addTap: ControlEvent<Void>
        let resetTap: ControlEvent<Void>
        let newTap: ControlEvent<Void>
        let searchText: ControlProperty<String?>
    }
    
    struct Output {
        let addTap: ControlEvent<Void>
        let resetTap: ControlEvent<Void>
        let newTap: ControlEvent<Void>
        let list: Driver<[Contact]>
        let searchText: Observable<String>
    }
    
    func transform(input: Input) -> Output {
        let list = list.asDriver(onErrorJustReturn: [])
        let text = input.searchText
            .orEmpty
            .debounce(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance) //debounce: 검색어 입력 후 일정시간 후 진행(네트워크 통신 때 서버 요청 콜수 줄일 수 있음)
            .distinctUntilChanged() //같은 값을 받지 않음(네트워크 통신 때 검색기록 있는 경우면 네트워크 통신하지 않고 검색기록 저장된 곳에서 데이터 불러옴)
        return Output(addTap: input.addTap, resetTap: input.resetTap, newTap: input.newTap, list: list, searchText: text)
    }
}

