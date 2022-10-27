//
//  ValidationViewController.swift
//  Week16,17
//
//  Created by Mac Pro 15 on 2022/10/27.
//

import UIKit

import RxCocoa
import RxSwift

class ValidationViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var validationLabel: UILabel!
    @IBOutlet weak var stepButton: UIButton!
    
    let disposeBag = DisposeBag() //리소스 정리에 사용
    let viewModel = ValidationViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bind()
        //observableVSSubject()
    }
    
    func bind() {
        viewModel.validText
            .asDriver() //relay짝궁은 DRIVER
            .drive(validationLabel.rx.text)
            .disposed(by: disposeBag)
        
        let validation = nameTextField.rx.text //String?타입
            .orEmpty //String타입
            .map { $0.count >= 8 } //Bool타입
            .share() //subject 내부에 share가 있기 때문에 subject에서는 share 따로 안써도 됨
        
        validation
            .bind(to: stepButton.rx.isEnabled, validationLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        validation
            .withUnretained(self)
            .bind { (vc, value) in
                let color: UIColor = value ? .systemPink : .lightGray
                self.stepButton.backgroundColor = color
            }
            .disposed(by: disposeBag)
        
        //stream, sequence 두 개 비슷한 개념으로 이해하면 됨
        stepButton.rx.tap
            .subscribe { _ in
                print("next")
            } onError: { error in
                print("error")
            } onCompleted: {
                print("complete")
            } onDisposed: {
                print("dispose")
            }
            .disposed(by: disposeBag)
            //.disposed(by: DisposeBag()) //새롭게 인스턴스를 할당하면 리소스 해제되어서 탭 작동이 안됨(수동으로 리소스 정리하는 것과 같음 / .dispose()와 같음)
        
        stepButton.rx.tap
            .bind { _ in
                print("SHOW ALERT")
            }
            .disposed(by: disposeBag)
    }
    
    func observableVSSubject() {
        //MARK: - .share: 옵저버 3개면 세번 실행 되지만 .share쓰면 한번만 실행
        let testA = stepButton.rx.tap
            .map { "안녕하세요" }
            .share()
        
        testA
            .bind(to: validationLabel.rx.text)
            .disposed(by: disposeBag)
        
        testA
            .bind(to: nameTextField.rx.text)
            .disposed(by: disposeBag)
        
        testA
            .bind(to: stepButton.rx.title())
            .disposed(by: disposeBag)
        
        //MARK: - .drive: Stream공유 가능함(Share사용 안해도 리소스 정리됨)
        let testB = stepButton.rx.tap
            .map { "안녕하세요" }
            .asDriver(onErrorJustReturn: "")
        
        testB
            .drive(validationLabel.rx.text)
            .disposed(by: disposeBag)
        
        testB
            .drive(nameTextField.rx.text)
            .disposed(by: disposeBag)
        
        testB
            .drive(stepButton.rx.title())
            .disposed(by: disposeBag)
        
        //MARK: - Observable: 각각 다른 리소스로 작업 실행행(출력값이 다름)
        let sampleInt = Observable<Int>.create { observer in
            observer.onNext(Int.random(in: 1...100))
            return Disposables.create()
        }
        
        sampleInt.subscribe { value in
            print("sampleInt: \(value)")
        }
        .disposed(by: disposeBag)
        
        sampleInt.subscribe { value in
            print("sampleInt: \(value)")
        }
        .disposed(by: disposeBag)
        
        sampleInt.subscribe { value in
            print("sampleInt: \(value)")
        }
        .disposed(by: disposeBag)
        
        //MARK: - subject: stream공유하므로 share없어도 리소스 하나로 작업 실행(출력값이 같음)
        let subjectInt = BehaviorSubject(value: 0)
        subjectInt.onNext(Int.random(in: 1...100))
        
        subjectInt.subscribe { value in
            print("subjectInt: \(value)")
        }
        .disposed(by: disposeBag)
        
        subjectInt.subscribe { value in
            print("subjectInt: \(value)")
        }
        .disposed(by: disposeBag)
        
        subjectInt.subscribe { value in
            print("subjectInt: \(value)")
        }
        .disposed(by: disposeBag)
    }
}
