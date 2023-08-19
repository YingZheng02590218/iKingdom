//
//  BackupViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/01/26.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import EMTNeumorphicView
import UIKit
import WebKit

class BackupViewController: UIViewController {
    
    @IBOutlet var baseView: UIView!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet var button: EMTNeumorphicButton!
    @IBOutlet var label: UILabel!
    
    var webView: WKWebView?

    // フィードバック
    private let feedbackGeneratorHeavy: Any? = {
        if #available(iOS 10.0, *) {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.prepare()
            return generator
        } else {
            return nil
        }
    }()
    // コンテナ　ファイル
    //    private let containerManager = ContainerManager()
    var backupFiles: [(String, NSNumber?, Bool)] = []
    
    // iCloudが有効かどうかの判定
    private var isiCloudEnabled: Bool {
        (FileManager.default.ubiquityIdentityToken != nil)
    }
    // ディレクトリ監視
    var isPresenting = false
    // ディレクトリ監視
    var presentedItemURL: URL? {
        FileManager.default.url(forUbiquityContainerIdentifier: nil)?
            .appendingPathComponent("Documents", isDirectory: true)
    }
    // ディレクトリ監視
    let presentedItemOperationQueue = OperationQueue()
    
    deinit {
        // ディレクトリ監視
        removeFilePresenterIfNeeded()
    }
    // インジゲーター
    var activityIndicatorView = UIActivityIndicatorView()
    let backView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // ディレクトリ監視
        addFilePresenterIfNeeded()
        
        // 削除機能 setEditingメソッドを使用するため、Storyboard上の編集ボタンを上書きしてボタンを生成する
        editButtonItem.tintColor = .accentColor
        navigationItem.rightBarButtonItem = editButtonItem
        
        // title設定
        navigationItem.title = "バックアップ・復元"
        // largeTitle表示
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .accentColor
        
        // UI
        setTableView()
    }
    
    override func loadView() {
        super.loadView() // 重要
        
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        guard let webView = webView else {
            return
        }
        webView.translatesAutoresizingMaskIntoConstraints = false
        // 背景色が白くなるので透明にする
        webView.isOpaque = false
        webView.backgroundColor = .cellBackground
        webView.scrollView.backgroundColor = .clear
        // バウンスを禁止する
        webView.scrollView.bounces = false
        webView.navigationDelegate = self

        baseView.addSubview(webView)
        baseView.bringSubviewToFront(webView)

        // 親Viewを覆うように制約をつける
        webView.leadingAnchor.constraint(equalTo: baseView.leadingAnchor, constant: 0).isActive = true
        webView.topAnchor.constraint(equalTo: baseView.topAnchor, constant: 0).isActive = true
        webView.trailingAnchor.constraint(equalTo: baseView.trailingAnchor, constant: 0).isActive = true
        webView.bottomAnchor.constraint(equalTo: baseView.bottomAnchor, constant: 0).isActive = true
        webView.layoutIfNeeded()
        
        // HTML を読み込む
        if let url = Bundle.main.url(forResource: "explain_backup", withExtension: "html") {
            let urlRequest = URLRequest(url: url)
            webView.load(urlRequest)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // ニューモフィズム　ボタンとビューのデザインを指定する
        createEMTNeumorphicView()
        // tableViewをリロード
        reload()
        // ダークモード対応 HTML上の文字色を変更する
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.webView?.evaluateJavaScript(
                "changeFontColor('\(UITraitCollection.isDarkMode ? "#F2F2F2" : "#0C0C0C")')",
                completionHandler: { _, _ in
                    print("Completed Javascript evaluation.")
                }
            )
        }
    }
    
    // MARK: - Setting
    
    private func setTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        // XIBを登録　xibカスタムセル設定によりsegueが無効になっているためsegueを発生させる
        tableView.register(UINib(nibName: "WithIconTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.separatorColor = .accentColor
    }
    
    // MARK: EMTNeumorphicView
    // ニューモフィズム　ボタンとビューのデザインを指定する
    private func createEMTNeumorphicView() {
        //        inputButton.setTitle("入力", for: .normal)
        button.neumorphicLayer?.cornerRadius = 15
        button.setTitleColor(.accentColor, for: .selected)
        button.neumorphicLayer?.lightShadowOpacity = Constant.LIGHTSHADOWOPACITY
        button.neumorphicLayer?.darkShadowOpacity = Constant.DARKSHADOWOPACITY
        button.neumorphicLayer?.edged = Constant.edged
        button.neumorphicLayer?.elementDepth = Constant.ELEMENTDEPTH
        button.neumorphicLayer?.elementBackgroundColor = UIColor.baseColor.cgColor
        // iCloudが無効の場合、不活性化
        if isiCloudEnabled {
            button.setTitleColor(.accentColor, for: .normal)
            // アイコン画像の色を指定する
            button.tintColor = .accentColor
            let backImage = UIImage(named: "baseline_cloud_upload_black_36pt")?.withRenderingMode(.alwaysTemplate)
            button.setImage(backImage, for: UIControl.State.normal)
            label.isHidden = true
        } else {
            button.setTitleColor(.mainColor, for: .normal)
            // アイコン画像の色を指定する
            button.tintColor = .mainColor
            let backImage = UIImage(named: "baseline_cloud_off_black_36pt")?.withRenderingMode(.alwaysTemplate)
            button.setImage(backImage, for: UIControl.State.normal)
            label.isHidden = false
        }
        button.isEnabled = isiCloudEnabled
        //  ボタンの画像サイズ変更
        button.imageView?.contentMode = .scaleAspectFit
        // button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
    }
    // 編集モード切り替え
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        tableView.setEditing(editing, animated: animated)
    }
    // バックアップ作成ボタン
    @IBAction func buttonTapped(_ sender: EMTNeumorphicButton) {
        // フィードバック
        if #available(iOS 10.0, *), let generator = feedbackGeneratorHeavy as? UIImpactFeedbackGenerator {
            generator.impactOccurred()
        }
        // ボタンを選択する
        sender.isSelected = !sender.isSelected
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            sender.isSelected = !sender.isSelected
        }
        // オフラインの場合iCloudへアクセスできないので、ネットワーク接続を確認する
        if Network.shared.isOnline() {
            // インジゲーターを開始
            self.showActivityIndicatorView()
            // iCloud Documents にバックアップを作成する
            BackupManager.shared.backup(
                completion: {
                    // イベントログ
                    FirebaseAnalytics.logEvent(
                        event: AnalyticsEvents.iCloudBackup,
                        parameters: [
                            AnalyticsEventParameters.kind.description: Parameter.backup.description as NSObject
                        ]
                    )
                },
                errorHandler: {
                    // インジケーターを終了
                    self.finishActivityIndicatorView()
                    // iCloud Drive へバックアップに失敗
                    self.showiCloudDriveDialog()
                }
            )
        } else {
            // フィードバック
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            // オフラインダイアログ
            self.showOfflineDialog()
        }
    }
    // tableViewをリロード
    func reload() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            BackupManager.shared.load {
                print($0)
                self.backupFiles = $0
                self.tableView.reloadData()
                // 編集ボタン
                if self.backupFiles.isEmpty {
                    self.setEditing(false, animated: true)
                    self.navigationController?.navigationItem.rightBarButtonItem?.isEnabled = false
                } else {
                    self.navigationController?.navigationItem.rightBarButtonItem?.isEnabled = true
                }
            }
        }
    }
    
    // インジゲーターを開始
    func showActivityIndicatorView() {
        DispatchQueue.main.async {
            // タブの無効化
            if let arrayOfTabBarItems = self.tabBarController?.tabBar.items as NSArray? {
                for tabBarItem in arrayOfTabBarItems {
                    if let tabBarItem = tabBarItem as? UITabBarItem {
                        tabBarItem.isEnabled = false
                    }
                }
            }
            // 背景になるView
            self.backView.backgroundColor = .mainColor
            // 表示位置を設定（画面中央）
            self.activityIndicatorView.center = CGPoint(x: self.view.center.x, y: self.view.center.y)
            // インジケーターのスタイルを指定（白色＆大きいサイズ）
            self.activityIndicatorView.style = UIActivityIndicatorView.Style.large
            // インジケーターを View に追加
            self.backView.addSubview(self.activityIndicatorView)
            // インジケーターを表示＆アニメーション開始
            self.activityIndicatorView.startAnimating()
            
            // tabBarControllerのViewを使う
            guard let tabBarView = self.tabBarController?.view else {
                return
            }
            // 背景をNavigationControllerのViewに貼り付け
            tabBarView.addSubview(self.backView)
            
            // サイズ合わせはAutoLayoutで
            self.backView.translatesAutoresizingMaskIntoConstraints = false
            self.backView.topAnchor.constraint(equalTo: tabBarView.topAnchor).isActive = true
            self.backView.bottomAnchor.constraint(equalTo: tabBarView.bottomAnchor).isActive = true
            self.backView.leftAnchor.constraint(equalTo: tabBarView.leftAnchor).isActive = true
            self.backView.rightAnchor.constraint(equalTo: tabBarView.rightAnchor).isActive = true
        }
    }
    // インジケーターを終了
    func finishActivityIndicatorView() {
        // 非同期処理などが終了したらメインスレッドでアニメーション終了
        DispatchQueue.main.async {
            // 非同期処理などを実行（今回は2秒間待つだけ）
            Thread.sleep(forTimeInterval: 1.0)
            // アニメーション終了
            self.activityIndicatorView.stopAnimating()
            // タブの有効化
            if let arrayOfTabBarItems = self.tabBarController?.tabBar.items as NSArray? {
                for tabBarItem in arrayOfTabBarItems {
                    if let tabBarItem = tabBarItem as? UITabBarItem {
                        tabBarItem.isEnabled = true
                    }
                }
            }
            self.backView.removeFromSuperview()
        }
    }
}

