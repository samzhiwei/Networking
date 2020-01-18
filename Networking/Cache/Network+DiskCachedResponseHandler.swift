//
//  Network+DiskCachedResponseHandler.swift
//  Demo Feed
//
//  Created by 岑智炜 on 2019/12/9.
//  Copyright © 2019 GuangZhou TianQu WangLuo KeJi. All rights reserved.
//

import Foundation
import Alamofire
import Cache
extension Network {
    struct DiskCachedResponseHandler: CachedResponseHandler {
        let cacheKey: String
        let storage: Cache.DiskStorage<Data>
        let expiry: Expiry?
        func dataTask(_ task: URLSessionDataTask, willCacheResponse response: CachedURLResponse, completion: @escaping (CachedURLResponse?) -> Void) {
            do {
                try storage.setObject(response.data, forKey: cacheKey, expiry: expiry)
            } catch {
                assert(false, error.localizedDescription)
            }
            completion(nil)
        }
    }
}
