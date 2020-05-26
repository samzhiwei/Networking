//
//  Network+EventMonitor.swift
//  iOSZhuTui
//
//  Created by 岑智炜 on 2019/7/16.
//  Copyright © 2019 GuangZhou TianQu WangLuo KeJi. All rights reserved.
//  PS. 'NETWORK_DEBUG' tag can get more debug info

import Foundation
import Alamofire

//MARK: LoggingMonitor
#if DEBUG
extension Network {
    final class LoggingMonitor: EventMonitor {
        //MARK: Did Resume
        func requestDidResume(_ request: Request) {
            if let _request = request.request {
                let sRequest = checkRequestType(request)
                let start = "======= Network Did Resume \(sRequest) ======="
                let id = "[UUID]: \(request.id)"
                let url = "[URL]: \(_request.url?.absoluteString ?? "null")"
                let method = "[Method]: \(_request.method?.rawValue ?? "null")"
                let header = "[Header]: \(_request.headers)"
                let params = "[Parameters]: \(_request.httpBody.map { String(decoding: $0, as: UTF8.self) } ?? "null")"
                print("", start, id, url, method, header, params, separator: "\n")
            }
        }
        
        #if NETWORK_DEBUG
        //MARK: Did Validate
        func request(_ request: DataRequest, didValidateRequest urlRequest: URLRequest?, response: HTTPURLResponse, data: Data?, withResult result: Request.ValidationResult) {
            let sRequest = checkRequestType(request)
            let start = "======= Network Did Validate \(sRequest) ======="
            let id = "[UUID]: \(request.id)"
            let result = "[Result]: \(result)"
            print("", start, id, result, separator: "\n")
        }
        #else
        #endif
        
        //MARK: Did Finish
        func requestDidFinish(_ request: Request) {
            let sRequest = checkRequestType(request)
            let start = "======= Network Did Finish \(sRequest) ======="
            let id = "[UUID]: \(request.id)"
            #if NETWORK_DEBUG
            let data = "[Data]: \((request as? DataRequest)?.data.map { String(decoding: $0, as: UTF8.self) } ?? "null")"
            print("", start, id, data, separator: "\n")
            #else
            print("", start, id, separator: "\n")
            #endif
        }
        //MARK: Did Fail Task
        func request(_ request: Request, didFailTask task: URLSessionTask, earlyWithError error: AFError) {
            let sRequest = checkRequestType(request)
            let start = "======= Network Did Finish \(sRequest) ======="
            let id = "[UUID]: \(request.id)"
            let error = "[Error]: \(error)"
            print("", start, id, error, separator: "\n")
        }
        
        //MARK: Did Suspend
        func requestDidSuspend(_ request: Request) {
            let sRequest = checkRequestType(request)
            let start = "======= Network Did Suspend \(sRequest) ======="
            let id = "[UUID]: \(request.id)"
            print("", start, id, separator: "\n")
        }
        
        //MARK: Did Cancel
        func request(_ request: Request, didCancelTask task: URLSessionTask) {
            let sRequest = checkRequestType(request)
            let start = "======= Network Did Cancel \(sRequest) ======="
            let id = "[UUID]: \(request.id)"
            print("", start, id, separator: "\n")
        }
    }
}

extension Network.LoggingMonitor {
    fileprivate func checkRequestType(_ request: Request) -> String {
        if request is UploadRequest {
            return "UploadRequest"
        } else if request is DataRequest {
            return "DataRequest"
        } else if request is DownloadRequest {
            return "DownloadRequest"
        } else {
            return "Request"
        }
    }
}
#else
#endif
