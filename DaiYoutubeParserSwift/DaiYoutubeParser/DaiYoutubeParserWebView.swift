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
        webView.terminalWebView()
        webView.completion?(status: .Fail, url: nil, videoTitle: nil, videoDuration: nil)
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
    private func terminalWebView() {
        self.stopLoading()
        self.checkTimer?.invalidate()
        self.checkTimer = nil
    }
    
    // 每 1.5 秒確認一次狀態
    @objc private func stateCheck(timer: NSTimer) {
        guard let safeStatus = self.stringByEvaluatingJavaScriptFromString("error();") else {
            return
        }
        
        if Int(safeStatus) > 0 {
            self.terminalWebView()
            self.completion?(status: .Fail, url: nil, videoTitle: nil, videoDuration: nil)
        }
    }
    
    // 複寫系統 method
    func webView(arg1: AnyObject?,identifierForInitialRequest arg2: NSMutableURLRequest?, fromDataSource arg3: AnyObject?) -> AnyObject? {

        var isFoundTargetString = false
        
        guard let safeURL = arg2?.URL else {
            return swiftHelper(self, arg1, arg2, arg3)
        }
        
        let urlString = String(format: "%@", safeURL)
        if urlString.containsString("videoplayback?") {
            isFoundTargetString = true
        }
        else if urlString.containsString(".m3u8") {
            isFoundTargetString = true
        }
        
        if isFoundTargetString {
            self.completion?(status: .Success, url: urlString, videoTitle: self.videoTitle(), videoDuration: self.duration())
            return nil
        }
        else {
            return swiftHelper(self, arg1, arg2, arg3)
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
        let returnWebView = DaiYoutubeParserWebView(frame: CGRectMake(0, 0, screenSize.width, screenSize.height))
        returnWebView.delegate = self as? UIWebViewDelegate
        returnWebView.allowsInlineMediaPlayback = true
        returnWebView.mediaPlaybackRequiresUserAction = false
        returnWebView.completion = { [weak returnWebView] (status: DaiYoutubeParserStatus, url: String?, videoTitle: String?, videoDuration: Int?) -> Void in
            returnWebView?.terminalWebView()
            completion(status: status, url: url, videoTitle: videoTitle, videoDuration: videoDuration)
        }
        
        // 開始讀取本地網頁
        let htmlWithParameterString = String(format: safeOriginalHtmlString, screenSize.width, screenSize.height, youtubeID, videoQualityString)
        returnWebView.loadHTMLString(htmlWithParameterString, baseURL: NSURL(string: "http://www.example.com"))
        returnWebView.checkTimer = NSTimer.scheduledTimerWithTimeInterval(1.5, target: returnWebView, selector: "stateCheck:", userInfo: nil, repeats: true)
        return returnWebView
    }
    
}
