//
//  CObservable.swift
//  Week16,17
//
//  Created by Mac Pro 15 on 2022/10/20.
//

//MVVM원칙: ViewModel에는 UIKit import하지 말자
import Foundation

import RxCocoa
import RxSwift

class CObservable<T> {
//    private var listener: ((T) -> Void)? = { value in
//        self.numberTextField.text = value
//    } //listener에 클로저가 저장된 형태
    
    private var listener: ((T) -> Void)?
    
    var value: T {
        didSet {
            listener?(value) //value값이 바뀌면 listener 실행
        }
    }
    
    init(_ value: T) {
        self.value = value
    }
    
    func bind(_ closure: @escaping (T) -> Void) {
        closure(value)
        listener = closure //listener에 클로저 저장
    }
}
