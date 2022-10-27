//
//  SubscribeViewController.swift
//  Week16,17
//
//  Created by Mac Pro 15 on 2022/10/26.
//

import UIKit

import RxCocoa
import RxSwift

class SubscribeViewController: UIViewController {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var label: UILabel!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //1.
        button.rx.tap
            .subscribe { [weak self] _ in
                self?.label.text = "안녕하숑"
            }
            .disposed(by: disposeBag)
        
        //2.
        button.rx.tap
            .withUnretained(self)
            .subscribe { (vc, _) in
                self.label.text = "안녕하숑"
            }
            .disposed(by: disposeBag)
        
        //3. observe: UI관련 없는 부분 백그라운드 작업발생 할 때 처리 방식(네트워크 통신이나 파일 다운 등) *UI관련 부분은 메인쓰레드에서 작업
        button.rx.tap
            .map { } //글로벌 쓰레드
            .observe(on: MainScheduler.instance) //다른 쓰레드로 동작하도록 변경(글로벌->메인) *백그라운드 작업하다가 메인쓰레드로 변경하지 않으면 에러발생하는 것 방지
            .map { } //메인 쓰레드
            .withUnretained(self)
            .subscribe { (vc, _) in
                self.label.text = "안녕하숑"
            }
            .disposed(by: disposeBag)
        
        //4. bind: UI관련 된 부분이면 에러 핸들링 할 필요없는 bind가 목적성에 더 부합
        button.rx.tap
            .withUnretained(self)
            .bind { (vc, _) in
                self.label.text = "안녕하숑"
            }
            .disposed(by: disposeBag)
        
        //5. operator로 데이터 stream 조작
        button.rx.tap //button타입 변경됨 rx->tap
            .map { "안녕 반가워" }
            .bind(to: label.rx.text)
            .disposed(by: disposeBag)
        
        //6. driver traits: bind 기능 + stream 공유 가능하여 리소스 낭비 방지, share()
        button.rx.tap
            .map { "안녕 반가워" }
            .asDriver(onErrorJustReturn: "") //에러발생 때 표시 메시지
            .drive(label.rx.text)
            .disposed(by: disposeBag)
    }
    

}