extension BackupViewController: UITableViewDelegate, UITableViewDataSource {
    // セクションの数を設定する
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    // セクションヘッダーのテキスト決める
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if backupFiles.isEmpty {
            return nil
        } else {
            return "バックアップ時刻"
        }
    }
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if backupFiles.isEmpty {
            return nil
        } else {
            return "復元する場合は、上記からバックアップファイルを選択してください。"
        }
    }
    // セルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        backupFiles.count
    }
    // セルを生成して返却するメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? WithIconTableViewCell else { return UITableViewCell() }
        // バックアップファイル一覧　時刻　バージョン　ファイルサイズMB
        cell.centerLabel.text = "\(backupFiles[indexPath.row].0)"
        if let size = backupFiles[indexPath.row].1 {
            let byteCountFormatter = ByteCountFormatter()
            byteCountFormatter.allowedUnits = [.useKB] // 使用する単位を選択
            byteCountFormatter.isAdaptive = true // 端数桁を表示する(123 MB -> 123.4 MB)(KBは0桁, MBは1桁, GB以上は2桁)
            byteCountFormatter.zeroPadsFractionDigits = true // trueだと100 MBを100.0 MBとして表示する(isAdaptiveをtrueにする必要がある)
            
            let byte = Measurement<UnitInformationStorage>(value: Double(truncating: size), unit: .bytes)
            
            byteCountFormatter.countStyle = .decimal // 1 KB = 1000 bytes
            print(byteCountFormatter.string(from: byte)) // 1,024 KB
            
            cell.subLabel.text = "\(byteCountFormatter.string(from: byte))"
        }
        // 未ダウンロードアイコン
        let isOniCloud = backupFiles[indexPath.row].2
        if isOniCloud {
            let image = UIImage(systemName: "icloud.and.arrow.down")?.withRenderingMode(.alwaysTemplate)
            let disclosureView = UIImageView(image: image)
            disclosureView.tintColor = UIColor.mainColor
            cell.accessoryView = disclosureView
        } else {
            cell.accessoryView = nil
        }
        
        cell.leftImageView.image = UIImage(named: "database-database_symbol")?.withRenderingMode(.alwaysTemplate)
        cell.shouldIndentWhileEditing = true
        
        return cell
    }
    // 編集機能
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }
    // 削除機能 セルを左へスワイプ
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "削除") { (action, view, completionHandler) in
            // オフラインの場合iCloudへアクセスできないので、ネットワーク接続を確認する
            if Network.shared.isOnline() {
                // 削除機能 アラートのポップアップを表示
                self.showPopover(indexPath: indexPath)
            } else {
                // フィードバック
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
                // オフラインダイアログ
                self.showOfflineDialog()
            }
            completionHandler(true) // 処理成功時はtrue/失敗時はfalseを設定する
        }
        action.image = UIImage(systemName: "trash.fill") // 画像設定（タイトルは非表示になる）
        let configuration = UISwipeActionsConfiguration(actions: [action])
        return configuration
    }
    // 削除機能 アラートのポップアップを表示
    private func showPopover(indexPath: IndexPath) {
        let alert = UIAlertController(title: "削除", message: "\(backupFiles[indexPath.row].0)\nバックアップファイルを削除しますか？", preferredStyle: .alert)
        
        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: .destructive,
                handler: { _ in
                    print("OK アクションをタップした時の処理")
                    // インジゲーターを開始
                    self.showActivityIndicatorView()
                    // バックアップファイルを削除
                    BackupManager.shared.deleteBackupFolder(
                        folderName: self.backupFiles[indexPath.row].0
                    )
                    // イベントログ
                    FirebaseAnalytics.logEvent(
                        event: AnalyticsEvents.iCloudBackup,
                        parameters: [
                            AnalyticsEventParameters.kind.description: Parameter.delete.description as NSObject
                        ]
                    )
                }
            )
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true) { () -> Void in
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                // self.dismiss にすると、ViewControllerを閉じてしまうので注意
                alert.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 未ダウンロード
        let isOniCloud = backupFiles[indexPath.row].2
        if isOniCloud {
            // オフラインの場合iCloudへアクセスできないので、ネットワーク接続を確認する
            if Network.shared.isOnline() {
                // 復元機能 アラートのポップアップを表示
                self.showPopoverRestore(indexPath: indexPath)
            } else {
                // フィードバック
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
                // オフラインダイアログ
                showOfflineDialog()
            }
        } else {
            // 復元機能 アラートのポップアップを表示
            self.showPopoverRestore(indexPath: indexPath)
        }
    }
    // オフラインダイアログ
    func showOfflineDialog() {
        // ネットワークなし
        let alert = UIAlertController(title: "インターネット未接続", message: "オフラインでは利用できません。", preferredStyle: .alert)
        present(alert, animated: true) { () -> Void in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                // self.dismiss にすると、ViewControllerを閉じてしまうので注意
                alert.dismiss(animated: true, completion: nil)
            }
        }
    }
    // iCloud Drive へバックアップに失敗
    func showiCloudDriveDialog() {
        // ネットワークなし
        let alert = UIAlertController(title: "iCloud Drive", message: "バックアップに失敗しました", preferredStyle: .alert)
        present(alert, animated: true) { () -> Void in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                // self.dismiss にすると、ViewControllerを閉じてしまうので注意
                alert.dismiss(animated: true, completion: nil)
            }
        }
    }
    // 復元機能 アラートのポップアップを表示
    private func showPopoverRestore(indexPath: IndexPath) {
        let alert = UIAlertController(
            title: "復元",
            message: """
                    バックアップファイルからデータベースを復元しますか？
                    現在のデータベースは上書きされます。
                    復元には時間がかかることがあります。
                    復元中は操作を行わずにお待ちください。
                    復元が完了後、アプリを再起動してください。
                    """,
            preferredStyle: .alert
        )
        
        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: .destructive,
                handler: { _ in
                    print("OK アクションをタップした時の処理")
                    // 最終確認
                    self.showPopoverRestoreAgain(indexPath: indexPath)
                }
            )
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true) { () -> Void in
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                // self.dismiss にすると、ViewControllerを閉じてしまうので注意
                alert.dismiss(animated: true, completion: nil)
            }
        }
    }
    // 復元機能 アラートのポップアップを表示
    private func showPopoverRestoreAgain(indexPath: IndexPath) {
        let alert = UIAlertController(
            title: "最終確認",
            message: """
                    バックアップファイルからデータベースを復元しますか？
                    現在のデータベースは上書きされます。
                    """,
            preferredStyle: .alert
        )
        
        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: .destructive,
                handler: { _ in
                    print("OK アクションをタップした時の処理")
                    // 復元処理
                    self.restore(indexPath: indexPath)
                    // イベントログ
                    FirebaseAnalytics.logEvent(
                        event: AnalyticsEvents.iCloudBackup,
                        parameters: [
                            AnalyticsEventParameters.kind.description: Parameter.restore.description as NSObject
                        ]
                    )
                }
            )
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true) { () -> Void in
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                // self.dismiss にすると、ViewControllerを閉じてしまうので注意
                alert.dismiss(animated: true, completion: nil)
            }
        }
    }
    // 復元処理
    func restore(indexPath: IndexPath) {
        // インジゲーターを開始
        self.showActivityIndicatorView()
        DispatchQueue.global(qos: .default).async {
            // iCloud Documents からデータベースを復元する
            BackupManager.shared.restore(folderName: self.backupFiles[indexPath.row].0) {
                // インジケーターを終了
                self.finishActivityIndicatorView()
                Thread.sleep(forTimeInterval: 1.5)
                DispatchQueue.main.async {
                    // 既存のRealmを開放させるため アプリ終了
                    UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
                    Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
                        exit(0)
                    }
                }
            }
        }
    }
}

