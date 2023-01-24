//
//  PlaylistItemsRequest.swift
//  YouTubeApp
//
//  Created by Hisashi Ishihara on 2023/01/20.
//

import Alamofire
import Foundation

// ② PlaylistItems:list で playlistId に含まれている動画の一覧を取得する
struct PlaylistItemsRequest: RequestYouTube {
    
    var path: String { "youtube/v3/playlistItems" }
    
    var parameters: [String: Any]? {
        [
            "key": "AIzaSyDR7-aUFuGUM6tKLYlWrpLKWwgqqa-Z3tA",
            "part": "snippet",
            "playlistId": "\(playlistId)",
            "maxResults": 10,
            "pageToken": "\(pageToken)"
        ]
    }
    
    var playlistId: String
    var pageToken: String
    
    init(playlistId: String?, pageToken: String?) {
        self.playlistId = playlistId ?? ""
        self.pageToken = pageToken ?? ""
    }
}

extension PlaylistItemsRequest {
    
    struct Body: Decodable {
        let kind, etag, nextPageToken: String?
        let pageInfo: PageInfo?
        let items: [Item]?
        
        private enum CodingKeys: CodingKey {
            case kind, etag, nextPageToken, pageInfo, items
        }
        
        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            do { kind = try c.decode(String?.self, forKey: .kind) } catch { kind = nil }
            do { etag = try c.decode(String?.self, forKey: .etag) } catch { etag = nil }
            do { nextPageToken = try c.decode(String?.self, forKey: .nextPageToken) } catch { nextPageToken = nil }
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
            let resourceId: ResourceId?
            
            enum CodingKeys: String, CodingKey {
                case title
                case snippetDescription = "description"
                case publishedAt, thumbnails, localized, country, resourceId
            }
        }
        
        struct ResourceId: Codable {
            let kind, videoId: String
            
