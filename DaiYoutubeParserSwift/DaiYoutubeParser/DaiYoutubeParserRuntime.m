//
//  DaiYoutubeParserRuntime.m
//  TycheRadioReborn
//
//  Created by DaidoujiChen on 2015/11/5.
//  Copyright © 2015年 ChilunChen. All rights reserved.
//

#import "DaiYoutubeParserRuntime.h"
#import <objc/message.h>

id messageSendToSuper(NSObject *self, id arg1, id arg2, id arg3) {
    struct objc_super superObject;
    superObject.receiver = self;
    superObject.super_class = class_isMetaClass(object_getClass(self)) ? object_getClass(self.superclass) : self.superclass;
    SEL selector = NSSelectorFromString(@"webView:identifierForInitialRequest:fromDataSource:");
    return ((id (*)(id, SEL, id, id, id))objc_msgSendSuper)((__bridge id)(&superObject), selector, arg1, arg2, arg3);
}
