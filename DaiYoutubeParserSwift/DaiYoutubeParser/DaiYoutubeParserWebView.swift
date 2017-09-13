//
//  DaiYoutubeParserWebView.swift
//  TycheRadioReborn
//
//  Created by DaidoujiChen on 2015/11/5.
//  Copyright © 2015年 ChilunChen. All rights reserved.
//

import UIKit

// MARK: UIWebViewDelegate
extension DaiYoutubeParserWebView: UIWebViewDelegate {
    
    // 錯誤時回報
    @nonobjc class func webView(_ webView: DaiYoutubeParserWebView, didFailLoadWithError error: NSError?) {
        webView.terminal()
        webView.fail()
    }
    
}

// MARK: Private Instance Method
extension DaiYoutubeParserWebView {
    
    // 取得影片 title
    fileprivate func videoTitle() -> String? {
        return self.stringByEvaluatingJavaScript(from: "getVideoTitle()")
    }
    
    // 取得影片時間
    fileprivate func duration() -> Int? {
        guard
            let safeDuration = self.stringByEvaluatingJavaScript(from: "getDuration()")
            else {
            return nil
        }
        return Int(safeDuration)
    }
    
    // 自身清除
    fileprivate func terminal() {
        self.stopLoading()
        if let safeCheckTimer = self.checkTimer {
            safeCheckTimer.invalidate()
        }
    }
    
    // 每 1.5 秒確認一次狀態
    fileprivate dynamic func stateCheck(_ timer: Timer) {
        guard
            let safeStatus = self.stringByEvaluatingJavaScript(from: "error();")
            else {
            return
        }
        
        if let safeStatusInt = Int(safeStatus), safeStatusInt > 0 {
            self.terminal()
            self.fail()
        }
    }
    
    // 失敗時候的 callback
    fileprivate func fail() {
        if let safeCompletion = self.completion {
            safeCompletion(.fail, nil, nil, nil)
        }
    }
    
    // 複寫系統 method
    func webView(_ arg1: AnyObject?,identifierForInitialRequest arg2: NSMutableURLRequest?, fromDataSource arg3: AnyObject?) -> AnyObject? {

        // 檢查 arg2 存在, 而且 URL 有值
        guard
            let safeArg2 = arg2,
            let safeURL = safeArg2.url
            else {
                return messageSendToSuper(self, arg1, arg2, arg3) as AnyObject
        }
        
        // 判斷這個網址是不是有含我們需要的字串內容
        let urlString = String(describing: safeURL)
        switch urlString {
        case _ where urlString.contains("videoplayback?"):
            fallthrough
        case _ where urlString.contains(".m3u8"):
            if let safeCompletion = self.completion {
                safeCompletion(.success, urlString, self.videoTitle(), self.duration())
            }
            return nil
        default:
            return messageSendToSuper(self, arg1, arg2, arg3) as AnyObject
        }
    }
    
}

// MARK: DaiYoutubeParserWebView
class DaiYoutubeParserWebView: UIWebView {
    
    fileprivate var completion: DaiYoutubeParserComplection?
    fileprivate var checkTimer: Timer?

    // 建立一個新的 DaiYoutubeParserWebView
    class func createWebView(_ youtubeID: String, _ screenSize: CGSize, _ videoQuality: DaiYoutubeParserQuality, _ completion: @escaping DaiYoutubeParserComplection) -> DaiYoutubeParserWebView? {
        
        // 檢查檔案是否讀取正常
        guard
            let safeHtmlFilePath = Bundle.main.path(forResource: "YoutubeParserBridge", ofType: "html"),
            let safeOriginalHtmlString = try? String(contentsOfFile: safeHtmlFilePath, encoding: String.Encoding.utf8)
            else {
                print("Load Local Html File Fail")
                return nil
        }
        
        // 設定新的 DaiYoutubeParserWebView
        let newWebView = DaiYoutubeParserWebView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
        newWebView.delegate = self as? UIWebViewDelegate
        newWebView.allowsInlineMediaPlayback = true
        newWebView.mediaPlaybackRequiresUserAction = false
        newWebView.completion = { [weak newWebView] (status: DaiYoutubeParserStatus, url: String?, videoTitle: String?, videoDuration: Int?) -> Void in
            if let safeWebView = newWebView {
                safeWebView.terminal()
            }
            completion(status, url, videoTitle, videoDuration)
        }
        
        // 開始讀取本地網頁
        let htmlWithParameterString = String(format: safeOriginalHtmlString, screenSize.width, screenSize.height, youtubeID, videoQuality.rawValue.lowercased())
        newWebView.loadHTMLString(htmlWithParameterString, baseURL: URL(string: "http://www.example.com"))
        newWebView.checkTimer = Timer.scheduledTimer(timeInterval: 1.5, target: newWebView, selector: #selector(DaiYoutubeParserWebView.stateCheck(_:)), userInfo: nil, repeats: true)
        return newWebView
    }
    
}
