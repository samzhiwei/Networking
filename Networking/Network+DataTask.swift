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
    open func validate(_ validate: @escaping DataRequest.Validation) -> Self {
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
/*
extension Network.DataTask where API: ResponseValidatable {
    
    /// API 业务逻辑验证
    @discardableResult
    public func validateAPIBLL(condition: @escaping ((API.ResponseValidationType) -> Bool)) -> Self {
        return validateAPIBLL { (responseValidation) -> Error? in
            return condition(responseValidation) ? nil : responseValidation.error()
        }
    }
    
    public func validateAPIBLL(_ condition: @escaping ((API.ResponseValidationType) -> Error?)) -> Self {
        let _api = self.api
        return validate { (_, _, data) -> DataRequest.ValidationResult in
            guard let _data = data, !_data.isEmpty else {
                return .failure(Network.ValidationError.emptyData)
            }
            do {
                let bll = try _api.responseValidationTypeDecoder.decode(API.ResponseValidationType.self, from: _data)
                if let error = condition(bll) {
                    return .failure(error)
                } else {
                    return .success(())
                }
            } catch {
                return .failure(Network.ValidationError.decode(error))
            }
        }
    }
}

extension Network.DataTask where API: ResponseValidatable {
    /// API 业务逻辑验证
    @discardableResult
    public func validateAPIBLL(condition: @escaping ((API.ResponseValidationType) -> Bool)) -> Self {
        return validateAPIBLL { (responseValidation) -> Error? in
            return condition(responseValidation) ? nil : responseValidation.error()
        }
    }
}
*/
//MARK: CallBack

extension Network.DataTask {
    @discardableResult
    public func responseData(completionHandler: @escaping (DataResponse<Data, Network.NEError>) -> Void) -> Self {
        _request.responseData { completionHandler($0.mapError{ Network.NEError.network($0) } ) }
        return self
    }
}

extension Network.DataTask where API: ResponseDecodable {
    @discardableResult
    public func responseDecodable(completionHandler: @escaping (Result<API.ResponseDecodableType, Network.NEError>) -> Void) -> Self {
        _request.responseDecodable(decoder: api.responseDecodableTypeDecoder) { response in
            completionHandler(response.mapError{ Network.NEError.network($0) }.result)
        }
        return self
    }
}

public typealias NEResponseHandler<Model: Decodable> = Result<Model, Network.NEError>

extension Network.DataTask where API: ResponseDecodable&ResponseValidatable {
    @discardableResult
    public func responseDecodableAndValidatable(condition: @escaping ( (API.ResponseValidationType) -> Bool ),
                                                completionHandler: @escaping (NEResponseHandler<API.ResponseDecodableType>) -> Void) -> Self {
        let decodableTypeDecoder = self.api.responseDecodableTypeDecoder
        let validationTypeDecoder = self.api.responseValidationTypeDecoder
        _request.responseData { (response) in
            switch response.result {
            case .success(let data):
                /// 1 验证
                guard !data.isEmpty else { /// 空数据
                    let error = Network.NEError.serialization(.emptyData)
                    let result = NEResponseHandler<API.ResponseDecodableType>.failure(error)
                    completionHandler(result)
                    return
                }
                do {
                    let bll = try validationTypeDecoder.decode(API.ResponseValidationType.self, from: data)
                    if condition(bll) {
                        do {
                            let decodable = try decodableTypeDecoder.decode(API.ResponseDecodableType.self, from: data)
                            let result = NEResponseHandler<API.ResponseDecodableType>.success(decodable)
                            completionHandler(result)
                        } catch {
                            let error = Network.NEError.serialization(.emptyData)
                            let result = NEResponseHandler<API.ResponseDecodableType>.failure(error)
                            completionHandler(result)
                        }
                    } else {
                        let error = Network.NEError.bll(bll)
                        let result = NEResponseHandler<API.ResponseDecodableType>.failure(error)
                        completionHandler(result)
                    }
                } catch {
                    let errorDataString = String.init(data: data, encoding: .utf8)
                    print(errorDataString)
                    let _error = Network.NEError.serialization(.error(error))
                    let result = NEResponseHandler<API.ResponseDecodableType>.failure(_error)
                    completionHandler(result)
                }
            case .failure(let afError):
                let error = Network.NEError.network(afError)
                let result = NEResponseHandler<API.ResponseDecodableType>.failure(error)
                completionHandler(result)
            }
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