// 流れ
// ファイル/ディレクトリを管理するオブジェクトにNSFilePresenterプロトコルを指定する。
// NSFileCoordinatorのaddFilePresenter:クラスを呼び出してオブジェクトを登録する。
// NSFilePresenterのメソッド内にそれぞれの処理を書く
// 管理が必要なくなるタイミングでNSFileCoordinatorのremoveFilePresenterを呼び出してファイルプレゼンタの登録を解除する。
extension BackupViewController: NSFilePresenter {
    
    // ファイルプレゼンタをシステムに登録
    func addFilePresenterIfNeeded() {
        if !isPresenting {
            isPresenting = true
            NSFileCoordinator.addFilePresenter(self)
        }
    }
    
    // ファイルプレゼンタをシステムの登録から解除
    func removeFilePresenterIfNeeded() {
        if isPresenting {
            isPresenting = false
            NSFileCoordinator.removeFilePresenter(self)
        }
    }
    
    // 提示された項目の内容または属性が変更されたことを伝える。
    func presentedItemDidChange() {
        print("Change item.")
        // tableViewをリロード
        reload()
        // インジケーターを終了
        self.finishActivityIndicatorView()
    }
    
    // ファイルまたはファイルパッケージの新しいバージョンが追加されたことをデリゲートに通知する
    func presentedItemDidGainVersion(version: NSFileVersion) {
        print("Update file at \(version.modificationDate).")
    }
    
