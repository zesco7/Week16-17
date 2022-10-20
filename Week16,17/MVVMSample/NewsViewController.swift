//
//  NewsViewController.swift
//  Week16,17
//
//  Created by Mac Pro 15 on 2022/10/20.
//

import UIKit

class NewsViewController: UIViewController {

    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var loadButton: UIButton!
    
    var viewModel = NewsViewModel()
    var dataSource : UICollectionViewDiffableDataSource<Int, News.NewsItem>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureHierachy()
        configureDataSource()
        bindData()
        configureView()
       
    }
    
    func configureView() {
        numberTextField.addTarget(self, action: #selector(numberTextFieldChanged), for: .editingChanged)
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        loadButton.addTarget(self, action: #selector(loadButtonTapped), for: .touchUpInside)
    }
    
    func bindData() {
         //numberTextField.text = "3000"
         viewModel.pageNumber.bind { value in
             self.numberTextField.text = value
         } //numberTextField.text = "3000"처럼 뷰컨트롤러에서 직접 보여주는게 아니라 뷰모델에서 내용을 전달받아 보여줌
        
        //뉴스 추가 제거를 뷰모델 처리: datasource초기화하기 전에 사용하면 found nil 발생하므로 configureDataSource()에서 datasource초기화 먼저 해줘야함
        viewModel.sample.bind { item in
            var snapshot = NSDiffableDataSourceSnapshot<Int, News.NewsItem>()
            snapshot.appendSections([0])
            snapshot.appendItems(News.items)
            self.dataSource.apply(snapshot, animatingDifferences: false)
        }
    }
    
    @objc func numberTextFieldChanged() {
        //numberTextFieldChanged에서 뷰모델에 숫자를 넘겨주면 뷰모델에서 천단위자릿수를 구분하고 뷰모델이 다시 뷰컨트롤러로 내용을 넘긴다.
        guard let text = numberTextField.text else { return }
        viewModel.changePageNumberFormat(text: text)
    }
    
    @objc func resetButtonTapped() {
        viewModel.resetSample()
    }
    
    @objc func loadButtonTapped() {
        viewModel.loadSample()
    }
}

extension NewsViewController {
    func configureHierachy() { //addSubView, init, snapkit
        collectionView.collectionViewLayout = createLayout()
        collectionView.backgroundColor = .lightGray
    }
    
    func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, News.NewsItem>(handler: { cell, indexPath, itemIdentifier in
            var content = UIListContentConfiguration.valueCell()
            content.text = itemIdentifier.title
            content.secondaryText = itemIdentifier.body
            cell.contentConfiguration = content
        })
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
            return cell
        })
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, News.NewsItem>()
        snapshot.appendSections([0])
        snapshot.appendItems(News.items)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func createLayout() -> UICollectionViewLayout {
        let configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        return layout
    }
}
