//
//  Network+Error.swift
//  Demo Feed
//
//  Created by 岑智炜 on 2019/12/10.
//  Copyright © 2019 GuangZhou TianQu WangLuo KeJi. All rights reserved.
//

import Foundation
import Alamofire

public protocol ValidatedErrorConveritble: Swift.Error {
    var validatedErrorCode: Int { get }
    var validatedErrorMsg: String { get }
}

extension Network {
    public enum NEError: Swift.Error, LocalizedError {
        public enum ValidationError {
            case emptyData
            case decode(Error)
            case condition(ValidatedErrorConveritble)
        }
        
        public enum SerializationError {
            case emptyData
            case decode(Error)
        }
        /// 业务验证时的错
        case validate(ValidationError)
        
        /// 数据解析时的错
        case serialization(SerializationError)
        
        public var errorDescription: String? {
            switch self {
            case .validate(let reason):
                switch reason {
                case .condition(let error):
                    return error.validatedErrorMsg
                default:
                    return "数据有误，请稍后再试"
                }
            case .serialization(let error):
                return "数据有误，请稍后再试"
            }
        }
    }
}

extension Network {
    /// 本地化error
    
    
}
