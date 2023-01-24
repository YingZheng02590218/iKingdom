//
//  ChannelsRequest.swift
//  YouTubeApp
//
//  Created by Hisashi Ishihara on 2023/01/19.
//

import Alamofire
import Foundation

// ① Channels:list でチャンネルの情報を取得する
struct ChannelsRequest: RequestYouTube {
    
    var path: String { "youtube/v3/channels" }
    
    var parameters: [String: Any]? {
        [
            "key": "AIzaSyDR7-aUFuGUM6tKLYlWrpLKWwgqqa-Z3tA",
            "part": "contentDetails",
            "id": "\(channelId)"
        ]
    }
    
    var channelId: String
    
    init(channelId: String) {
        self.channelId = channelId
    }
}

extension ChannelsRequest {
    
    struct Body: Decodable {
        let kind, etag: String?
        let pageInfo: PageInfo?
        let items: [Item]?
        
        private enum CodingKeys: CodingKey {
            case kind, etag, pageInfo, items
        }
        
        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            do { kind = try c.decode(String?.self, forKey: .kind) } catch { kind = nil }
            do { etag = try c.decode(String?.self, forKey: .etag) } catch { etag = nil }
            do { pageInfo = try c.decode(PageInfo?.self, forKey: .pageInfo) } catch { pageInfo = nil }
            do { items = try c.decode([Item]?.self, forKey: .items) } catch { items = nil }
        }
        
        struct Item: Codable {
            let kind, etag, id: String?
            let snippet: Snippet?
            let contentDetails: ContentDetails?
        }
        
        struct ContentDetails: Codable {
            let relatedPlaylists: RelatedPlaylists?
        }
        
        struct RelatedPlaylists: Codable {
            let likes, favorites, uploads, watchHistory: String?
            let watchLater: String?
        }
        
        struct Snippet: Codable {
            let title, snippetDescription: String?
            let publishedAt: String?
            let thumbnails: Thumbnails?
            let localized: Localized?
            let country: String?
            
            enum CodingKeys: String, CodingKey {
                case title
                case snippetDescription = "description"
                case publishedAt, thumbnails, localized, country
            }
        }
        
        struct Localized: Codable {
            let title, localizedDescription: String
            
            enum CodingKeys: String, CodingKey {
                case title
                case localizedDescription = "description"
            }
        }
        
        struct Thumbnails: Codable {
            let thumbnailsDefault, medium, high: Default
            
            enum CodingKeys: String, CodingKey {
                case thumbnailsDefault = "default"
                case medium, high
            }
        }
        
        struct Default: Codable {
            let url: String
            let width, height: Int
        }
        
        struct PageInfo: Codable {
            let totalResults, resultsPerPage: Int?
        }
        
    }
    
}
// ザ・きんにくTV 【The Muscle TV】
//            {
//              "kind": "youtube#channelListResponse",
//              "etag": "-x1wG_92R26cYeMw_Lp5uJHyfi8",
//              "pageInfo": {
//                "totalResults": 1,
//                "resultsPerPage": 5
//              },
//              "items": [
//                {
//                  "kind": "youtube#channel",
//                  "etag": "6dXLQ4etqpB3IWO4QFuEeJ-s5ac",
//                  "id": "UCOUu8YlbaPz0W2TyFTZHvjA"
//                }
//              ]
//            }

// パラメータ"part": "contentDetails",の場合
//            {
//              "kind": "youtube#channelListResponse",
//              "etag": "PCOHogizTub1se-YQh9vsGUgYQw",
//              "pageInfo": {
//                "totalResults": 1,
//                "resultsPerPage": 5
//              },
//              "items": [
//                {
//                  "kind": "youtube#channel",
//                  "etag": "uSbxOtnygSO-GMznPiFQAaVtDvc",
//                  "id": "UCOUu8YlbaPz0W2TyFTZHvjA",
//                  "contentDetails": {
//                    "relatedPlaylists": {
//                      "likes": "",
//                      "uploads": "UUOUu8YlbaPz0W2TyFTZHvjA" これがアップロード済み動画のplaylistId
//                    }
//                  }
//                }
//              ]
//            }
