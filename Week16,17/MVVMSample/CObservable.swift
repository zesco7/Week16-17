//
//  CObservable.swift
//  Week16,17
//
//  Created by Mac Pro 15 on 2022/10/20.
//

//MVVM원칙: ViewModel에는 UIKit import하지 말자
import Foundation

class CObservable<T> {
    private var listener: ((T) -> Void)?
    
    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    init(_ value: T) {
        self.value = value
    }
    
    func bind(_ closure: @escaping (T) -> Void) {
        closure(value)
        listener = closure
    }
    
}
