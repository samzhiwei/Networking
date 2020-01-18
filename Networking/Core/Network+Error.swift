//
//  Network+Error.swift
//  Demo Feed
//
//  Created by 岑智炜 on 2019/12/10.
//  Copyright © 2019 GuangZhou TianQu WangLuo KeJi. All rights reserved.
//

import Foundation

extension Network {
    public enum ValidationError: Error, LocalizedError {
        case emptyData
        case decode(Error)
        case service(Int, String)
        
        public var errorDescription: String? {
            switch self {
            case .emptyData: return "数据有误，请联系客服"
            case .decode(let error): return error.localizedDescription
            case .service(_, let msg): return msg
            }
        }
    }
}