            enum CodingKeys: String, CodingKey {
                case kind
                case videoId
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
//{
//  "kind": "youtube#playlistItemListResponse",
//  "etag": "nkAPp3gCO7pLIQ7MzeL73CQ9hsc",
//  "nextPageToken": "EAAaBlBUOkNBVQ",
//  "items": [
//    {
//      "kind": "youtube#playlistItem",
//      "etag": "wwotxRBIh2jQzRdOinH7Tz9XEOw",
//      "id": "VVVPVXU4WWxiYVB6MFcyVHlGVFpIdmpBLnNBakpNUkJiVmVN",
//      "snippet": {
//        "publishedAt": "2023-01-08T10:00:22Z",
//        "channelId": "UCOUu8YlbaPz0W2TyFTZHvjA",
//        "title": "【一人焼肉＆新年会】最高級お肉を食べる＆ダイエットのポイントトーク少々です。",
//        "description": "○2ndチャンネルでの2022年振り返りトーク\nhttps://youtu.be/Y0gdx1Oc2G0\n\n○なかやまきんに君公式ホームページ\nhttp://なかやまきんに君.com\n\n○日本中の体脂肪を燃やす\n『ザ・オンラインフィットネス』公式ホームページ\nhttps://the-online-fitness.net/\n\n○2023年3月1日発売\n『世界で一番楽なゼロパワーダイエット』予約開始です。https://www.amazon.co.jp/dp/4046061014\n\n○きんにく漢字ドリル(小学1年生)が大好評発売中です。\nAmazon\nhttps://amzn.asia/d/3JjVyy2\n楽天ブックス\nhttps://books.rakuten.co.jp/rb/17328915/\n\n○なかやまきんに君プロデュース\n『ザ・プロテイン』のフレッシュいちご味＆プレーンタイプが新登場。\nhttp://theprotein.jp\n\n○LINE公式スタンプ  第二弾\n『 なかやまきんに君　パワー!!スタンプ』 (1セット24種、音声付き)\nhttps://line.me/S/sticker/26259\n\n○LINE公式スタンプ  第一弾\n『 なかやまきんに君　パワー!!スタンプ』 (1セット24種、音声付き)\n\n○オリジナルアパレル『POWER Official Store』\nタンクトップ AIR、BIG Tシャツ AIR、ノースリーブAIRが新発売しております。\nhttps://power29.jp/\n\n○【最強】無添加の超柔らかサラダチキン\n『ザ・パワーチキン』\nhttps://kinnikun-power.com\n\n○ザ・きんにくTV 2nd\nhttps://www.youtube.com/channel/UCnHzm--hwx96P9D3Rnbe3LQ?view_as=subscriber\n\n○Instagram\nhttps://www.instagram.com/nakayama_kinnikun/?hl=ja\n\n○Twitter\nhttps://twitter.com/kinnikun0917\n\n#一人焼肉 #新年会 #忘年会",
//        "thumbnails": {
//          "default": {
//            "url": "https://i.ytimg.com/vi/sAjJMRBbVeM/default.jpg",
//            "width": 120,
//            "height": 90
//          },
//          "medium": {
//            "url": "https://i.ytimg.com/vi/sAjJMRBbVeM/mqdefault.jpg",
//            "width": 320,
//            "height": 180
//          },
//          "high": {
//            "url": "https://i.ytimg.com/vi/sAjJMRBbVeM/hqdefault.jpg",
//            "width": 480,
//            "height": 360
//          },
//          "standard": {
//            "url": "https://i.ytimg.com/vi/sAjJMRBbVeM/sddefault.jpg",
//            "width": 640,
//            "height": 480
//          }
//        },
//        "channelTitle": "ザ・きんにくTV 【The Muscle TV】",
//        "playlistId": "UUOUu8YlbaPz0W2TyFTZHvjA",
//        "position": 0,
//        "resourceId": {
//          "kind": "youtube#video",
//          "videoId": "sAjJMRBbVeM"
//        },
//        "videoOwnerChannelTitle": "ザ・きんにくTV 【The Muscle TV】",
//        "videoOwnerChannelId": "UCOUu8YlbaPz0W2TyFTZHvjA"
//      }
//    },
//    {
//      "kind": "youtube#playlistItem",
//      "etag": "xBAW6YkEJG3xOvddNC8bQNu4Zzw",
//      "id": "VVVPVXU4WWxiYVB6MFcyVHlGVFpIdmpBLlFUZFc4amJFbzB3",
//      "snippet": {
//        "publishedAt": "2023-01-04T12:40:23Z",
//        "channelId": "UCOUu8YlbaPz0W2TyFTZHvjA",
//        "title": "【年末年始】実は紅白歌合戦でやらかしてました＆新年は北海道でマイナス７℃で筋肉ルーレット",
//        "description": "○【公式】NHK紅白歌合戦 天童よしみさんステージ\nhttps://youtu.be/NlCfXyn24fE\n\n○ティモンディチャンネル\nhttps://www.youtube.com/@user-uh4js3wg2d\n\n○なかやまきんに君公式ホームページ\nhttp://なかやまきんに君.com\n\n○日本中の体脂肪を燃やす\n『ザ・オンラインフィットネス』公式ホームページ\nhttps://the-online-fitness.net/\n\n○2023年3月1日発売\n『世界で一番楽なゼロパワーダイエット』予約開始です。https://www.amazon.co.jp/dp/4046061014\n\n○きんにく漢字ドリル(小学1年生)が大好評発売中です。\nAmazon\nhttps://amzn.asia/d/3JjVyy2\n楽天ブックス\nhttps://books.rakuten.co.jp/rb/17328915/\n\n○なかやまきんに君プロデュース\n『ザ・戦 天童よしみさんステージ\nhttps://youtu.be/NlCfXyn24fE\n\n○ティモンディチャンネル\nhttps://www.youtube.com/@user-uh4js3wg2d\n\n○なかやまきんに君公式ホームページ\nhttp://なかやまきんに君.com\n\n○日本中の体脂肪を燃やす\n『ザ・オンラインフィットネス』公式ホームページ\nhttps://the-online-fitness.net/\n\n○2023年3月1日発売\n『世界で一番楽なゼロパワーダイエット』予約開始です。https://www.amazon.co.jp/dp/4046061014\n\n○きんにく漢字ドリル(小学1年生)が大好評発売中です。\nAmazon\nhttps://amzn.asia/d/3JjVyy2\n楽天ブックス\nhttps://books.rakuten.co.jp/rb/17328915/\n\n○なかやまきんに君プロデュース\n『ザ・\343プロテイン』のフレッシュいちご味＆プレーンタイプが新登場。\nhttp://theprotein.jp\n\n○LINE公式スタンプ  第二弾\n『 なかやまきんに君　パワー!!スタンプ』 (1セット24種、音声付き)\nhttps://line.me/S/sticker/26259\n\n○LINE公式スタンプ  第一弾\n『 なかやまきんに君　パワー!!スタンプ』 (1セット24種、音声付き)\n\n○オリジナルアパレル『POWER Official Store』\nタンクトップ AIR、BIG Tシャツ AIR戦 天童よしみさんステージ\nhttps://youtu.be/NlCfXyn24fE\n\n○ティモンディチャンネル\nhttps://www.youtube.com/@user-uh4js3wg2d\n\n○なかやまきんに君公式ホームページ\nhttp://なかやまきんに君.com\n\n○日本中の体脂肪を燃やす\n『ザ・オンラインフィットネス』公式ホームページ\nhttps://the-online-fitness.net/\n\n○2023年3月1日発売\n『世界で一番楽なゼロパワーダイエット』予約開始です。https://www.amazon.co.jp/dp/4046061014\n\n○きんにく漢字ドリル(小学1年生)が大好評発売中です。\nAmazon\nhttps://amzn.asia/d/3JjVyy2\n楽天ブックス\nhttps://books.rakuten.co.jp/rb/17328915/\n\n○なかやまきんに君プロデュース\n『ザ・\343プロテイン』のフレッシュいちご味＆プレーンタイプが新登場。\nhttp://theprotein.jp\n\n○LINE公式スタンプ  第二弾\n『 なかやまきんに君　パワー!!スタンプ』 (1セット24種、音声付き)\nhttps://line.me/S/sticker/26259\n\n○LINE公式スタンプ  第一弾\n『 なかやまきんに君　パワー!!スタンプ』 (1セット24種、音声付き)\n\n○オリジナルアパレル『POWER Official Store』\nタンクトップ AIR、BIG Tシャツ AIR\343\200、ノースリーブAIRが新発売しております。\nhttps://power29.jp/\n\n○【最強】無添加の超柔らかサラダチキン\n『ザ・パワーチキン』\nhttps://kinnikun-power.com\n\n○ザ・きんにくTV 2nd\nhttps://www.youtube.com/channel/UCnHzm--hwx96P9D3Rnbe3LQ?view_as=subscriber\n\n○Instagram\nhttps://www.instagram.com/nakayama_kinnikun/?hl=ja\n\n○Twitter\nhttps://twitter.com/kinnikun0917\n\n#紅白歌合戦 #天童よしみ #ティモンディ高岸",
//        "thumbnails": {
//          "default": {
//            "url": "https://i.ytimg.com/vi/QTdW8jbEo0w/default.jpg",
//            "width": 120,
//            "height": 90
//          },
//          "medium": {
//            "url": "https://i.ytimg.com/vi/QTdW8jbEo0w/mqdefault.jpg",
//            "width": 320,
//            "height": 180
//          },
//          "high": {
//            "url": "https://i.ytimg.com/vi/QTdW8jbEo0w/hqdefault.jpg",
//            "width": 480,
//            "height": 360
//          },
//          "standard": {
//            "url": "https://i.ytimg.com/vi/QTdW8jbEo0w/sddefault.jpg",
//            "width": 640,
//            "height": 480
//          }
//        },
//        "channelTitle": "ザ・きんにくTV 【The Muscle TV】",
//        "playlistId": "UUOUu8YlbaPz0W2TyFTZHvjA",
//        "position": 1,
//        "resourceId": {
//          "kind": "youtube#video",
//          "videoId": "QTdW8jbEo0w"
//        },
//        "videoOwnerChannelTitle": "ザ・きんにくTV 【The Muscle TV】",
//        "videoOwnerChannelId": "UCOUu8YlbaPz0W2TyFTZHvjA"
//      }
//    },
//    {
//      "kind": "youtube#playlistItem",
//      "etag": "_TTk1P7eHHc8aDK4neCyRZYCnWQ",
//      "id": "VVVPVXU4WWxiYVB6MFcyVHlGVFpIdmpBLkgwbHJzTjFweHdZ",
//      "snippet": {
//        "publishedAt": "2023-01-03T10:00:10Z",
//        "channelId": "UCOUu8YlbaPz0W2TyFTZHvjA",
//        "title": "【初対決・後編】きんに君vsケインコスギ！！芸能人スポーツマンNo.1はどっちだ。実況は古舘伊知郎さんです。",
//        "description": "○ケインコスギYouTubeチャンネルでのコラボ\nスペシャルゲストと一緒にトレーニング&トークをする\n第1回ゲスト『なかやまきんに君』\nhttps://youtu.be/1TiUrCJ4Ak4\n\n○古舘伊知郎チャンネルでのコラボ\n【正月SPコラボ】今年はこれで変われる！きんに君からの金言。\nすぐに実践出来る噛む事と飲む時の心がけ\nhttps://youtu.be/vwH-Va5_vFY\n\n○日本中の体脂肪を燃やす\n『ザ・オンラインフィットネス』公式ホームページ\nhttps://the-online-fitness.net/\n\n○2023年3月1日発売\n『世界で一番楽なゼロパワーダイエット』予約開始です。https://www.amazon.co.jp/dp/4046061014\n\n○なかやまきんに君公式ホームページ\nhttp://なかやまきんに君.com\n\n○きんにく漢字ドリル(小学1年生)が大好評発売中です。\nAmazon\nhttps://amzn.asia/d/3JjVyy2\n楽天ブックス\nhttps://books.rakuten.co.jp/rb/17328915/\n\n○なかやまきんに君プロデュース\n『ザ・プロテイン』のフレッシュいちご味＆プレーンタイプが新登場。\nhttp://theprotein.jp\n\n○LINE公式スタンプ  第二弾\n『 なかやまきんに君　パワー!!スタンプ』 (1セット24種、音声付き)\nhttps://line.me/S/sticker/26259\n\n○LINE公式スタンプ  第一弾\n『 なかやまきんに君　パワー!!スタンプ』 (1セット24種、音声付き)\n\n○オリジナルアパレル『POWER Official Store』\nタンクトップ AIR、BIG Tシャツ AIR、ノースリーブAIRが新発売しております。\nhttps://power29.jp/\n\n○【最強】無添加の超柔らかサラダチキン\n『ザ・パワーチキン』\nhttps://kinnikun-power.com\n\n○ザ・きんにくTV 2nd\nhttps://www.youtube.com/channel/UCnHzm--hwx96P9D3Rnbe3LQ?view_as=subscriber\n\n○Instagram\nhttps://www.instagram.com/nakayama_kinnikun/?hl=ja\n\n○Twitter\nhttps://twitter.com/kinnikun0917\n\n#ケインコスギ #筋肉番付 #対決",
//
//        "thumbnails": {
//          "default": {
//            "url": "https://i.ytimg.com/vi/H0lrsN1pxwY/default.jpg",
//            "width": 120,
//            "height": 90
//          },
//          "medium": {
//            "url": "https://i.ytimg.com/vi/H0lrsN1pxwY/mqdefault.jpg",
//            "width": 320,
//            "height": 180
//          },
//          "high": {
//            "url": "https://i.ytimg.com/vi/H0lrsN1pxwY/hqdefault.jpg",
//            "width": 480,
//            "height": 360
//          },
//          "standard": {
//            "url": "https://i.ytimg.com/vi/H0lrsN1pxwY/sddefault.jpg",
//            "width": 640,
//            "height": 480
//          }
//        },
//        "channelTitle": "ザ・きんにくTV 【The Muscle TV】",
//        "playlistId": "UUOUu8YlbaPz0W2TyFTZHvjA",
//        "position": 2,
//        "resourceId": {
//          "kind": "youtube#video",
//          "videoId": "H0lrsN1pxwY"
//        },
//        "videoOwnerChannelTitle": "ザ・きんにくTV 【The Muscle TV】",
//        "videoOwnerChannelId": "UCOUu8YlbaPz0W2TyFTZHvjA"
//      }
//    },
//    {
//      "kind": "youtube#playlistItem",
//      "etag": "TWUbN27rxKQsTJ7TT8RMU-_rBAI",
//      "id": "VVVPVXU4WWxiYVB6MFcyVHlGVFpIdmpBLjBza3FMSlNXenhJ",
//      "snippet": {
//        "publishedAt": "2023-01-02T10:00:00Z",
//        "channelId": "UCOUu8YlbaPz0W2TyFTZHvjA",
//        "title": "【新春SP】ついに初対決!!芸能人スポーツマンNo.1決定戦が復活。実況は古舘伊知郎さんで、きんに君vsケイン５番勝負。 〜前編〜",
//        "description": "○ケインコスギYouTubeチャンネル\nスペシャルゲストと一緒にトレーニング&トークをする\n第1回ゲスト『なかやまきんに君』\nhttps://youtu.be/1TiUrCJ4Ak4\n\n○古舘伊知郎チャンネルでのコラボ\n【正月SPコラボ】今年はこれで変われる！きんに君からの金言。\nすぐに実践出来る噛む事と飲む時の心がけ\nhttps://youtu.be/vwH-Va5_vFY\n\n撮影協力・ゴールドジム東陽町スーパーセンター\nhttps://www.goldsgym.jp/shop/71221\n\n○日本中の体脂肪を燃やす\n『ザ・オンラインフィットネス』公式ホームページ\nhttps://the-online-fitness.net/\n\n○2023年3月1日発売\n『世界で一番楽なゼロパワーダイエット』予約開始です。https://www.amazon.co.jp/dp/4046061014\n\n○なかやまきんに君公式ホームページ\nhttp://なかやまきんに君.com\n\n○きんにく漢字ドリル(小学1年生)が大好評発売中です。\nAmazon\nhttps://amzn.asia/d/3JjVyy2\n楽天ブックス\nhttps://books.rakuten.co.jp/rb/17328915/\n\n○なかやまきんに君プロデュース\n『ザ・プロテイン』のフレッシュいちご味＆プレーンタイプが新登場。\nhttp://theprotein.jp\n\n○LINE公式スタンプ  第二弾\n『 なかやまきんに君　パワー!!スタンプ』 (1セット24種、音声付き)\nhttps://line.me/S/sticker/26259\n\n○LINE公式スタンプ  第一弾\n『 なかやまきんに君　パワー!!スタンプ』 (1セット24種、音声付き)\n\n○オリジナルアパレル『POWER Official Store』\nタンクトップ AIR、BIG Tシャツ AIR、ノースリーブAIRが新発売しております。\nhttps://power29.jp/\n\n○【最強】無添加の超柔らかサラダチキン\n『ザ・パワーチキン』\nhttps://kinnikun-power.com\n\n○ザ・きんにくTV 2nd\nhttps://www.youtube.com/channel/UCnHzm--hwx96P9D3Rnbe3LQ?view_as=subscriber\n\n○Instagram\nhttps://www.instagram.com/nakayama_kinnikun/?hl=ja\n\n○Twitter\nhttps://twitter.com/kinnikun0917\n\n#ケインコスギ #筋肉番付 #対決",
//        "thumbnails": {
//          "default": {
//            "url": "https://i.ytimg.com/vi/0skqLJSWzxI/default.jpg",
//            "width": 120,
//            "height": 90
//          },
//          "medium": {
//            "url": "https://i.ytimg.com/vi/0skqLJSWzxI/mqdefault.jpg",
//            "width": 320,
//            "height": 180
//          },
//          "high": {
//            "url": "https://i.ytimg.com/vi/0skqLJSWzxI/hqdefault.jpg",
//            "width": 480,
//            "height": 360
//          },
//          "standard": {
//            "url": "https://i.ytimg.com/vi/0skqLJSWzxI/sddefault.jpg",
//            "width": 640,
//            "height": 480
//          }
//        },
//        "channelTitle": "ザ・きんにくTV 【The Muscle TV】",
//        "playlistId": "UUOUu8YlbaPz0W2TyFTZHvjA",
//        "position": 3,
//        "resourceId": {
//          "kind": "youtube#video",
//          "videoId": "0skqLJSWzxI"
//        },
//        "videoOwnerChannelTitle": "ザ・きんにくTV 【The Muscle TV】",
//        "videoOwnerChannelId": "UCOUu8YlbaPz0W2TyFTZHvjA"
//      }
//    },
//    {
//      "kind": "youtube#playlistItem",
//      "etag": "SvrN6Sl2qNvLSDZUaMCwzYn2wsA",
//      "id": "VVVPVXU4WWxiYVB6MFcyVHlGVFpIdmpBLnROdjdqR3FhbVVN",
//      "snippet": {
//        "publishedAt": "2022-12-31T23:00:34Z",
//        "channelId": "UCOUu8YlbaPz0W2TyFTZHvjA",
//        "title": "【2023年】なぜ続かない？筋トレ＆ダイエット始める前にまず知るべき事３選+αです。",
//        "description": "○日本中の体脂肪を燃やす\n『ザ・オンラインフィットネス』公式ホームページ\nhttps://the-online-fitness.net/\n\n○2023年3月1日発売\n『世界で一番楽なゼロパワーダイエット』予約開始です。https://www.amazon.co.jp/dp/4046061014\n\n○なかやまきんに君公式ホームページ\nhttp://なかやまきんに君.com\n\n○きんにく漢字ドリル(小学1年生)が大好評発売中です。\nAmazon\nhttps://amzn.asia/d/3JjVyy2\n楽天ブックス\nhttps://books.rakuten.co.jp/rb/17328915/\n\n○なかやまきんに君プロデュース\n『ザ・プロテイン』のフレッシュいちご味＆プレーンタイプが新登場。\nhttp://theprotein.jp\n\n○LINE公式スタンプ  第二弾\n『 なかやまきんに君　パワー!!スタンプ』 (1セット24種、音声付き)\nhttps://line.me/S/sticker/26259\n\n○LINE公式スタンプ  第一弾\n『 なかやまきんに君　パワー!!スタンプ』 (1セット24種、音声付き)\n\n○オリジナルアパレル『POWER Official Store』\nタンクトップ AIR、BIG Tシャツ AIR、ノースリーブAIRが新発売しております。\nhttps://power29.jp/\n\n○【最強】無添加の超柔らかサラダチキン\n『ザ・パワーチキン』\nhttps://kinnikun-power.com\n\n○ザ・きんにくTV 2nd\nhttps://www.youtube.com/channel/UCnHzm--hwx96P9D3Rnbe3LQ?view_as=subscriber\n\n○Instagram\nhttps://www.instagram.com/nakayama_kinnikun/?hl=ja\n\n○Twitter\nhttps://twitter.com/kinnikun0917\n\n#継続 #ダイエット #コツ",
//        "thumbnails": {
//          "default": {
//            "url": "https://i.ytimg.com/vi/tNv7jGqamUM/default.jpg",
//            "width": 120,
//            "height": 90
//          },
//          "medium": {
//            "url": "https://i.ytimg.com/vi/tNv7jGqamUM/mqdefault.jpg",
//            "width": 320,
//            "height": 180
//          },
//          "high": {
//            "url": "https://i.ytimg.com/vi/tNv7jGqamUM/hqdefault.jpg",
//            "width": 480,
//            "height": 360
//          },
//          "standard": {
//            "url": "https://i.ytimg.com/vi/tNv7jGqamUM/sddefault.jpg",
//            "width": 640,
//            "height": 480
//          }
//        },
//        "channelTitle": "ザ・きんにくTV 【The Muscle TV】",
//        "playlistId": "UUOUu8YlbaPz0W2TyFTZHvjA",
//        "position": 4,
//        "resourceId": {
//          "kind": "youtube#video",
//          "videoId": "tNv7jGqamUM"
//        },
//        "videoOwnerChannelTitle": "ザ・きんにくTV 【The Muscle TV】",
//        "videoOwnerChannelId": "UCOUu8YlbaPz0W2TyFTZHvjA"
//      }
//    }
//  ],
//  "pageInfo": {
//    "totalResults": 381,
//    "resultsPerPage": 5
//  }
//}
