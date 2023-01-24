//
//  YouTubeViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/01/24.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import Alamofire
import UIKit
import WebKit

class YouTubeViewController: UIViewController {

    // TODO: 特定のチャンネルにアップロードされている動画の一覧を取得して各動画の詳細（タイトル、説明、再生数など）を取得する

    // Google Cloud Console へのアクセス、API キーのリクエスト、アプリケーションの登録

    // OAuth 2.0 Client IDs
    // 144008316435-0e6d59bpgvdglcnvdaei3tveo6hu1vur.apps.googleusercontent.com

    // API キー:
    // AIzaSyDR7-aUFuGUM6tKLYlWrpLKWwgqqa-Z3tA

    // アプリケーションが使用するサービスの 1 つとして YouTube Data API をステータスを ON にします。

    // チャンネルID
    // ザ・きんにくTV 【The Muscle TV】
    // @themuscletv29
    // UCOUu8YlbaPz0W2TyFTZHvjA

    // TODO: 【Swift】YouTube風の動画ミニビューの実装方法
    // https://hiromiick.com/swift-youtube-like-mini-player-view/#YouTube

    //    @IBOutlet weak var webView: WKWebView!
        @IBOutlet var webViewBase: UIView!

    lazy var webView = WKWebView()

        @IBOutlet var tableView: UITableView!

    var canRotateInt = 1 // 1は回転不可、−１は回転可能

