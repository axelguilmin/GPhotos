//
//  MediaItems.swift
//  Alamofire
//
//  Created by Deivi Taka on 21.08.19.
//

import Foundation
import Moya

public class MediaItems {
    
    public init() {}
    
    // MARK: List
    private struct List {
        var request = MediaItemsList.Request()
        var page = 0
    }
    private var currentList = List()
    
    // MARK: Search
    private struct Search {
        var request = MediaItemsSearch.Request()
        var page = 0
    }
    private var currentSearch = Search()

}

// MARK:- List
public extension MediaItems {
    
    func list(completion: @escaping (([MediaItem])->())) {
        if currentList.page > 0 && currentList.request.pageToken == nil {
            log.d("Reached end of mediaItems")
            completion([])
            return
        }
        
        if !GPhotos.checkScopes(with: [.readAndAppend, .readOnly, .readDevData]) {
            completion([])
            return
        }
        
        GPhotos.refreshTokenIfNeeded() {
            GPhotosApi.mediaItems.request(.list(req: self.currentList.request)) { (result) in
                switch result {
                case let .success(res):
                    guard let dict = GPhotosApi.handle(response: res) else {
                        completion([])
                        return
                    }
                    let listRes = MediaItemsList.Response(JSON: dict)
                    self.currentList.request.pageToken = listRes?.nextPageToken
                    self.currentList.page += 1
                    completion(listRes?.mediaItems ?? [])
                    
                case let .failure(error):
                    GPhotosApi.handle(error: error)
                    completion([])
                }
            }
        }
    }
    
    func reloadList(completion: @escaping (([MediaItem])->())) {
        currentList = List()
        list(completion: completion)
    }
}

// MARK:- Search
public extension MediaItems {
    
    func search(with request: MediaItemsSearch.Request, completion: @escaping (([MediaItem])->())) {
        currentSearch.request.albumId = request.albumId
        currentSearch.request.filters = request.filters
        currentSearch.request.pageSize = request.pageSize
        
        if currentSearch.page > 0 && currentSearch.request.pageToken == nil {
            log.d("Reached end of mediaItems")
            completion([])
            return
        }
        
        if !GPhotos.checkScopes(with: [.readAndAppend, .readOnly, .readDevData]) {
            completion([])
            return
        }
        
        GPhotos.refreshTokenIfNeeded() {
            GPhotosApi.mediaItems.request(.search(req: self.currentSearch.request)) { (result) in
                switch result {
                case let .success(res):
                    guard let dict = GPhotosApi.handle(response: res) else {
                        completion([])
                        return
                    }
                    let searchRes = MediaItemsList.Response(JSON: dict)
                    self.currentSearch.request.pageToken = searchRes?.nextPageToken
                    self.currentSearch.page += 1
                    completion(searchRes?.mediaItems ?? [])
                    
                case let .failure(error):
                    GPhotosApi.handle(error: error)
                    completion([])
                }
            }
        }
    }
    
    func reloadSearch(with request: MediaItemsSearch.Request, completion: @escaping (([MediaItem])->())) {
        currentSearch = Search()
        search(with: request, completion: completion)
    }
}

// MARK:- Get
public extension MediaItems {
    
    func get(id: String, completion: @escaping ((MediaItem?)->())) {
        GPhotos.refreshTokenIfNeeded() {
            GPhotosApi.mediaItems.request(.get(id: id)) { (result) in
                switch result {
                case let .success(res):
                    guard let dict = GPhotosApi.handle(response: res) else {
                        completion(nil)
                        return
                    }
                    let item = MediaItem(JSON: dict)
                    completion(item)
                    
                case let .failure(error):
                    GPhotosApi.handle(error: error)
                    completion(nil)
                }
            }
        }
    }
    
}
