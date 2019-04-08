//
//  RCSwiftTool.h
//  RCDemo_Swift
//
//  Created by 孙浩 on 2019/3/25.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMKit/RongIMKit.h>

NS_ASSUME_NONNULL_BEGIN

// 由于 Swift 无法直接获取到会话 Cell 和消息 Cell 的头像，利用 RCSwiftTool 类获取
@interface RCSwiftTool : NSObject

// 获取会话列表中会话 cell 的头像
+ (UIImageView *)getImageViewFromRCConversationCell:(RCConversationCell *)cell;

// 获取会话页面中消息 cell 的头像
+ (UIImageView *)getImageViewFromRCMessageCell:(RCMessageCell *)cell;

@end

NS_ASSUME_NONNULL_END
