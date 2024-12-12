//
//  PodCastAlbumListViewModel.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/12.

import Foundation
import RxRelay

// MARK: - global var and methods

// MARK: - main class
class PodCastAlbumListViewModel: ViewModel {
    
    var albumListRelay = BehaviorRelay<[PodcastAlbumListMeta]>(value: [])
   
    required init() {
        super.init()
        self.fetchAlbums()
    }
}

// MARK: - private mothods
extension PodCastAlbumListViewModel {
    
    func fetchAlbums() {
        PodcastRequest.albums().done { albums in
            self.albumListRelay.accept(albums)
        }.catch { error in
            print(error.localizedDescription)
        }
    }
}

// MARK: - call backs
extension PodCastAlbumListViewModel { 
}

// MARK: - delegate or data source
extension PodCastAlbumListViewModel { 
}

// MARK: - other classes
