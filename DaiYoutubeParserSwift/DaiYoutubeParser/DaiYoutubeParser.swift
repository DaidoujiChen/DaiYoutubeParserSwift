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
    case Small, Medium, Large, HD720, HD1080, Highres
}

// 成功或是失敗
enum DaiYoutubeParserStatus {
    case Fail, Success
}

// closure 縮寫
typealias DaiYoutubeParserComplection = (status: DaiYoutubeParserStatus, url: String?, videoTitle: String?, videoDuration: Int?) -> Void

class DaiYoutubeParser {
    
    private static let parserTaskQueue = NSOperationQueue()
    
    // parse 某個 youtube id 的影片網址
    class func parse(youtubeID: String, screenSize: CGSize, videoQuality: DaiYoutubeParserQuality, completion: DaiYoutubeParserComplection) {
        
        // 加入排程
        self.parserTaskQueue.addOperationWithBlock { _ -> Void in
            dispatch_async(dispatch_get_main_queue(), { _ -> Void in
                DaiYoutubeParserWebView.createWebView(youtubeID, screenSize: screenSize, videoQuality: videoQuality, completion: { (status, url, videoTitle, videoDuration) -> Void in
                    completion(status: status, url: url, videoTitle: videoTitle, videoDuration: videoDuration)
                })
            })
        }
    }
    
}