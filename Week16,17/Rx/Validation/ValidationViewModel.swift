//
//  ValidationViewModel.swift
//  Week16,17
//
//  Created by Mac Pro 15 on 2022/10/27.
//

import Foundation

import RxCocoa
import RxSwift

class ValidationViewModel {
    
    let validText = BehaviorRelay(value: "닉네임은 최소 8자 이상 필요합니다")
    
    struct Input {
        let text: ControlProperty<String?> //let validation = nameTextField.rx.text에서 text타입인 ControlProperty로 프로퍼티 생성
        let tap: ControlEvent<Void> //stepButton.rx.tap
    }
    
    struct Output {
        let validation: Observable<Bool> //validation에 대한 연산을 거치고 뷰컨트롤러로 전달할 값의 타입을 가진 프로퍼티 생성
        let tap: ControlEvent<Void> //input, output 동일
        let text: Driver<String> //viewModel.validText에서 구독할 대상의 타입가진 프로퍼티 생성
    }
    
    //input->output 바꿔주는 메서드
    func transform(input: Input) -> Output{
        let valid = input.text //let input = ValidationViewModel.Input(text: nameTextField.rx.text, tap: stepButton.rx.tap)에서 input을 통해 text에 접근할 수 있으므로 let validation = nameTextField.rx.text과 동일
            .orEmpty //String타입
            .map { $0.count >= 8 } //Bool타입
            .share() //subject 내부에 share가 있기 때문에 subject에서는 share 따로 안써도 됨
        
        let text = validText.asDriver() //asDriver까지 연산메서드에서 처리
        
        return Output(validation: valid, tap: input.tap, text: text)
    }
}
