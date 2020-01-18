//
//  Network+Cache.swift
//  Demo Feed
//
//  Created by 岑智炜 on 2019/12/4.
//  Copyright © 2019 GuangZhou TianQu WangLuo KeJi. All rights reserved.
//  PS. 主动控制的缓存策略 todo: 适配https的缓存策略

import Foundation
import Alamofire
import Cache

extension DiskStorage {
    func checkCache<API>(for api: API, param: API.Params) -> T?
        where API: CachableAPIConvertible,
        API: ResponseDecodable,
        API.Params: Encodable,
        API.ResponseDecodableType == T {
            do {
                let key = try api.cacheKey(params: param)
                return try object(forKey: key)
            } catch {
                print(error)
                return nil
            }
    }
}

extension Network.DataTask where API: ResponseDecodable {
    func cacheIfSuccess(key: String, in diskStorage: DiskStorage<Data>, expiry: Expiry?) -> Self {
        self.request?.responseData(completionHandler: { (response) in
            switch response.result {
            case .success(let data):
                do {
                    try diskStorage.setObject(data, forKey: key, expiry: expiry)
                } catch {
                    print(error)
                }
            case .failure(_): break
            }
        })
        return self
    }
}

extension Network.DataTask where API.Params: Encodable, API: ResponseDecodable, API: CachableAPIConvertible {
    /// 从responseData回调判断是否缓存，不能阻断请求
    func cache() -> Self {
        var key: String? = nil
        
        do {
            key = try api.cacheKey(params: self.params)
        } catch {
            print(error)
        }
        guard let cacheKey = key else { return self }
        return cacheIfSuccess(key: cacheKey, in: api.diskStorage, expiry: api.cacheExpiry)
    }
}



