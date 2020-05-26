//
//  Network+Task.swift
//  Networking
//
//  Created by 岑智炜 on 2019/12/11.
//  Copyright © 2019 GuangZhou TianQu WangLuo KeJi. All rights reserved.
//

import Foundation
import Alamofire

//MARK: RequestInterceptor
protocol RequestInterceptorConveritble {
    var requestInterceptor: RequestInterceptor? { get }
}

extension Network {
    open class Task<API: APIConvertible> {
        let api: API
        let params: API.Params?
        
        init(api: API, params: API.Params? = nil) {
            self.api = api
            self.params = params
        }
    }
}

//MARK: RequestInterceptor
extension Network.Task: RequestInterceptorConveritble {
    var requestInterceptor: RequestInterceptor? {
        return Network.TaskRequestInterceptor(timeout: api.timeout,
                                              httpHeadersFollowSession: api.httpHeadersFollowSession,
                                              enforceHttpsRequest: api.enforceHttpsRequest)
    }
}

//MARK: DataTaskRequestInterceptor
extension Network {
    class TaskRequestInterceptor: RequestInterceptor {
        let timeout: TimeoutStrategy
        let httpHeadersFollowSession: Bool
        /// if yes, url will change to https when it is http.
        let enforceHttpsRequest: Bool
        init(timeout: TimeoutStrategy = .followSession,
             httpHeadersFollowSession: Bool = false,
             enforceHttpsRequest: Bool = false) {
            self.timeout = timeout
            self.httpHeadersFollowSession = httpHeadersFollowSession
            self.enforceHttpsRequest = enforceHttpsRequest
        }
        
        func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
            var request = urlRequest
            /// 修改timeout
            switch timeout {
            case .interval(let interval):
                request.timeoutInterval = interval
            case .followSession:
                request.timeoutInterval = session.sessionConfiguration.timeoutIntervalForRequest
            }
            /// 强制https请求
            if enforceHttpsRequest,
                let url = request.url,
                url.absoluteString.hasPrefix("http://") {
                let newUrl = url.absoluteString.replacingOccurrences(of: "http://", with: "https://")
                request.url = URL.init(string: newUrl)
            }
            /// 跟随session预设headers
            if httpHeadersFollowSession {
                session.sessionConfiguration.httpAdditionalHeaders?.compactMap({ (arg0) -> (String, String)? in
                    let (key, value) = arg0
                    if let key = key as? String, let value = value as? String {
                        return (key, value)
                    } else {
                        return nil
                    }
                }).forEach{ request.addValue($0.1, forHTTPHeaderField: $0.0) }
            }
            
            completion(.success(request))
        }
    }
}

//MARK: APIConvertible
public protocol APIConvertible {
    associatedtype Params
    var url: String { get }
    var method: Network.HttpMethod { get }
    var headers: HTTPHeaders { get }
    var timeout: Network.TimeoutStrategy { get }
    var httpHeadersFollowSession: Bool { get }
    var enforceHttpsRequest: Bool { get }
}

extension APIConvertible {
    var headers: HTTPHeaders { HTTPHeaders() }
    var timeout: Network.TimeoutStrategy { .followSession }
    var httpHeadersFollowSession: Bool { false }
    var enforceHttpsRequest: Bool { false }
}

//MARK: ParameterEncodableAPI
protocol ParameterEncodableAPI: APIConvertible, ParameterEncodable {
    
}

//MARK: ParameterEncodable
public protocol ParameterEncodable {
    var parameterEncoder: ParameterEncoder { get }
}

//MARK: ResponseDecodable
public protocol ResponseDecodable {
    associatedtype ResponseDecodableType: Decodable
    var responseDecodableTypeDecoder: DataDecoder { get }
}

//MARK: Validatable
public protocol ResponseValidatable {
    associatedtype ResponseValidationType: BLLErrorConveritble&Decodable
    var responseValidationTypeDecoder: DataDecoder { get }
}

public protocol ResponseFailure {
    associatedtype ResponseFailureType: AFErrorConveritble
}

//MARK: AFErrorConveritble
public protocol AFErrorConveritble: Swift.Error {
    init(af: AFError)
}

extension Network {
    public enum TimeoutStrategy {
        case interval(TimeInterval)
        case followSession
    }
}

//MARK: RequestTimeoutConveritble
protocol RequestTimeoutConveritble {
    var timeout: Network.TimeoutStrategy { get }
}