    override func viewDidLoad() {
        super.viewDidLoad()

        // largeTitle表示
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.prefersLargeTitles = false

        // FIXME: 全画面の時のみ、横画面にすることを許可する
        // https://teratail.com/questions/9741?sort=1
        // 全画面表示になったことを検知
        // wideViewメソッドはあとで書きます
        NotificationCenter.default.addObserver(self, selector: #selector(self.wideView), name: UIWindow.didBecomeKeyNotification, object: nil)
        // 全画面表示になったことを検知
        // wideViewメソッドはあとで書きます
        NotificationCenter.default.addObserver(self, selector: #selector(self.wideView), name: UIWindow.didBecomeKeyNotification, object: nil)

        rotateSet(rotateInt: 1)

        // https://web-y.dev/2020/10/24/ios-wkwebview-play-youtube-inline/
        print(view.frame.width)
        view.backgroundColor = .systemPink
        //        WKWebView を用意
        //        まずWKWebView を準備します。
        //        storyboard や xib ではなく、直接コードにより作っていきます。
        //        コードの方が色々小回りが効くので、今回はこちらの方が良い気がします。
        let config = WKWebViewConfiguration()
        //        ここでポイントなのが、config.allowsInlineMediaPlayback = true の箇所。
        //        これを指定しないと、YouTube動画がインライン再生されず、
        //        再生ボタンをタップした瞬間に全画面再生になってしまいます。
        config.allowsInlineMediaPlayback = true

        // 自動再生させる
        config.mediaTypesRequiringUserActionForPlayback = []

        print(view.frame.width)
        webView = WKWebView(
            frame: webViewBase.frame,
            configuration: config
        )
        webView.contentMode = UIView.ContentMode.scaleAspectFit // 効いてる？
        webView.backgroundColor = .green
        webViewBase.addSubview(webView)
        // https://qiita.com/aryzae/items/9b3d6f77cb5082665220
        // webViewの制約設定時、AutoresizingMaskによって自動生成される制約と競合するため、自動生成をやめる
        webView.translatesAutoresizingMaskIntoConstraints = false
        // webViewの制約
        NSLayoutConstraint.activate(
            [
                webView.leadingAnchor.constraint(equalTo: webViewBase.leadingAnchor),
                webView.trailingAnchor.constraint(equalTo: webViewBase.trailingAnchor),
                webView.topAnchor.constraint(equalTo: webViewBase.topAnchor),
                webView.bottomAnchor.constraint(equalTo: webViewBase.bottomAnchor),
                webView.widthAnchor.constraint(equalTo: webViewBase.widthAnchor),
                webView.heightAnchor.constraint(equalTo: webViewBase.heightAnchor)
            ]
        )
        // https://qiita.com/dddisk/items/8001598ea7951bcdcc30
        // redViewの横方向の中心は、親ビューの横方向の中心と同じ
        webView.centerXAnchor.constraint(equalTo: webViewBase.centerXAnchor).isActive = true
        // redViewの縦方向の中心は、親ビューの縦方向の中心と同じ
        webView.centerYAnchor.constraint(equalTo: webViewBase.centerYAnchor).isActive = true
        // redViewの幅は、親ビューの幅
        webView.widthAnchor.constraint(equalTo: webViewBase.widthAnchor, multiplier: 1).isActive = true
        webView.heightAnchor.constraint(equalTo: webViewBase.heightAnchor, multiplier: 1).isActive = true

        guard let path: String = Bundle.main.path(forResource: "html", ofType: "html") else {
            return
        }

        let localHTMLUrl = URL(fileURLWithPath: path, isDirectory: false)
        webView.loadFileURL(localHTMLUrl, allowingReadAccessTo: localHTMLUrl)

        // TableView
        setupTableView()

        // 動画を取得する
        callApiYouTube()
    }
    // TableView
    func setupTableView() {

        // Register the table view cell class and its reuse id.
        tableView.register(UINib(nibName: String(describing: VideoTableViewCell.self), bundle: nil), forCellReuseIdentifier: "VideoTableViewCell")
        // 2. 可変にしたいとき
        tableView.estimatedRowHeight = 40
        tableView.rowHeight = UITableView.automaticDimension

        // This view controller provides delegate methods and row data for the table view.
        tableView.delegate = self
        tableView.dataSource = self
    }

    var items: [PlaylistItemsRequest.Body.Item] = [] {
        didSet {
            //            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.tableView.reloadData()
            // Toast.show("検索結果 \(self.placeList.count)件", self.view)
            //            }
        }
    }
    var item: PlaylistItemsRequest.Body.Item? {
        didSet {
            DispatchQueue.main.async {
                if let videoId = self.item?.snippet?.resourceId?.videoId {
                    // 動画を再生する
                    self.evaluateJavaScript(videoId: videoId)
                }
            }
        }
    }
    // JavaScriptの処理の呼出
    // Swift からJavaScriptをコールする
    func evaluateJavaScript(videoId: String) {
        // evaluateJavaScriptを使用してJavascript側で拡張したwindowオブジェクトを呼び出します。
        // callFromNative()という処理を呼び出す。
        let executeScript: String = "callFromNative(\"\(videoId)\");"

        webView.evaluateJavaScript(executeScript, completionHandler: { (object, error) -> Void in
            if let object = object {
                print(object)
            }
            if let error = error {
                print(error)
            }
        })
    }
    // 動画を取得
    func callApiYouTube() {
        // 動画の情報を取得する流れ
        // API の利用の流れは以下の通り。

        // ① Channels:list でチャンネルの情報を取得する
        //   アップロード済み動画 のリストが含まれているプレイリストの ID（playlistId）が取得できる
        callApiChannels(channelId: "UCOUu8YlbaPz0W2TyFTZHvjA") // FIXME: ザ・きんにくTV 【The Muscle TV】

        //        callApiChannels(channelId: "UCFAwrtqSFrAxIjeIXkjmEAg") // @paciolist   UCFAwrtqSFrAxIjeIXkjmEAg
        // ② PlaylistItems:list で playlistId に含まれている動画の一覧を取得する
        //   各動画の概要と videoId が取得できる

        // ③ Videos:list でビデオの詳細を取得する
        //   再生数やいいねなどが取得できる
    }
    // ① Channels:list でチャンネルの情報を取得する
    func callApiChannels(channelId: String) {
        let request = ChannelsRequest(channelId: channelId)
        sendApi(request, completion: { response in
            // ② PlaylistItems:list で playlistId に含まれている動画の一覧を取得する
            self.callApiPlaylistItems(playlistId: response.body.items?.first?.contentDetails?.relatedPlaylists?.uploads, pageToken: nil)
        })
    }
    // TODO: Swift　TableViewで無限スクロール(ページネート)を実装する方法
    // https://qiita.com/sasaki_shunsuke/items/88c568230641cc973a9d
    // 【swift入門】TableViewで無限スクロールを実装しよう
    // https://fukatsu.tech/infinite-scroll
    //    最初は今まで通り20記事取得
    //    70〜80%ぐらいスクロールしたところで次の20記事を取得して表示
    //    一番下にたどり着く頃には次の記事が既に表示されている
    //    2〜3の繰り返し

    var playlistId: String?
    var pageToken: String?
    private var page: Int = 1
    private var loadStatus: LoadStatus = .initial

    // ② PlaylistItems:list で playlistId に含まれている動画の一覧を取得する
    func callApiPlaylistItems(playlistId: String?, pageToken: String?) {
        self.playlistId = playlistId
        self.pageToken = pageToken

        guard loadStatus != .fetching && loadStatus != .full else {
            // 読み込み中またはもう次に記事がない場合にはapiを叩かないようんいする
            return
        }
        loadStatus = .fetching // loadStatusを読み込み中に変更

        let request = PlaylistItemsRequest(playlistId: playlistId, pageToken: pageToken)
        sendApi(request, completion: { response in
            if let nextPageToken = response.body.nextPageToken {
                self.pageToken = nextPageToken
            }
            // itemsの配列に動画のリストが含まれている
            // タイトル・概要・サムネイルの URL・videoId などが取得できる
            if let items = response.body.items {
                if items.isEmpty {
                    self.loadStatus = .full // もう続きの記事がないときにはloadStatusをfullにする
                    return
                }
                DispatchQueue.main.async() { () -> Void in
                    self.items += items
                    self.loadStatus = .loadMore // 記事取得が終わった段階でloadStatusをloadmoreにする
                    if self.page == 2 {
                        self.loadStatus = .full // 10動画 * 2ページ まで来たらloadStatusをfullにする
                        return
                    }
                    if items.count < 10 {
                        self.loadStatus = .full // もう続きの記事がないときにはloadStatusをfullにする
                        return
                    }
                    self.page += 1
                }
            }
        })
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffsetY = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.height
        let distanceToBottom = maximumOffset - currentOffsetY
        //        print("currentOffsetY: \(currentOffsetY)")
        //        print("maximumOffset: \(maximumOffset)")
        //        print("distanceToBottom: \(distanceToBottom)")
        // 下にスクロールするにつれてdistanceToBottomが小さくなっていくので
        // distanceToBottomが500を下回ったときにAPIを呼ぶようにします。
        if distanceToBottom < 500 {

            callApiPlaylistItems(playlistId: playlistId, pageToken: pageToken)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 回転禁止
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        appdelegate.shouldSupportAllOrientation = false
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    // 画面の回転可能性の設定
    func rotateSet(rotateInt: Int) {
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        if rotateInt == 1 {
            // 強制的に縦表示に戻す
            appdelegate.shouldSupportAllOrientation = false
            let value = UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        } else {
            // 回転を許可する
            appdelegate.shouldSupportAllOrientation = true
        }
    }

    // 全画面表示になった時に呼び出される処理
    @objc func wideView() {
        // 回転可能と不能を切りかえる 全画面になる時と閉じる時の両方呼ばれるからこうしなきゃいけない
        canRotateInt *= (-1)
        rotateSet(rotateInt: canRotateInt)
    }
}

//extension UIImage {
//
//    public convenience init(url: String) {
//        let url = URL(string: url)
//        do {
//            let data = try Data(contentsOf: url!)
//            self.init(data: data)!
//            return
//        } catch let err {
//            print("Error : \(err.localizedDescription)")
//        }
//        self.init()
//    }
//}
// Respond when a user selects a place.
extension YouTubeViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        item = items[indexPath.row]
        // TODO: 詳細画面表示
        // performSegue(withIdentifier: "unwindToMain", sender: self)
    }

    // Adjust cell height to only show the first five items in the table
    // (scrolling is disabled in IB).
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100 //self.tableView.frame.size.height

    }

    // Make table rows display at proper height if there are less than 5 items.
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == tableView.numberOfSections - 1 {
            return 1
        }
        return 0
    }
}

