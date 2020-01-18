//
//  Network+DownloadTask.swift
//  Networking
//
//  Created by 岑智炜 on 2019/12/11.
//  Copyright © 2019 GuangZhou TianQu WangLuo KeJi. All rights reserved.
//

import Foundation
import Alamofire

extension Network {
    ///  For a continuous download file task，deinit after initialized DownloadRequest
    open class DownloadTask<API: APIConvertible>: Task<API> {
        var request: Alamofire.DownloadRequest? {
            if _request == nil {
                return nil
            } else {
                return _request
            }
        }
        fileprivate var _request: Alamofire.DownloadRequest!
        deinit {
            print("DownloadTask deinit")
        }
    }
}

extension Network.DownloadTask: URLRequestConvertible where API.Params: Encodable, API: ParameterEncodable {
    
    public func asURLRequest() throws -> URLRequest {
        let request = try URLRequest(url: api.url, method: api.method.method, headers: api.headers)
        do {
            return try api.parameterEncoder.encode(params, into: request)
        } catch {
            return request
        }
    }
}

//MARK: DownloadDestinationConvertible
public protocol DownloadDestinationConvertible {
    var downloadOption: DownloadRequest.Options { get }
    func downloadDestinationURL(_ temporaryURL: URL) -> URL
}

extension DownloadDestinationConvertible {
    var downloadOption: DownloadRequest.Options { [.createIntermediateDirectories, .removePreviousFile] }
}

//MARK: API
extension Network {
    public func download<API>(_ api: API,
                      params: API.Params? = nil,
                      destination: DownloadRequest.Destination?) -> DownloadTask<API> where API.Params: Encodable, API: ParameterEncodable {
        let task = DownloadTask(api: api, params: params)
        let request = session.download(task.api.url,
                                       method: task.api.method.method,
                                       parameters: task.params,
                                       encoder: task.api.parameterEncoder,
                                       headers: task.api.headers,
                                       interceptor: task.requestInterceptor,
                                       to: destination)
        task._request = request
        return task
    }
    
    public func download<API>(_ api: API,
                              params: API.Params? = nil) -> DownloadTask<API>
        where API.Params: Encodable, API: ParameterEncodable, API: DownloadDestinationConvertible {
            return download(api, params: params) { (url, _) -> (destinationURL: URL, options: DownloadRequest.Options) in
                return (  api.downloadDestinationURL(url), api.downloadOption )
            }
    }
}

extension Network.DownloadTask {
    @discardableResult
    func downloadProgress(closure: @escaping (Progress) -> Void) -> Self {
        _request.downloadProgress(closure: closure)
        return self
    }
    
    @discardableResult
    public func responseData(completionHandler: @escaping ((AFDownloadResponse<Data>) -> Void)) -> Self {
        #warning ("todo: Localization AFError")
        _request.responseData(completionHandler: completionHandler)
        return self
    }
}

//MARK: Token
extension Network.DownloadTask {
    public func token() -> Network.Token? {
        guard let cRequest = request else { return nil }
        return Network.Token(cRequest)
    }
}
