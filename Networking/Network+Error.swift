//
//  Network+Error.swift
//  Demo Feed
//
//  Created by 岑智炜 on 2019/12/10.
//  Copyright © 2019 GuangZhou TianQu WangLuo KeJi. All rights reserved.
//

import Foundation
import Alamofire


public protocol BLLErrorConveritble: Swift.Error {
    var bllErrorCode: Int { get }
    var bllErrorMsg: String { get }
}

extension Network {
    public enum NEError: Swift.Error, LocalizedError {
        public enum SerializationReason {
            case emptyData
            case error(Error)
        }
        /// 数据解析时的错
        case serialization(SerializationReason)
        /// 业务Error
        case bll(BLLErrorConveritble)
        /// AF所有的错误
        case network(AFError)
        
        public var errorDescription: String? {
            switch self {
            case .serialization(let error):
                #if NETWORK_DEBUG
                Log(error)
                #else
                #endif
                return "数据有误，请稍后再试"
            case .bll(let bll):
                #if NETWORK_DEBUG
                Log(bll)
                #else
                #endif
                return bll.bllErrorMsg
            case .network(let error):
                switch error {
                case .explicitlyCancelled:
                    return "Request explicitly cancelled."
                case .invalidURL(_):
                    return "参数错误, 请联系客服\nErrorCode = -8000"
                case .parameterEncodingFailed(_):
                    return "参数错误, 请联系客服\nErrorCode = -8001"
                case .parameterEncoderFailed(_):
                    return "参数错误, 请联系客服\nErrorCode = -8002"
                case .multipartEncodingFailed(_):
                    return "参数错误, 请联系客服\nErrorCode = -8003"
                case .requestAdaptationFailed(_):
                    return "参数错误, 请联系客服\nErrorCode = -8004"
                case .responseValidationFailed(_):
                    return "数据错误, 请联系客服\nErrorCode = -8005"
                case .responseSerializationFailed(_):
                    return "数据错误, 请联系客服\nErrorCode = -8006"
                case .requestRetryFailed(_, _):
                    return "重试失败, 请联系客服\nErrorCode = -8007"
                case .sessionDeinitialized:
                    return """
                    Session was invalidated without error, so it was likely deinitialized unexpectedly. \
                    Be sure to retain a reference to your Session for the duration of your requests.
                    """
                case let .sessionInvalidated(error):
                    return error?.localizedDescription ?? "No description"
//                    return "Session was invalidated with error: \(error?.localizedDescription ?? "No description.")"
                case .serverTrustEvaluationFailed(_):
                    return "请求错误, 请联系客服\nErrorCode = -8008"
//                    return "Server trust evaluation failed due to reason: \(reason.localizedDescription)"
                case .urlRequestValidationFailed(_):
//                    return "URLRequest validation failed due to reason: \(reason.localizedDescription)"
                    return "请求错误, 请联系客服\nErrorCode = -8009"
                case let .createUploadableFailed(error):
//                    return "Uploadable creation failed with error: \(error.localizedDescription)"
                    return "\(error.localizedDescription)"
                case let .createURLRequestFailed(error):
//                    return "URLRequest creation failed with error: \(error.localizedDescription)"
                    return "\(error.localizedDescription)"
                case let .downloadedFileMoveFailed(error, _, _):
                    return "\(error.localizedDescription)"
//                    return "Moving downloaded file from: \(source) to: \(destination) failed with error: \(error.localizedDescription)"
                case let .sessionTaskFailed(error):
                    return "\(error.localizedDescription)"
//                    return "URLSessionTask failed with error: \(error.localizedDescription)"
                }
            }
        }
    }
}

extension Network {
    /// 本地化error
    
    
}
