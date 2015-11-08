# DaiYoutubeParserSwift
Parse the youtube video url path, do any custom things you want.

![image](https://s3-ap-northeast-1.amazonaws.com/daidoujiminecraft/Daidouji/DaiYoutubeParser.gif)

DaidoujiChen

daidoujichen@gmail.com

## Installation
Copy all the files in `DaiYoutubeParserSwift\DaiYoutubeParser` to your project.

And add 

`````objc
#import "DaiYoutubeParserRuntime.h"
`````
to your `Objective-C Bridging Header`

## Usage
It is very easy to use, there is a only method

`````swift
parse(youtubeID: String, screenSize: CGSize, videoQuality: DaiYoutubeParserQuality, completion: DaiYoutubeParserComplection)
`````

 - youtubeID, your target youtube video ID
 - screenSize, the screen size you want to show
 - videoQuality, choose the video quality. If the screenSize is not large enough, the video qulity can not get the better one
 - completion, callback success or fail, and the video url path

simple to use

`````swift
DaiYoutubeParser.parse("2cEi8IpUpBo", screenSize: CGSizeZero, videoQuality: .Small) { (status, url, videoTitle, videoDuration) -> Void in
            if status == .Success {
                print(videoTitle);
                print(videoDuration);
                print(url);
            }
            else {
                print("load fail")
            }
        }
`````
