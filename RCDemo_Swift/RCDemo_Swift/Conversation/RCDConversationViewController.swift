//
//  RCDConversationViewController.swift
//  RCDemo_Swift
//
//  Created by 孙浩 on 2019/3/13.
//  Copyright © 2019 RongCloud. All rights reserved.
//

import UIKit

class RCDConversationViewController: RCConversationViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = nil
        // 添加测试消息的入口
        chatSessionInputBarControl.pluginBoardView.insertItem(with: UIImage(named: "urlPic"), title: "测试消息", tag: 2001)
        
        // 注册自定义消息的Cell
        register(RCDTestMessageCell.self, forMessageClass: RCDTestMessage.self)
        
        
        // 加号区域增加发送文件功能，Kit 中已经默认实现了该功能，但是为了 SDK 向后兼容性，目前 SDK 默认不开启该入口，可以参考以下代码在加号区域中增加发送文件功能。
        if conversationType != RCConversationType.ConversationType_APPSERVICE && conversationType != RCConversationType.ConversationType_PUBLICSERVICE {
            let imageFile = RCKitUtility.imageNamed("actionbar_file_icon", ofBundle: "RongCloud.bundle")
            let pluginBoardView = chatSessionInputBarControl.pluginBoardView
            pluginBoardView?.insertItem(with: imageFile, title: "File", at: 3, tag: Int(PLUGIN_BOARD_ITEM_FILE_TAG))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 设置输入框的默认输入模式
//        defaultInputType = RCChatSessionInputBarInputType.voice
    }
    
    // 添加附加信息
    override func willSendMessage(_ messageContent: RCMessageContent!) -> RCMessageContent! {
        
        if messageContent.isKind(of: RCDTestMessage.self) {
            let testMessage = messageContent as? RCDTestMessage
            testMessage?.extra = "附加信息"
            return testMessage
        }
        return messageContent
    }
    
    override func didTapMessageCell(_ model: RCMessageModel!) {
        super.didTapMessageCell(model)
        
        if let content = model.content {
            if content.isKind(of: RCDTestMessage.self) {
                guard let testMsg = content as? RCDTestMessage else {
                    return
                }
                let alertView = UIAlertView(title: "RCDTestMessage", message: "content:\(testMsg.content), extra: \(String(describing: testMsg.extra))", delegate: self, cancelButtonTitle: "OK")
                alertView.show()
            }
        }
    }
    
    override func pluginBoardView(_ pluginBoardView: RCPluginBoardView!, clickedItemWithTag tag: Int) {
        
        switch tag {
        case 2001:
            let messageContent = RCDTestMessage.messageWithContent(content: "RCDTestMessage 测试消息")
            sendMessage(messageContent, pushContent: "测试消息")
        default:
            super.pluginBoardView(pluginBoardView, clickedItemWithTag: tag)
        }
        
    }
}


// MARK: - 修改头像以及修改已读样式
extension RCDConversationViewController {
    override func willDisplayMessageCell(_ cell: RCMessageBaseCell!, at indexPath: IndexPath!) {
        
//        let messageCell = cell as? RCMessageCell
        
        // 修改头像
        // 由于 Swift 无法直接获取到会话 Cell 和消息 Cell 的头像，利用 RCSwiftTool 类获取
//        let imageView = RCSwiftTool.getImageView(from: messageCell ?? RCMessageCell())
//        imageView.layer.masksToBounds = true
//        imageView.layer.cornerRadius = imageView.frame.width / 2
        
        
        // 修改已读样式
//        if let subviews = messageCell?.messageHasReadStatusView.subviews {
//            for subView in subviews {
//                subView.isHidden = true
//            }
//        }
//        let label = UILabel(frame: CGRect(x: -10, y: -5, width: 24, height: 12))
//        label.text = "已读"
//        label.clipsToBounds = true
//        label.layer.cornerRadius = 3
//        label.backgroundColor = UIColor.black.withAlphaComponent(0.3)
//        label.font = UIFont.systemFont(ofSize: 10)
//        messageCell?.messageHasReadStatusView.addSubview(label)
    }
}
