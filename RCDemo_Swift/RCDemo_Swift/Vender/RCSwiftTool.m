//
//  RCSwiftTool.m
//  RCDemo_Swift
//
//  Created by 孙浩 on 2019/3/25.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCSwiftTool.h"

@implementation RCSwiftTool

+ (UIImageView *)getImageViewFromRCConversationCell:(RCConversationCell *)cell {
    return (UIImageView *)cell.headerImageView;
}

+ (UIImageView *)getImageViewFromRCMessageCell:(RCMessageCell *)cell {
    return (UIImageView *)cell.portraitImageView;
}

@end
