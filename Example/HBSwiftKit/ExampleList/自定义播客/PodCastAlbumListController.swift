//
//  PodCastAlbumListController.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/12.

import Foundation

// MARK: - global var and methods

// MARK: - main class
class PodCastAlbumListController: ViewController, ViewModelProvider {
    typealias ViewModelType = PodCastAlbumListViewModel
    
    lazy var listView: UITableView = {
        let _listView = UITableView(frame: CGRect.zero, style: .grouped)
        _listView.backgroundColor = .white
        _listView.registerCell(PodCastAlbumCell.self)
        _listView.dataSource = self
        _listView.delegate = self
        //_listView.separatorColor = Colors.separator
        return _listView
    }()

    override func setupLayout() {
        self.view.backgroundColor = .white
        self.naviBar.title = "专辑列表"
        self.view.addSubview(listView)
        self.listView.snp.makeConstraints { make in
            make.top.equalTo(naviBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        self.vm.albumListRelay.asDriver(onErrorJustReturn: []).drive(onNext: {[weak self] albums in
            print("albums: \(albums.count)")
            self?.listView.reloadData()
        }).disposed(by: rx.disposeBag)
    }
}

// MARK: - private mothods
extension PodCastAlbumListController { 
}

// MARK: - call backs
extension PodCastAlbumListController { 
}

// MARK: - delegate or data source
extension PodCastAlbumListController: UITableViewDataSource, UITableViewDelegate {
    
//    func numSections(in collectionSkeletonView: UITableView) -> Int {
//        return 1
//    }
//    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 3
//    }
//    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
//        return NSStringFromClass(ExploreListCell.self)
//    }
//    func collectionSkeletonView(_ skeletonView: UITableView, skeletonCellForRowAt indexPath: IndexPath) -> UITableViewCell? {
//        return skeletonView.getReusableCell(ExploreListCell.self)
//    }
    func collectionSkeletonView(_ skeletonView: UITableView, prepareCellForSkeleton cell: UITableViewCell, at indexPath: IndexPath) { }

    //
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.vm.albumListRelay.value.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.getReusableCell(PodCastAlbumCell.self)
        let model = vm.albumListRelay.value[indexPath.row]
        cell.configure(with: model)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = vm.albumListRelay.value[indexPath.row]
        self.navigator.show(provider:AppScene.podcastAlbumDetail(viewModel: PodCastAlbumDetailViewModel(with: model)), sender: self)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(frame: CGRect(x: 0, y: 0, width: tableView.width, height: 1))
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: CGRect(x: 0, y: 0, width: tableView.width, height: 10))
    }
}
