//
//  RequestReviewManager.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2024/05/02.
//  Copyright © 2024 Hisashi Ishihara. All rights reserved.
//

import StoreKit
import UIKit

// レビュー促進ダイアログ
class RequestReviewManager {
    
    public static let shared = RequestReviewManager()
    
    private init() {
        self.currentAppVersion = AppVersion.currentVersion
    }
    
    // アプリ起動回数
    var processCompletedCount: Int {
        get {
            return UserDefaults.standard.integer(forKey: Constant.PROCESS_COMPLETED_COUNT)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constant.PROCESS_COMPLETED_COUNT)
        }
    }
    // 最後にダイアログを表示した時のアプリバージョン
    var lastVersionPromptedForReview: String? {
        get {
            return UserDefaults.standard.string(forKey: Constant.LAST_VERSION_PROMPETD_FOR_REVIEW)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constant.LAST_VERSION_PROMPETD_FOR_REVIEW)
        }
    }
    // 最後にダイアログを表示した日
    var showReviewDialogDate: Date? {
        get {
            guard let dateString = UserDefaults.standard.string(forKey: Constant.SHOW_REVIEW_DIALOG_DATE),
                  let date = Date.iso8601Date(from: dateString) else { return nil }
            return date
        }
        set {
            if let date = newValue {
                let dateString = Date.iso8601String(date: date)
                UserDefaults.standard.set(dateString, forKey: Constant.SHOW_REVIEW_DIALOG_DATE)
            } else {
                UserDefaults.standard.set(nil, forKey: Constant.SHOW_REVIEW_DIALOG_DATE)
            }
        }
    }
    
    /// The current version of this app.
    var currentAppVersion: String?
    /// The threshold value to determine whether this app can request review to ther user.
    var thresholdCountForReviewRequest: Int = 10
    /// The waittime value to determine whether the user is continuing to perform tasks.
    var waitTimeForReviewRequest: Double = 3.0
    /// The work item, which stores request of app store review.
    ///
    /// The work item is used to protect multiple request at same time.
    var requestReviewWorkItem: DispatchWorkItem?
    /// The bool value whether this app can request app review to the user.
    var canRequestReview: Bool {
        print("Process completed  : \(processCompletedCount >= thresholdCountForReviewRequest) \(processCompletedCount) / \(thresholdCountForReviewRequest) time(s) ")
        print("Current app version: \(lastVersionPromptedForReview != currentAppVersion) \(lastVersionPromptedForReview ?? "nil") -> \(currentAppVersion ?? "nil")")
        // 表示フラグ立っていて、なおかつ、前回のダイアログを表示した日から122日を経過してるかを判定
        return processCompletedCount >= thresholdCountForReviewRequest && lastVersionPromptedForReview != currentAppVersion && judgeDateOver122Days()
    }
    
    // アプリ起動回数をインクリメントする
    func incrementProcessCompletedCount() {
        if processCompletedCount < thresholdCountForReviewRequest {
            // 永遠にインクリメントするのを防ぐ
            processCompletedCount += 1
        }
    }
    // 前回のダイアログを表示した日から122日を経過してるか
    func judgeDateOver122Days() -> Bool {
        guard let reviewDate = showReviewDialogDate else {
            showReviewDialogDate = Date()
            return false
        }
        let last = Calendar.current.startOfDay(for: reviewDate)
        let now = Calendar.current.startOfDay(for: Date())
        print("Show Review Dialog Date: \(reviewDate)")
        print("                   last: \(last)")
        print("                   now : \(now)")
        print("                   \(!(Calendar.current.dateComponents([.day], from: last, to: now).day ?? 0 < 122))")
        print("\n")
        if Calendar.current.dateComponents([.day], from: last, to: now).day ?? 0 < 122 {
            // 前回表示時から条件未達なので何もしない
            return false
        } else {
            return true
        }
    }
    
    /// Requests review for this app if the provided condition returns true.
    ///
    /// You must use this method after checking `canRequestReview` and it returns true like bellow:
    ///
    ///     if requestReviewManager.canRequestReview {
    ///         requestReviewManager.requestReview(in: view.window!.windowScene!) {
    ///             // Do something
    ///             return true
    ///         }
    ///     }
    ///
    /// - Parameters:
    ///   - windowScene: The window scene to present the review prompt.
    ///   - conditionAfterWait: The condition which is asked after some wait time.
    func requestReview(in windowScene: UIWindowScene, conditionAfterWait condition: @escaping () -> Bool) {
        // Cancel previous request.
        requestReviewWorkItem?.cancel()
        // Make new request work.
        requestReviewWorkItem = DispatchWorkItem(block: { [weak self] in
            if condition() {
                if #available(iOS 14.0, *) {
                    SKStoreReviewController.requestReview(in: windowScene)
                } else {
                    // Fallback on earlier versions
                    SKStoreReviewController.requestReview()
                }
                self?.lastVersionPromptedForReview = self?.currentAppVersion
                self?.showReviewDialogDate = Date()
                print(self?.showReviewDialogDate)
            }
        })
        // Scedule the request.
        DispatchQueue.main.asyncAfter(deadline: .now() + waitTimeForReviewRequest, execute: requestReviewWorkItem!)
    }
}
