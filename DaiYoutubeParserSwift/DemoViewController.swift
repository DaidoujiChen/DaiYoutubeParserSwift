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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        cell.textLabel?.text = self.dataSource[indexPath.row]
        return cell
    }
    
}

// MARK: UITableViewDelegate
extension DemoViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DaiYoutubeParser.parse(self.dataSource[indexPath.row], self.videoContainView.bounds.size, .highres) { [weak self] (status, url, videoTitle, videoDuration) -> Void in
            
            // 檢查 callback 回來時 DemoViewController 是不是已經不存在
            guard
                let safeSelf = self
                else {
                print("DemoViewController Dealloced")
                return
            }
            
            guard
                let safeURLString = url,
                let safeURL = URL(string: safeURLString),
                let safeVideoTitle = videoTitle,
                let safeVideoDuration = videoDuration,
                status == .success
                else {
                    let alert = UIAlertController(title: "Load Video Fail", message: "Handle on Fail", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: nil))
                    safeSelf.present(alert, animated: true, completion: nil)
                    return
            }
            
            // 設定顯示資訊
            let duration = String(format: "%02td:%02td", safeVideoDuration / 60, safeVideoDuration % 60)
            let title = String(format: "(%@) %@", duration, safeVideoTitle)
            safeSelf.titleTextField.text = title
            safeSelf.urlTextField.text = safeURLString
            
            // 如果有正在播放的影片, 先停止他並且移除
            if let safeAVPlayerLayer = safeSelf.avPlayerLayer, let safePlayer = safeAVPlayerLayer.player {
                safePlayer.pause()
                safeAVPlayerLayer.removeFromSuperlayer()
            }
            
            // 製作新的播放器
            let avAssert = AVURLAsset(url: safeURL)
            let avPlayerItem = AVPlayerItem(asset: avAssert)
            let avPlayer = AVPlayer(playerItem: avPlayerItem)
            let avPlayerLayer = AVPlayerLayer(player: avPlayer)
            avPlayerLayer.frame = safeSelf.videoContainView.bounds
            safeSelf.videoContainView.layer.addSublayer(avPlayerLayer)
            safeSelf.avPlayerLayer = avPlayerLayer
            avPlayer.play()
        }
    }
    
}

// MARK: DemoViewController
class DemoViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var videoListTableView: UITableView!
    @IBOutlet weak var videoContainView: UIView!
    
    fileprivate let dataSource = ["6J1B1NMpX-E", "12345", "2cEi8IpUpBo", "P5KCCfURTCA", "ADkvjHwGQDY", "mIIb3Jf06AA", "ViJ-geMKm0Q", "W43FJw3yKGM", "3iB8TCqagFQ"]
    weak var avPlayerLayer: AVPlayerLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.videoListTableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
    }
    
}
