//
//  RxCocoaExampleViewController.swift
//  Week16,17
//
//  Created by Mac Pro 15 on 2022/10/24.
//

import UIKit
import RxCocoa
import RxSwift


//화면전환 할 때마다 RxCocoaExampleViewController가 메모리에 올라감
class RxCocoaExampleViewController: UIViewController {

    @IBOutlet weak var simpleTableView: UITableView!
    @IBOutlet weak var simplePickerView: UIPickerView!
    @IBOutlet weak var simpleLabel: UILabel!
    @IBOutlet weak var simpleSwitch: UISwitch!
    
    @IBOutlet weak var signName: UITextField!
    @IBOutlet weak var signEmail: UITextField!
    @IBOutlet weak var signButton: UIButton!
    
    @IBOutlet weak var nicknameLabel: UILabel!
    
    
    var disposeBag = DisposeBag()
    var nickname = Observable.just("Jack")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nickname
            .bind(to: nicknameLabel.rx.text)
            //.disposed(by: DisposeBag)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            //Observable은 이벤트 전달만 하기 때문에 값을 저장할 수 없음. 그래서 이벤트(next,complete,error) 처리와 구독(subscribe)역할을 같이 할 수 있는 subject 등장
            //self.nickname = "Hello"
        }

        setTableView()
        setPickerView()
        setSwitch()
        setSign()
        setOperator()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        print(#function)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print(#function)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print(#function)
    }
    
    //ViewController가 deinit되면 dispose도 알아서 동작한다.
    //DisposeBag 새롭게 할당하거나 nil전달: 원하는 시점에 할당하면 기존 리소스는 자동해제 됨(한번에 리소스 정리) *예외케이스: rootvc에 interval이 있는 경우
    deinit {
        print("RxCocoaExampleViewController")
    }
    
    //무한시퀀스 이벤트라서 다른 이벤트와 달리 dispose가 되지 않음.
    func setOperator() {
        let intervalObservable = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe { value in
                print("interval - \(value)")
            } onError: { error in
                print("interval - \(error)")
            } onCompleted: {
                print("interval completed")
            } onDisposed: {
                print("interval disposed")
            }
            .disposed(by: disposeBag)
        
        //DisposeBag: 리소스 해제 케이스
        //일반적으로는 ViewController가 deinit되면 dispose도 알아서 동작하기 때문에 개별해제할 필요 없으나 예외케이스가 있으면 개별해제함 ex.3,4번)
          //1. 시퀀스 끝날 때(subsribe의 completed)
          //2. 클래스가 deinit될 때(bind 자동해제 됨)
          //3. dispose 직접 호출 -> dispose()는 구독하는 것 마다 별도로 관리해야하기 때문에 이벤트객체가 많아지면 번거로울 수 있음
          //4. DisposeBag 새롭게 할당하거나 nil전달: 원하는 시점에 할당하면 기존 리소스는 자동해제 됨(한번에 리소스 정리) *예외케이스: rootvc에 interval이 있는 경우

        //(ViewController deinit처리
        DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
            //intervalObservable.dispose() //3. intervalObservable이 10개 있으면 10개 각각 dispose해줘야 리소스 해제됨
            self.disposeBag = DisposeBag() //4. intervalObservable에서 .disposed(by: disposeBag)에 새로운 DisposeBag 할당
        }
        
        let itemsA = [3.3, 4.0, 5.0, 2.0, 3.6, 4.8]
        let itemsB = [2.3, 2.0, 1.3]
        
        Observable.repeatElement("JACK") //반복실행 메서드(Infinite Observable Sequence)
            .take(5) //실행횟수 설정(Finite Observable Sequence)
            .subscribe { value in
                print("repeat - \(value)")
            } onError: { error in
                print("repeat - \(error)")
            } onCompleted: {
                print("repeat completed")
            } onDisposed: {
                print("repeat disposed")
            }
            .disposed(by: disposeBag)
        
        Observable.just(itemsA)
            .subscribe { value in
                print("just - \(value)")
            } onError: { error in
                print("just - \(error)")
            } onCompleted: {
                print("just completed")
            } onDisposed: {
                print("just disposed")
            }
            .disposed(by: disposeBag)
        
        Observable.of(itemsA, itemsB) //of는 매개변수 2개 이상 가능
            .subscribe { value in
                print("of - \(value)")
            } onError: { error in
                print("of - \(error)")
            } onCompleted: {
                print("of completed")
            } onDisposed: {
                print("of disposed")
            }
            .disposed(by: disposeBag)
        
        Observable.from(itemsA)
            .subscribe { value in
                print("from - \(value)")
            } onError: { error in
                print("from - \(error)")
            } onCompleted: {
                print("from completed")
            } onDisposed: {
                print("from disposed")
            }
            .disposed(by: disposeBag)
    }
    
    //텍스트필드1,2는 observable, 레이블은 observer, bind
    //등록된 객체가 바뀌면 신호보내는 메서드: combineLatest, 옵셔널처리 프로퍼티: OrEmpty
    func setSign() {
        //Observable 클로저 반환값이 simpleLabel.rx.text에 bind되어있기 때문에 값이 변경되면 simpleLabel.rx.text가 반응하여 UI가 변경된다.
        Observable.combineLatest(signName.rx.text.orEmpty, signEmail.rx.text.orEmpty) { value1, value2 in
            return "name은 \(value1)이고 이메일은 \(value2)입니다"
    }
        .bind(to: simpleLabel.rx.text)
        .disposed(by: disposeBag)
        
        //UITextField->Reactive->String->String->Int
        signName.rx.text.orEmpty
            .map { $0.count < 4}
            .bind(to: signEmail.rx.isHidden)
            .disposed(by: disposeBag)
        
        signEmail.rx.text.orEmpty
            .map { $0.count > 4 }
            .bind(to: signButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        signButton.rx.tap
//            .subscribe { [weak self] _ in //deinit 시키려면 ARC카운트되지 않게 [weak self]처리 꼭 해줘야함
//                self?.showAlert()
//            }
            .withUnretained(self) //rx6.0부터 .withUnretained(self)사용하면 [weak self] 대신 deinit가능
            .subscribe(onNext: { vc, _ in //withUnretained 대상이 되는 뷰컨트롤러 추가
                vc.showAlert()
            })
            .disposed(by: disposeBag)
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "하하하", message: nil, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default)
        alert.addAction(ok)
        present(alert, animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    func setSwitch() {
        Observable.just(false) //초기값 false로 지정(just, of 둘 다사용 가능)
            .bind(to: simpleSwitch.rx.isOn) //초기값 false를 스위치에 바인드시킴(=초기값 false일때 버튼누르면 on으로 UI변경)
            .disposed(by: disposeBag)
    }
    
    func setTableView() {
        simpleTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        //just: 하나의 값을 방출하는 연산자
        let items = Observable.just([
            "First Item",
            "Second Item",
            "Third Item"
        ])

        //simpleTableView가 Observable을 구독하고 있음(bind): items를 구독하면 items가 가지고 있는 데이터를 재사용셀에 클로저로 받는다.
        items
        .bind(to: simpleTableView.rx.items) { (tableView, row, element) in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
            cell.textLabel?.text = "\(element) @ row \(row)"
            return cell
        }
        .disposed(by: disposeBag)

        //MARK: - modelSelected(didSelectedRowAt): 테이블뷰셀에 있는 데이터를 구독하고 클로저로 받아 콘솔에 프린트한다.(modelSelected는 indexPath만 가져올 수 있음(data는 안 됨)
        simpleTableView.rx.modelSelected(String.self).subscribe { value in
            print(value) //onNext 생략
        } onError: { error in
            print("error")
        } onCompleted: {
            print("completed")
        } onDisposed: {
            print("disposed")
        }
        .disposed(by: disposeBag)
        
        //UI는 이벤트처리 안 할 일이 없으므로(버튼 누를 때마다 계속 레이블에 나와야 하니까) subscribe 아닌 bind로 처리(무한시퀀스)
        simpleTableView.rx.modelSelected(String.self)
            .map { data in "\(data)를 클릭했습니다."}
            .bind(to: simpleLabel.rx.text)
        .disposed(by: disposeBag)
    }
    
    func setPickerView() {
        let items = Observable.just([
                "영화",
                "애니",
                "드라마",
                "기타"
            ])
     
        items
            .bind(to: simplePickerView.rx.itemTitles) { (row, element) in
                return element
            }
            .disposed(by: disposeBag)
        
        //피커선택시 레이블에 행내용 표시(map+bind or subscribe)
        simplePickerView.rx.modelSelected(String.self)
            .map { $0.description }
            .bind(to: simpleLabel.rx.text) //레이블이 피커선택했을 때 값을 구독했으므로 레이블 내용은 피커선택값이 됨(subscribe onNext만 호출하거나 map+bind로 처리가능)
//            .subscribe(onNext: { value in
//                print(value)
//            })
            .disposed(by: disposeBag)
    }
}
