//
//  AudioListController.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/27.

import Foundation

// MARK: - global var and methods

// MARK: - main class
class AudioListController: ViewController, ViewModelProvider {
    typealias ViewModelType = AudioListViewModel
    
    lazy var tableView: UITableView = {
        let _tableView = UITableView(frame: .zero, style: .grouped)
        _tableView.registerCell(AudioListCell.self)
        _tableView.dataSource = self
        _tableView.delegate = self
        _tableView.rowHeight = 60
        return _tableView
    }()
    
    override func setupLayout() {
        super.setupLayout()
        self.naviBar.title = "Audio List"
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(naviBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

// MARK: - private mothods
extension AudioListController { 
}

// MARK: - call backs
extension AudioListController { 
}

// MARK: - delegate or data source
extension AudioListController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return vm.sections.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.sections[section].playList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = vm.sections[indexPath.section].playList[indexPath.row]
        let cell = tableView.getReusableCell(AudioListCell.self)
        cell.configure(with: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let playList = vm.sections[indexPath.section].playList
        AVPlayerManager.shared.setPlaylist(AVPlaylist(playlist: playList, playbackMode: .none))
        navigator.show(provider: AppScene.audioPlayer(viewModel: AudioPlayerViewModel(index: indexPath.row)), sender: self, transition: .modal(type: .fullScreen))
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return vm.sections[section].type.value
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
}
