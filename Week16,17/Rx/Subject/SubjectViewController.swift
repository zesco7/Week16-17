//
//  SubjectViewController.swift
//  Week16,17
//
//  Created by Mac Pro 15 on 2022/10/25.
//

import UIKit

import RxCocoa
import RxSwift

class SubjectViewController: UIViewController {
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var resetButton: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newButton: UIBarButtonItem!
    
    let publish = PublishSubject<Int>() //PublishSubject는 초기값 없음.(구독 이후 시점부터 emit되는 이벤트 처리)
    let behavior = BehaviorSubject(value: 100) //BehaviorSubject는 초기값 필수(구독 전 가장 최근 emit한 이벤트 1개 처리)
    let replay = ReplaySubject<Int>.create(bufferSize: 3) //ReplaySubject는 초기값 필수(bufferSize 갯수에 따라 구독 전 가장 최근 emit한 이벤트 처리), 작성된 이벤트 갯수만큼 메모리에서 가지고 있다가 구독 직후 한번에 이벤트 전달
    let async = AsyncSubject<Int>()
    
    let disposeBag = DisposeBag()
    let viewModel = SubjectViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        behaviorSubject()
        //        publishSubject()
        //        replaySubject()
        //        asyncSubject()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ContactCell")
        
        viewModel.list //list 변경될때 마다 bind실행(무한시퀀스로서 종료없이 list변경될때마다 계속 실행)
            .bind(to: tableView.rx.items(cellIdentifier: "ContactCell", cellType: UITableViewCell.self)) { (row, element, cell) in                                      cell.textLabel?.text = "\(element.name): \(element.age)세 (\(element.number))"
            }
            .disposed(by: disposeBag)
        
        addButton.rx.tap //addButton버튼 눌렀을 때(observable역할로서 이벤트를 넘김)
            .withUnretained(self)
            .subscribe { (vc, _) in //클로저로 vc데이터를 받고
                vc.viewModel.fetchData() //observer인 list가 onNext로 contactData를 받을 수 있음(PublishSubject타입이기 때문에)
            }
            .disposed(by: disposeBag)
        
        resetButton.rx.tap
            .withUnretained(self)
            .subscribe { (vc, _) in
                vc.viewModel.resetData()
            }
            .disposed(by: disposeBag)
        
        newButton.rx.tap
            .withUnretained(self)
            .subscribe { (vc, _) in
                vc.viewModel.newData()
            }
            .disposed(by: disposeBag)
        
        searchBar.rx.text.orEmpty //orEmpty로 옵셔널에러 처리
            .withUnretained(self)
        //debounce: 검색어 입력 후 일정시간 후 진행(네트워크 통신 때 서버 요청 콜수 줄일 수 있음)
            .debounce(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
        //.distinctUntilChanged //같은 값을 받지 않음(네트워크 통신 때 검색기록 있는 경우면 네트워크 통신하지 않고 검색기록 저장된 곳에서 데이터 불러옴)
            .subscribe { (vc, value) in
                print("======\(value)")
                vc.viewModel.filterData(query: value)
            }
            .disposed(by: disposeBag)
    }
    
    
    func replaySubject() { //ReplaySubject는 초기값 필수(bufferSize 갯수에 따라 구독 전 가장 최근 emit한 이벤트 처리)
        replay.onNext(100)
        replay.onNext(200)
        replay.onNext(300)
        replay.onNext(400)
        replay.onNext(500) //bufferSize 갯수에 따라 구독전 값 최근 값을 같이 emit(ex. bufferSize = 1은 500, bufferSize = 2는 400, 500)
        
        replay
            .subscribe { value in
                print("replay - \(value)")
            } onError: { error in
                print("replay - \(error)")
            } onCompleted: {
                print("replay completed")
            } onDisposed: {
                print("replay disposed")
            }
            .disposed(by: disposeBag)
        
        replay.onNext(3)
        replay.onNext(4)
        
        replay.onCompleted()
        
        replay.onNext(5)
        replay.onNext(6)
    }
    
    func behaviorSubject() { //BehaviorSubject는 초기값 필수(구독 전 가장 최근 emit한 이벤트 1개 처리)
        behavior.onNext(1) //구독전 가장 최근 값을 emit해야하기 때문에 초기값이 필수다.(ex. 구독전에 emit 값 없으면 초기값 1 처리)
        behavior.onNext(2) //구독전 가장 최근 값을 emit한 값이 2이므로 2만 처리하고 초기값 1 생략
        
        behavior
            .subscribe { value in
                print("behavior - \(value)")
            } onError: { error in
                print("behavior - \(error)")
            } onCompleted: {
                print("behavior completed")
            } onDisposed: {
                print("behavior disposed")
            }
            .disposed(by: disposeBag)
        
        behavior.onNext(3)
        behavior.onNext(4)
        
        behavior.onCompleted()
        
        behavior.onNext(5)
        behavior.onNext(6)
    }
    
    func publishSubject() { //PublishSubject는 초기값 없음.(구독 이후 시점부터 emit되는 이벤트 처리)
        //subscribe 전이기 때문에 1,2 프린트 안됨
        publish.onNext(1) //publish.on(.next(1))과 같음
        publish.onNext(2)
        
        publish
            .subscribe { value in //subscribe 메서드에서 dispose를 리턴값으로 가지고 있기 때문에 리소스 관리 해줘야함
                print("publish - \(value)") //이벤트방출 할 때마다(값변경 될 때마다) 콘솔에 프린트
            } onError: { error in
                print("publish - \(error)")
            } onCompleted: {
                print("publish completed")
            } onDisposed: {
                print("publish disposed")
            }
            .disposed(by: disposeBag)
        
        publish.onNext(3) //observable역할 할 수 있으므로 publish = 3 형태가 아니라 publish.onNext(3) 형태로 값 할당
        publish.onNext(4)
        
        publish.onCompleted() //subscribe완료되었기 때문에 5,6 프린트 안됨
        
        publish.onNext(5)
        publish.onNext(6)
    }
}

extension SubjectViewController {
    func asyncSubject() {
        async.onNext(100)
        async.onNext(200)
        async.onNext(300)
        async.onNext(400)
        async.onNext(500)
        
        async
            .subscribe { value in
                print("replay - \(value)")
            } onError: { error in
                print("replay - \(error)")
            } onCompleted: {
                print("replay completed")
            } onDisposed: {
                print("replay disposed")
            }
            .disposed(by: disposeBag)
        
        async.onNext(3)
        async.onNext(4)
        
        async.onCompleted() //event complete 전 한개만 emit하고 complete없으면 작동 안함(4 처리)
        
        async.onNext(5)
        async.onNext(6)
    }
}