    // ファイルまたはファイルパッケージのバージョンが消えたことをデリゲートに通知する
    func presentedItemDidLoseVersion(version: NSFileVersion) {
        print("Lose file version at \(version.modificationDate).")
    }
    
    // ディレクトリ内のアイテムが新しいバージョンになった（更新された）時の通知
    func presentedSubitem(at url: URL, didGain version: NSFileVersion) {
        
        var isDir = ObjCBool(false)
        if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) {
            if Bool(isDir.boolValue) {
                print("Update directory (\(url.path)) at \(version.modificationDate).")
            } else {
                print("Update file (\(url.path)) at \(version.modificationDate).")
            }
        }
    }
    
    // ディレクトリ内のアイテムが削除された時の通知
    func presentedSubitem(at url: URL, didLose version: NSFileVersion) {
        print("looooooooooooose")
        var isDir = ObjCBool(false)
        if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) {
            if Bool(isDir.boolValue) {
                print("Lose directory version (\(url.path)) at \(version.modificationDate).")
            } else {
                print("Lose file version (\(url.path)) at \(version.modificationDate).")
            }
        }
    }
    
    // ファイル/ディレクトリの内容変更の通知
    func presentedSubitemDidChange(at url: URL) {
        if FileManager.default.fileExists(atPath: url.path) {
            print("Add subitem (\(url.path)).")
        } else {
            print("Remove subitem (\(url.path)).")
        }
        // tableViewをリロード
        reload()
        // インジケーターを終了
        self.finishActivityIndicatorView()
    }
    
    // ファイル/ディレクトリが移動した時の通知
    func presentedSubitemAtURL(oldURL: NSURL, didMoveToURL newURL: NSURL) {
        var isDir = ObjCBool(false)
        if FileManager.default.fileExists(atPath: newURL.path!, isDirectory: &isDir) {
            if Bool(isDir.boolValue) {
                print("Move directory from (\(oldURL.path)) to (\(newURL.path!).")
            } else {
                print("Move file from (\(oldURL.path)) to (\(newURL.path)).")
            }
        }
    }
    
    // MARK: 何したら呼ばれるのか
    
    // 何したら呼ばれるのか
    func accommodatePresentedItemDeletionWithCompletionHandler(completionHandler: (NSError?) -> Void) {
        print("accommodatePresentedItemDeletionWithCompletionHandler")
    }
    
    // 何したら呼ばれるのか
    private func accommodatePresentedSubitemDeletionAtURL(url: URL, completionHandler: @escaping (NSError?) -> Void) {
        print("accommodatePresentedSubitemDeletionAtURL")
        print("url: \(url.path)")
    }
    
    // 何したら呼ばれるのか
    func presentedSubitemDidAppear(at url: URL) {
        print("presentedSubitemDidAppearAtURL")
        print("url: \(url.path)")
    }
}

extension BackupViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // 長押しによる選択、コールアウト表示を禁止する
        webView.prohibitTouchCalloutAndUserSelect()
    }
}
