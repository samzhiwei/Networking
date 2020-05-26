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
    init(session: Session) {
        self.session = session
    }
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

