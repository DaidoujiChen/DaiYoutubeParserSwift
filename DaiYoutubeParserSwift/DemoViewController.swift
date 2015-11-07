//
//  DemoViewController.swift
//  DaiYoutubeParserSwift
//
//  Created by 啟倫 陳 on 2015/11/7.
//  Copyright © 2015年 ChilunChen. All rights reserved.
//

import UIKit
import AVFoundation

// MARK: UITableViewDataSource
extension DemoViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UITableViewCell", forIndexPath: indexPath)
        cell.textLabel?.text = self.dataSource[indexPath.row]
        return cell
    }
    
}

// MARK: UITableViewDelegate
extension DemoViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        DaiYoutubeParser.parse(self.dataSource[indexPath.row], screenSize: self.videoContainView.bounds.size, videoQuality: .Highres) { [weak self] (status, url, videoTitle, videoDuration) -> Void in
            
            if status == .Success {
                guard
                    let strongSelf = self,
                    let safeURLString = url,
                    let safeURL = NSURL(string: safeURLString),
                    let safeVideoTitle = videoTitle,
                    let safeVideoDuration = videoDuration
                    else {
                        print("Data Check Fail")
                        return
                }
                
                // 設定顯示資訊
                let duration = String(format: "%02td:%02td", safeVideoDuration / 60, safeVideoDuration % 60)
                let title = String(format: "(%@) %@", duration, safeVideoTitle)
                strongSelf.titleTextField.text = title
                strongSelf.urlTextField.text = safeURLString
                
                // 如果有正在播放的影片, 先停止他並且移除
                if strongSelf.avPlayerLayer != nil {
                    strongSelf.avPlayerLayer?.player?.pause()
                    strongSelf.avPlayerLayer?.removeFromSuperlayer()
                }
                
                // 製作新的播放器
                let avAssert = AVURLAsset(URL: safeURL)
                let avPlayerItem = AVPlayerItem(asset: avAssert)
                let avPlayer = AVPlayer(playerItem: avPlayerItem)
                let avPlayerLayer = AVPlayerLayer(player: avPlayer)
                avPlayerLayer.frame = strongSelf.videoContainView.bounds
                strongSelf.videoContainView.layer.addSublayer(avPlayerLayer)
                strongSelf.avPlayerLayer = avPlayerLayer
                avPlayer.play()
            }
            else {
                let alert = UIAlertController(title: "Load Video Fail", message: "Handle on Fail", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Done", style: .Cancel, handler: nil))
                self?.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
}

// MARK: DemoViewController
class DemoViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var videoListTableView: UITableView!
    @IBOutlet weak var videoContainView: UIView!
    
    var dataSource = ["6J1B1NMpX-E", "12345", "2cEi8IpUpBo", "P5KCCfURTCA", "ADkvjHwGQDY", "mIIb3Jf06AA", "ViJ-geMKm0Q", "W43FJw3yKGM", "3iB8TCqagFQ"]
    weak var avPlayerLayer: AVPlayerLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.videoListTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
    }
    
}
