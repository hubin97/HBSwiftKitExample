//
//  PodCastListController.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/9.

import Foundation
import Kingfisher

// MARK: - global var and methods

// MARK: - main class
class PodCastAlbumDetailController: ViewController, ViewModelProvider {
    typealias ViewModelType = PodCastAlbumDetailViewModel
    
    // 五音Jw-明月天涯.mp3
    let audioPlayerManager: AudioPlayerManager = {
        return AudioPlayerManager.shared
    }()
    
    lazy var backButton: UIButton = {
        let _backButton = UIButton(type: .custom)
        _backButton.setImage(R.image.ib_back()?.adaptRTL, for: .normal)
        _backButton.addTarget(self, action: #selector(tapBackAction), for: .touchUpInside)
        return _backButton
    }()
    
    lazy var listScroll: UIScrollView = {
        let _scrollView = UIScrollView()
        _scrollView.delegate = self
        return _scrollView
    }()
    
    // 海报
    lazy var posterView: PodCastPosterView = {
        let _posterView = PodCastPosterView()
        return _posterView
    }()
    
    lazy var tableView: UITableView = {
        let _tableView = UITableView(frame: .zero, style: .plain)
        _tableView.backgroundColor = .white
        _tableView.separatorStyle = .none
        _tableView.delegate = self
        _tableView.dataSource = self
        _tableView.rowHeight = vm.rowHeight
        _tableView.isScrollEnabled = false
        _tableView.registerCell(PodCastAudioCell.self)
        return _tableView
    }()
    
    override func setupLayout() {
        super.setupLayout()
        naviBar.isHidden = true
        view.addSubview(listScroll)
        view.addSubview(backButton)
        listScroll.addSubview(posterView)
        listScroll.addSubview(tableView)
        
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.equalTo(view).offset(10)
            make.width.height.equalTo(44)
        }
        
        listScroll.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        posterView.snp.makeConstraints { make in
            make.top.equalToSuperview()//.offset(-kStatusBarHeight)
            make.leading.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(vm.posterViewHeight)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(posterView.snp.bottom)
            make.leading.equalToSuperview()
            make.centerX.equalToSuperview()
            //make.bottom.equalToSuperview()
            make.height.equalTo(vm.rowHeight * CGFloat(vm.trackListRelay.value.count))
            make.bottom.equalTo(listScroll.snp.bottom)
        }
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        self.listScroll.contentSize = vm.contentSize
        self.posterView.configure(with: vm.albumMeta)

        self.vm.trackListRelay
            //.distinctUntilChanged()
            .asDriver(onErrorJustReturn: []).drive(onNext: {[weak self] list in
                guard let self = self else { return }
                self.audioPlayerManager.setPlaylistList(with: list)
                
                self.tableView.reloadData()
                self.listScroll.contentSize = self.vm.contentSize
                self.tableView.snp.updateConstraints { make in
                    make.height.equalTo(self.vm.rowHeight * CGFloat(list.count))
                }
            }).disposed(by: rx.disposeBag)
        
//        self.vm.audioListRelay.asDriver().drive(onNext: {[weak self] list in
//            guard let self = self else { return }
//            self.tableView.reloadData()
//            self.listScroll.contentSize = self.vm.contentSize
//            self.tableView.snp.updateConstraints { make in
//                make.height.equalTo(self.vm.rowHeight * CGFloat(list.count))
//            }
//        }).disposed(by: rx.disposeBag)
    }
}

// MARK: - private mothods
extension PodCastAlbumDetailController {
}

extension PodCastAlbumDetailController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let offsetY = scrollView.contentOffset.y + kStatusBarHeight
//        //print("offsetY: \(offsetY)")
//        if -offsetY > 0 {
//            let height = vm.posterViewHeight - offsetY
//            //self.listScroll.contentSize = CGSize(width: 0, height: CGFloat(vm.podCastList.count) * vm.rowHeight + height)
//            posterView.snp.updateConstraints { make in
//                make.height.equalTo(height)
//            }
//        }
    }
}

// MARK: - call backs
extension PodCastAlbumDetailController {
    
    @objc func tapBackAction() {
        backAction()
    }
}

// MARK: - delegate or data source
extension PodCastAlbumDetailController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.trackListRelay.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = vm.trackListRelay.value[indexPath.row]
        let cell = tableView.getReusableCell(PodCastAudioCell.self)
        cell.bind(to: PodCastAudioCellViewModel(item: item))
        //cell.configure(with: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = vm.trackListRelay.value[indexPath.row]
        self.navigator.show(provider: AppScene.PodCastAudioDetail(viewModel: PodCastAudioDetailViewModel(with: item)), sender: self)
    }
}
