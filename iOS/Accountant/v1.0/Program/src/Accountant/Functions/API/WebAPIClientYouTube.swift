//
//  WebAPIClientYouTube.swift
//  APIClientApp
//
//  Created by Hisashi Ishihara on 2023/01/19.
//

import Alamofire
import Foundation

struct EmptyBody: Decodable {}

protocol RequestYouTube {
    associatedtype Body
    
    var method: HTTPMethod { get }
    var baseURL: String { get }
    var path: String { get }
    
    var headers: HTTPHeaders? { get }
    var parameters: [String: Any]? { get }
    
    func request<T: RequestYouTube>(_ req: T, completion: ((ResponseYouTube<T.Body>) -> Void)?)
    func decode(from data: Data) throws -> ResponseYouTube<Body>
}

struct ResponseYouTube<Body> {
    public let body: Body
}

extension RequestYouTube {
    var method: HTTPMethod { .get }
    var baseURL: String { "https://www.googleapis.com/" }
    var path: String { "" }
    
    var headers: HTTPHeaders? { nil }
    var parameters: [String: Any]? { nil }
}

struct DecodableResponseYouTube<Body: Decodable>: Decodable {
    let body: Body
    
    private enum CodingKeys: CodingKey {
        case body
    }
    
    init(from decoder: Decoder) throws {
        // キーがない階層の対応
        body = try decoder.singleValueContainer().decode(Body.self)
    }
}

extension RequestYouTube where Body: Decodable {
    
    func request<T: RequestYouTube>(_ req: T, completion: ((ResponseYouTube<T.Body>) -> Void)?) {
        let req = AF.request(
            req.baseURL + req.path,
            method: req.method,
            parameters: req.parameters,
            encoding: URLEncoding.default,
            // encoding: URLEncoding.queryString,
            // encoding: JSONEncoding.default,
            headers: req.headers
        )
            .response { response in
                guard let data = response.data else { return }
                
                do {
                    print(String(data: data, encoding: .utf8) ?? "変換できず")
                    //                    {
                    //                      "kind": "youtube#channelListResponse",
                    //                      "etag": "RuuXzTIr0OoDqI4S0RU6n4FqKEM",
                    //                      "pageInfo": {
                    //                        "totalResults": 0,
                    //                        "resultsPerPage": 5
                    //                      }
                    //                    }
                    let model = try req.decode(from: data)
                    completion?(model)
                } catch let error {
                    print("error decode json \(error)")
                }
            }
        
        debugPrint(req)
    }
    func decode(from data: Data) throws -> ResponseYouTube<Body> {
        let response = try JSONDecoder().decode(DecodableResponseYouTube<Body>.self, from: data)
        return ResponseYouTube<Body>(body: response.body)
    }
}

// Use this for params
extension Dictionary where Key == String, Value == Any? {
    var cleaned: [Key: Any] { clean(self) }
}

func clean<Key, Value>(_ dict: [Key: Value?]) -> [Key: Value] {
    var result: [Key: Value] = [:]
    for (key, value) in dict {
        if let value = value {
            result[key] = value
        }
    }
    return result
}

func sendApi<Req: RequestYouTube>(_ req: Req, completion: @escaping (ResponseYouTube<Req.Body>) -> Void) {
    req.request(req) { response in
        completion(response)
    }
}
