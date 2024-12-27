//
//  MediaListController.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/27.

import Foundation

// MARK: - global var and methods

// MARK: - main class
class MediaListController: ViewController {
    
    let items = ["Audio Player", "Video Player", "Live Player", "Camera Player"]
    
    lazy var tableView: UITableView = {
        let _tableView = UITableView(frame: .zero, style: .plain)
        _tableView.backgroundColor = .white
        _tableView.registerCell(UITableViewCell.self)
        _tableView.dataSource = self
        _tableView.delegate = self
        _tableView.rowHeight = 50
        return _tableView
    }()
    
    override func setupLayout() {
        super.setupLayout()
        self.naviBar.title = "Media Player"
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(naviBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    override func bindViewModel() {
        super.bindViewModel()
    }
}

// MARK: - private mothods
extension MediaListController { 
}

// MARK: - call backs
extension MediaListController { 
}

// MARK: - delegate or data source
extension MediaListController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.getReusableCell(UITableViewCell.self)
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            navigator.show(provider: AppScene.audioList(viewModel: AudioListViewModel()), sender: self)
        case 1:
            navigator.show(provider: AppScene.videoList(viewModel: VideoListViewModel()), sender: self)
//        case 2:
//            let vc = LivePlayerController()
//            navigationController?.pushViewController(vc, animated: true)
//        case 3:
//            let vc = CameraPlayerController()
//            navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
}

// MARK: - other classes
