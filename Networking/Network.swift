//
//  Network.swift
//
//  Created by sam on 2018/7/4.
//  Copyright © 2018年 Tianqu. All rights reserved.
//
//  Done:
//  Retry, Cache, Timeout, BLL validate, Token, &ReactiveCocoa, Logging
//  Undone:
//  HttpCachePolicy,
import Foundation
import Alamofire

//MARK: Network
open class Network: NSObject {
    
    let session: Session
    public init(session: Session) {
        self.session = session
    }
}
//MARK: Default
extension Network {
    private static let defaultRootQueue = "com.xxx.network.default.rootQueue"
    public static let `default`: Network = Network.init(session: defaultSession)
    private(set) static var defaultSession: Alamofire.Session = {
        let configuration = URLSessionConfiguration.default
        let headers = HTTPHeaders.default
        configuration.headers = headers
        configuration.timeoutIntervalForRequest = 15.0
        configuration.requestCachePolicy = .useProtocolCachePolicy
        let eventMonitors: [EventMonitor]
        #if DEBUG
        eventMonitors = [Network.LoggingMonitor()]
        #else
        eventMonitors = [EventMonitor]()
        #endif
        
        return Alamofire.Session.init(configuration: configuration,
                                      delegate: SessionDelegate(),
                                      rootQueue: DispatchQueue(label: defaultRootQueue),
                                      startRequestsImmediately: true,
                                      interceptor: ConnectionLostRetryPolicy(),
                                      serverTrustManager: nil,
                                      redirectHandler: nil,
                                      cachedResponseHandler: nil,
                                      eventMonitors: eventMonitors)
    }()
}

extension Network {
    public enum HttpMethod {
        case get, post, put, delete, connect, head, options, patch, trace
        var method: Alamofire.HTTPMethod {
            switch self {
            case .get: return .get
            case .post: return .post
            case .put: return .put
            case .delete: return .delete
            case .connect: return .connect
            case .head: return .head
            case .options: return .put
            case .patch: return .patch
            case .trace: return .trace
            }
        }
    }
    
    public typealias DataDecoder = Alamofire.DataDecoder
}

//MARK: Token
extension Network {
    /// cancel request when its deinit called
    open class Token {
        let request: Alamofire.Request
        func invalidate() {
            request.task?.cancel()
        }
        init(_ request: Alamofire.Request) {
            self.request = request
        }
        deinit {
            invalidate()
        }
    }
}

