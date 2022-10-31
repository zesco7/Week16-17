//
//  SubscribeViewController.swift
//  Week16,17
//
//  Created by Mac Pro 15 on 2022/10/26.
//

import UIKit

import RxAlamofire
import RxCocoa
import RxDataSources
import RxSwift

class SubscribeViewController: UIViewController {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let disposeBag = DisposeBag()
    
    //데이터 재사용: 데이터소스, 표시할 테이블뷰, 셀위치, 셀에 표현할 데이터를 클로저로 넘김(diffable처리방식과 비슷하게 전역변수로 선언)
    lazy var dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Int>> (configureCell: { dataSource, tableView, indexPath, item in
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        cell.textLabel?.text = "\(item)" //행 내용 표시
        return cell
    })
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        testAlamofire()
        textRxDataSource()
        
        Observable.of(1,2,3,4,5,6,7,8,9,10)
            .skip(3) //3까지 스킵하고 4부터 실행 (4~10)
            .debug() //디버그 사용하면 print로 일일이 안찍어봐도 됨(4~10)
            .filter { $0 % 2 == 0 } //(4,6,8,10)
            .map { $0 * 2 } //(8,12,16,20)
            .subscribe { value in
                print("===\(value)")
            }
            .disposed(by: disposeBag)
        
        let buttonType = button
        let rxType = button.rx
        let controlEventType = button.rx.tap
        
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
    
    //Rx사용하여 네트워크 통신
    func testAlamofire() {
        //통신성공, 실패 두가지 경우만 있음: 네트워크객체 대응할 수 있는 single이 있음(driver같은 것)
        let url = APIKey.searchURL + "apple"
        request(.get, url, headers: ["Authorization": APIKey.authorization]) //requset(통신방식, 통신요청할URL, 헤더)
            .data() //응답내용을 데이터 타입으로 변경
            .decode(type: SearchPhoto.self, decoder: JSONDecoder()) //받은 데이터를 디코딩
            .subscribe { value in
                print(value)
            }
            .disposed(by: disposeBag)
    }
    
    //Rx사용하여 테이블뷰 section, row 생성
    func textRxDataSource() {
        //테이블뷰 등록
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        //헤더 내용 표시(bind보다 먼저 선언해줘야 함)
        dataSource.titleForHeaderInSection = { dataSource, index in
            return dataSource.sectionModels[index].model
        }
        
        //재사용할 데이터 설정
        Observable.just([
            SectionModel(model: "title", items: [1, 2, 3]),
            SectionModel(model: "title", items: [1, 2, 3]),
            SectionModel(model: "title", items: [1, 2, 3]),
        ])
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}
