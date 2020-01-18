//
//  Network+CachableAPI.swift
//  Demo Feed
//
//  Created by 岑智炜 on 2019/12/9.
//  Copyright © 2019 GuangZhou TianQu WangLuo KeJi. All rights reserved.
//

import Foundation
import Alamofire
import Cache

protocol CachableAPIConvertible: APIConvertible {
    func cacheKey<Params: Encodable>(params: Params?) throws -> String
    var cacheKeyEncoder: JSONEncoder { get }
    var cacheExpiry: Expiry? { get }
    var diskStorage: DiskStorage<Data> { get }
}

extension CachableAPIConvertible {
    /// Default "URL_METHOD_KEYVALUE" encryption by md5
    func cacheKey<Params: Encodable>(params: Params?) throws -> String {
        var element = [url, method.method.rawValue]
        if let _params = params,
            let sParams = try Network.encodeToString(_params, with: cacheKeyEncoder) {
            element.append(sParams)
        }
        let id = element.joined(separator: "_")
        return MD5(id)
    }

    /// Default is 30 days, if nil, cache will save as DiskStorage.DiskConfig.expiry
    var cacheExpiry: Expiry? {
        return .seconds(60*60*24*30)
    }
    /// Default is JSONEncoder,
    var cacheKeyEncoder: JSONEncoder { JSONEncoder() }
}
