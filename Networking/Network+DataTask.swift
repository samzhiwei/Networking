//
//  Network+DataTask.swift
//  Networking
//
//  Created by 岑智炜 on 2019/12/11.
//  Copyright © 2019 GuangZhou TianQu WangLuo KeJi. All rights reserved.
//

import Foundation
import Alamofire

extension Network {
    ///  For one time fetch data task，deinit after initialized DataRequest
    open class DataTask<API: APIConvertible>: Task<API> {
        var request: Alamofire.DataRequest? {
            if _request == nil {
                return nil
            } else {
                return _request
            }
        }
        fileprivate var _request: Alamofire.DataRequest!
        
        override init(api: API, params: API.Params? = nil) {
            super.init(api: api, params: params)
        }
    }
}



//MARK: URLRequestConvertible
extension Network.DataTask: URLRequestConvertible where API.Params: Encodable, API: ParameterEncodable {
    
    public func asURLRequest() throws -> URLRequest {
        let request = try URLRequest(url: api.url, method: api.method.method, headers: api.headers)
        do {
            return try api.parameterEncoder.encode(params, into: request)
        } catch {
            return request
        }
    }
}

//MARK: API
extension Network {
    @discardableResult
    public func request<API>(_ api: API,
                             params: API.Params? = nil) -> DataTask<API> where API.Params: Encodable, API: ParameterEncodable {
        let task = DataTask(api: api, params: params)
        let request = session.request(task.api.url,
                                      method: task.api.method.method,
                                      parameters: task.params,
                                      encoder: task.api.parameterEncoder,
                                      headers: task.api.headers,
            interceptor: task.requestInterceptor)
        task._request = request
        return task
    }
}

//MARK: Validation
extension Network.DataTask {
    /// 状态码验证
    @discardableResult
    public func validate<S: Sequence>(statusCode acceptableStatusCodes: S) -> Self where S.Iterator.Element == Int {
        _request.validate(statusCode: acceptableStatusCodes)
        return self
    }
    /// 数据验证
    @discardableResult
    public func validate(_ validate: @escaping DataRequest.Validation) -> Self {
        _request.validate(validate)
        return self
    }
}

extension Network.DataTask {
    /// 状态码验证
    @discardableResult
    public func validateStatusCodes() -> Self {
        _request.validate(statusCode: 200..<399)
        return self
    }
}

extension Network.DataTask where API: ResponseValidatable {
    
    @discardableResult
    public func validateAPI(_ condition: @escaping ((API.ResponseValidationType) -> Bool)) -> Self {
        let _api = self.api
        return validate { (_, _, data) -> DataRequest.ValidationResult in
            guard let _data = data, !_data.isEmpty else {
                return .failure(Network.NEError.validate(.emptyData))
            }
            do {
                let bll = try _api.responseValidationTypeDecoder.decode(API.ResponseValidationType.self, from: _data)
                if condition(bll) {
                    return .success(())
                } else {
                    return .failure(Network.NEError.validate(.condition(bll)))
                }
            } catch {
                return .failure(Network.NEError.validate(.decode(error)))
            }
        }
    }
}

//MARK: CallBack

extension Network.DataTask {
    
    @discardableResult
    public func response(completionHandler: @escaping (Result<Data?, Error>) -> Void) -> Self {
        _request.response { (response) in
            completionHandler(response.mapError{ $0 }.result)
        }
        return self
    }
    
    @discardableResult
    public func responseData(completionHandler: @escaping (Result<Data, Error>) -> Void) -> Self {
        _request.responseData { (response) in
            completionHandler(response.mapError{ $0 }.result)
        }
        return self
    }
}

extension Network.DataTask where API: ResponseDecodable {
    @discardableResult
    public func responseDecodable(completionHandler: @escaping (Result<API.ResponseDecodableType, Error>) -> Void) -> Self {
        _request.responseDecodable(decoder: api.responseDecodableTypeDecoder) { response in
            completionHandler(response.mapError{ $0 }.result)
        }
        return self
    }
}

//MARK: Token
extension Network.DataTask {
    public func token() -> Network.Token? {
        guard let cRequest = request else { return nil }
        return Network.Token(cRequest)
    }
}