// Populate the table with the list of most likely places.
extension YouTubeViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: VideoTableViewCell.self), for: indexPath ) as? VideoTableViewCell else { return UITableViewCell() }
        let collectionItem = items[indexPath.row]

        if let thumbnails = collectionItem.snippet?.thumbnails {
            cell.iconImageView.image = UIImage(url: thumbnails.thumbnailsDefault.url)
        }

        cell.nameLabel.text = collectionItem.snippet?.title

        if let description = collectionItem.snippet?.snippetDescription {
            cell.openingHoursLabel.text = "(\(description))"
        } else {
            cell.openingHoursLabel.text = "(-)"
        }
        //        if let openingHours = collectionItem.openingHours {
        //            cell.openingHoursLabel.text = openingHours.openNow ? "Open" : "Close"
        //            cell.openingHoursLabel.textColor = openingHours.openNow ? UIColor.green : UIColor.red
        //        }
        //        else {
        //            cell.openingHoursLabel.text = "-"
        //            cell.openingHoursLabel.textColor = UIColor.gray
        //        }
        if let publishedAt = collectionItem.snippet?.publishedAt {
            cell.publishedAtLabel.text = publishedAt
        }

        return cell
    }
}
//// 無限スクロール(ページネート)現在の状況を管理
//enum LoadStatus {
//    // loadStatusを導入して現在の状況を管理できるようにしました。
//    // 初期状態
//    case initial
//    // apiを叩いて結果が返ってきて表示されるまでの状態
//    case fetching
//    // 次のページがまだある状態
//    case loadMore
//    // 次のページにはもう記事がない状態
//    case full
//    // エラー
//    case error
//    // これでfetching,fullの状態ではController側からAPIが呼ばれたとしてもapiを叩かないようにしています。
//}
