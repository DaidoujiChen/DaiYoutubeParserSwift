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
    class func webView(webView: DaiYoutubeParserWebView, didFailLoadWithError error: NSError?) {
        webView.terminal()
        webView.fail()
    }
    
}

// MARK: Private Class Method
extension DaiYoutubeParserWebView {
    
    // 將列舉轉為字串
    private class func videoQualityString(videoQuality: DaiYoutubeParserQuality) -> String {
        switch videoQuality {
            case .Small:
                return "small"
            case .Medium:
                return "medium"
            case .Large:
                return "large"
            case .HD720:
                return "hd720"
            case .HD1080:
                return "hd1080"
            case .Highres:
                return "highres"
        }
    }
    
}

// MARK: Private Instance Method
extension DaiYoutubeParserWebView {
    
    // 取得影片 title
    private func videoTitle() -> String? {
        return self.stringByEvaluatingJavaScriptFromString("getVideoTitle()")
    }
    
    // 取得影片時間
    private func duration() -> Int? {
        guard let safeDuration = self.stringByEvaluatingJavaScriptFromString("getDuration()") else {
            return nil
        }
        return Int(safeDuration)
    }
    
    // 自身清除
    private func terminal() {
        self.stopLoading()
        if let safeCheckTimer = self.checkTimer {
            safeCheckTimer.invalidate()
        }
    }
    
    // 每 1.5 秒確認一次狀態
    @objc private func stateCheck(timer: NSTimer) {
        guard let safeStatus = self.stringByEvaluatingJavaScriptFromString("error();") else {
            return
        }
        
        if Int(safeStatus) > 0 {
            self.terminal()
            self.fail()
        }
    }
    
    // 失敗時候的 callback
    private func fail() {
        if let safeCompletion = self.completion {
            safeCompletion(status: .Fail, url: nil, videoTitle: nil, videoDuration: nil)
        }
    }
    
    // 複寫系統 method
    func webView(arg1: AnyObject?,identifierForInitialRequest arg2: NSMutableURLRequest?, fromDataSource arg3: AnyObject?) -> AnyObject? {

        // 檢查 arg2 存在, 而且 URL 有值
        guard
            let safeArg2 = arg2,
            let safeURL = safeArg2.URL
            else {
                return messageSendToSuper(self, arg1, arg2, arg3)
        }
        
        // 判斷這個網址是不是有含我們需要的字串內容
        let urlString = String(safeURL)
        switch urlString {
        case _ where urlString.containsString("videoplayback?"):
            fallthrough
        case _ where urlString.containsString(".m3u8"):
            if let safeCompletion = self.completion {
                safeCompletion(status: .Success, url: urlString, videoTitle: self.videoTitle(), videoDuration: self.duration())
            }
            return nil
        default:
            return messageSendToSuper(self, arg1, arg2, arg3)
        }
    }
    
}

// MARK: DaiYoutubeParserWebView
class DaiYoutubeParserWebView: UIWebView {
    
    private var completion: DaiYoutubeParserComplection?
    private var checkTimer: NSTimer?

    // 建立一個新的 DaiYoutubeParserWebView
    class func createWebView(youtubeID: String, screenSize: CGSize, videoQuality: DaiYoutubeParserQuality, completion: DaiYoutubeParserComplection) -> DaiYoutubeParserWebView? {
        let videoQualityString = self.videoQualityString(videoQuality)
        
        // 檢查檔案是否讀取正常
        guard
            let safeHtmlFilePath = NSBundle.mainBundle().pathForResource("YoutubeParserBridge", ofType: "html"),
            let safeOriginalHtmlString = try? String(contentsOfFile: safeHtmlFilePath, encoding: NSUTF8StringEncoding)
            else {
                print("Load Local Html File Fail")
                return nil
        }
        
        // 設定新的 DaiYoutubeParserWebView
        let newWebView = DaiYoutubeParserWebView(frame: CGRectMake(0, 0, screenSize.width, screenSize.height))
        newWebView.delegate = self as? UIWebViewDelegate
        newWebView.allowsInlineMediaPlayback = true
        newWebView.mediaPlaybackRequiresUserAction = false
        newWebView.completion = { [weak newWebView] (status: DaiYoutubeParserStatus, url: String?, videoTitle: String?, videoDuration: Int?) -> Void in
            if let safeWebView = newWebView {
                safeWebView.terminal()
            }
            completion(status: status, url: url, videoTitle: videoTitle, videoDuration: videoDuration)
        }
        
        // 開始讀取本地網頁
        let htmlWithParameterString = String(format: safeOriginalHtmlString, screenSize.width, screenSize.height, youtubeID, videoQualityString)
        newWebView.loadHTMLString(htmlWithParameterString, baseURL: NSURL(string: "http://www.example.com"))
        newWebView.checkTimer = NSTimer.scheduledTimerWithTimeInterval(1.5, target: newWebView, selector: "stateCheck:", userInfo: nil, repeats: true)
        return newWebView
    }
    
}
