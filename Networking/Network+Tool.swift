//
//  Network+Tool.swift
//  Demo Feed
//
//  Created by 岑智炜 on 2019/12/9.
//  Copyright © 2019 GuangZhou TianQu WangLuo KeJi. All rights reserved.
//

import Foundation
import Alamofire

struct VoidInput: Encodable { }
typealias KeyValueInput = Dictionary<String, String>
struct VoidOuput: Decodable, EmptyResponse {
    static let value = VoidOuput()
    static func emptyValue() -> VoidOuput {
        return value
    }
}

extension Network {
    static func encodeToString<Params: Encodable>(_ params: Params, with encoder: JSONEncoder) throws -> String? {
        let data = try encoder.encode(params)
        return String(data: data, encoding: .utf8)
    }
}

