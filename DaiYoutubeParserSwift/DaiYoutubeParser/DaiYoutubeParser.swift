//
//  DaiYoutubeParser.swift
//  TycheRadioReborn
//
//  Created by DaidoujiChen on 2015/11/5.
//  Copyright © 2015年 ChilunChen. All rights reserved.
//

import UIKit

// 影片品質
enum DaiYoutubeParserQuality: String {
    case small, medium, large, hd720, hd1080, highres
}

// 成功或是失敗
enum DaiYoutubeParserStatus {
    case fail, success
}

// closure 縮寫
typealias DaiYoutubeParserComplection = (_ status: DaiYoutubeParserStatus, _ url: String?, _ videoTitle: String?, _ videoDuration: Int?) -> Void

class DaiYoutubeParser {
    
    fileprivate static let parserTaskQueue = OperationQueue()
    
    // parse 某個 youtube id 的影片網址
    class func parse(_ youtubeID: String, _ screenSize: CGSize, _ videoQuality: DaiYoutubeParserQuality, _ completion: @escaping DaiYoutubeParserComplection) {
        
        // 加入排程
        self.parserTaskQueue.addOperation {
            DispatchQueue.main.async(execute: {
                _ = DaiYoutubeParserWebView.createWebView(youtubeID, screenSize, videoQuality, completion)
            })
        }
    }
    
}
