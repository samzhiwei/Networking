//
//  ViewController.swift
//  Example
//
//  Created by 岑智炜 on 2020/5/26.
//  Copyright © 2020 czw. All rights reserved.
//

import UIKit
import CZWNetworking
import ReactiveSwift

extension Network {
    static var main: Network { return .default }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Network.default.request(FetchRouteCategory(), params: .init())
            .validateAPI(condition: { $0.bllErrorCode == 0 })
            .responseDecodable { (result) in
                switch result {
                case .success(let data):
                    break
                case .failure(let error):
                    break
                }
        }

            /*
            .responseData { (response) in
                switch response.result {
                case .success(let data):
                    print("成功\(data.count)")
                case .failure(let error):
                    print("error: \(error)")
                }
        }.responseDecodableAndValidatable(condition: { $0.bllErrorCode == 0 }) { (result) in
            switch result {
            case .success(let data):
                print(data)
            case .failure(let error):
                print("失败: \(error)")
            }
        }*/
    }
}

struct FetchRouteCategory: ParameterEncodableAPI {
    let url = "https://api.8684.cn/bus_api_v1.php"
    let method: Network.HttpMethod = .post
    struct Params: Encodable {
        let k = "all_lines"
        let appkey = "Yv9cL8wTwZgr"
        let ecity = "guangzhou"
    }
}

struct NestedHelper<Model: Decodable>: Decodable {
    let error_message: String
    let data: Model
}

struct RouteCategory: Decodable {
    let type: String
    let lines: [Route]
}

struct Route: Decodable {
    let busw: String
    let code: String
}

extension FetchRouteCategory: ResponseDecodable {
    typealias ResponseDecodableType = NestedHelper<[RouteCategory]>
}

struct BusCN: BLLErrorConveritble, Decodable {
    var bllErrorCode: Int {
        return Int(errorMsg) ?? -9999
    }
    
    var bllErrorMsg: String { errorMsg }
    
    /// Acceptable Type: String, Int
    let errorMsg: String
    
    enum CodingKeys: String, CodingKey {
        case errorMsg = "error_message"
    }
}

extension FetchRouteCategory: ResponseValidatable {
    typealias ResponseValidationType = BusCN

}

