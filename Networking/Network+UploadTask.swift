//
//  Network+UploadTask.swift
//  Networking
//
//  Created by 岑智炜 on 2019/12/11.
//  Copyright © 2019 GuangZhou TianQu WangLuo KeJi. All rights reserved.
//

import Foundation
import Alamofire

extension Network {
    ///  For a continuous upload file task，deinit after initialized UploadRequest
    open class UploadTask<API: APIConvertible>: Task<API> {
        var request: Alamofire.UploadRequest? {
            if _request == nil {
                return nil
            } else {
                return _request
            }
        }
        fileprivate var _request: Alamofire.UploadRequest!
    }
}

public protocol MultipartFormDataConvertible {
    func baleMultipartFormData(_ multipartFormData: MultipartFormData)
}

extension Network {
    public func upload<API>(_ api: API,
                            params: API.Params? = nil,
                            multipartFormData: @escaping (MultipartFormData) -> Void) -> UploadTask<API>
        where API.Params: Encodable, API: ParameterEncodable {
            let task = UploadTask(api: api, params: params)
            let request = session.upload(multipartFormData: multipartFormData,
                                         to: task.api.url,
                                         method: task.api.method.method,
                                         headers: task.api.headers,
                                         interceptor: task.requestInterceptor)
            task._request = request
            return task
    }
    
    public func upload<API>(_ api: API,
                            params: API.Params? = nil) -> UploadTask<API>
        where API.Params: Encodable, API: ParameterEncodable, API: MultipartFormDataConvertible {
            return upload(api, params: params) { api.baleMultipartFormData($0) }
    }
}

//MARK: UploadProgress
extension Network.UploadTask {
    @discardableResult
    public func uploadProgress(closure: @escaping (Progress) -> Void) -> Self {
        _request.uploadProgress(closure: closure)
        return self
    }
}

//MARK: Validation
extension Network.UploadTask {
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

extension Network.UploadTask {
    /// 状态码验证
    @discardableResult
    public func validateStatusCodes() -> Self {
        _request.validate(statusCode: 200..<399)
        return self
    }
}

extension Network.UploadTask where API: ResponseValidatable {
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
extension Network.UploadTask {
        
    @discardableResult
    public func responseData(completionHandler: @escaping (Result<Data, Error>) -> Void) -> Self {
        _request.responseData { (response) in
            completionHandler(response.mapError{ $0 }.result)
        }
        return self
    }
 
}

extension Network.UploadTask where API: ResponseDecodable {
     
    @discardableResult
    public func responseDecodable(completionHandler: @escaping (Result<API.ResponseDecodableType, Error>) -> Void) -> Self {
        _request.responseDecodable(decoder: api.responseDecodableTypeDecoder) { (response) in
            completionHandler(response.mapError{ $0 }.result)
        }
        return self
    }
 
}

//MARK: Token
extension Network.UploadTask {
    public func token() -> Network.Token? {
        guard let cRequest = request else { return nil }
        return Network.Token(cRequest)
    }
}


