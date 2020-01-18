//
//  Network+ReactiveCocoa.swift
//  Demo Feed
//
//  Created by 岑智炜 on 2019/12/4.
//  Copyright © 2019 GuangZhou TianQu WangLuo KeJi. All rights reserved.
//

import Foundation
import Alamofire
import ReactiveSwift

extension Network.DataTask where API: ResponseDecodable {
    @discardableResult
    public func responseDecodableSignalProducer() -> SignalProducer<API.ResponseDecodableType, Error> {
        /// 必须强持有self
        return .init { (observer, lifetime) in
            let token = self.responseDecodable { (result) in
                switch result {
                case .success(let data): /// 一次性获取数据后完成
                    observer.send(value: data)
                    observer.sendCompleted()
                case .failure(let error): /// 错误
                    observer.send(error: error)
                }
            }
            .token()
            ///跟随signal 取消请求
            lifetime.observeEnded{ token?.invalidate() }
        }
    }
}

extension Reactive where Base == Network {
    
    func request<API>(_ api: API,
                      params: API.Params? = nil) -> Network.DataTask<API>
        where API: APIConvertible, API.Params: Encodable, API: ParameterEncodable, API: ResponseDecodable {
            return base.request(api, params: params)
    }
}
