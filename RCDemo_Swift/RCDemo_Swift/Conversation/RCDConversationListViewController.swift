//
//  RCDConversationListViewController.swift
//  RCDemo_Swift
//
//  Created by 孙浩 on 2019/3/11.
//  Copyright © 2019 RongCloud. All rights reserved.
//

import UIKit

class RCDConversationListViewController: RCConversationListViewController {

    override func viewDidLoad() {
        // 重写显示相关的接口，必须先调用super，否则会屏蔽SDK默认的处理
        super.viewDidLoad()

        // 设置在列表中需要显示的会话类型
        setDisplayConversationTypes([
            RCConversationType.ConversationType_PRIVATE.rawValue,
            RCConversationType.ConversationType_DISCUSSION.rawValue,
            RCConversationType.ConversationType_CHATROOM.rawValue,
            RCConversationType.ConversationType_GROUP.rawValue,
            RCConversationType.ConversationType_APPSERVICE.rawValue,
            RCConversationType.ConversationType_SYSTEM.rawValue
            ])
        
        // 设置需要将哪些类型的会话在会话列表中聚合显示
//        setCollectionConversationType([
//            RCConversationType.ConversationType_DISCUSSION.rawValue,
//            RCConversationType.ConversationType_GROUP.rawValue
//            ])
        
       
        let rightBarButton = UIBarButtonItem(title: "退出", style: .plain, target: self, action: #selector(logout))
        rightBarButton.tintColor = UIColor.blue
        navigationItem.rightBarButtonItem = rightBarButton
        
    }
    
    // 修改头像显示
//    override func willDisplayConversationTableCell(_ cell: RCConversationBaseCell!, at indexPath: IndexPath!) {
//        let conversationCell = cell as? RCConversationCell
//        let imageView = RCSwiftTool.getImageView(from: conversationCell ?? RCConversationCell())
//        imageView.layer.masksToBounds = true
//        imageView.layer.cornerRadius = imageView.frame.width / 2
//    }
    
    override func onSelectedTableRow(_ conversationModelType: RCConversationModelType, conversationModel model: RCConversationModel!, at indexPath: IndexPath!) {
        
        let conversationVC = RCDConversationViewController()
        conversationVC.conversationType = model.conversationType
        conversationVC.targetId = model.targetId
        conversationVC.title = model.conversationTitle
        conversationVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(conversationVC, animated: true)
    }
    
    @objc func logout() {
        // 退出
        RCIM.shared()?.logout()
        
        let loginNav = UINavigationController(rootViewController: RCDLoginViewController())
        present(loginNav, animated: true, completion: nil)
        print("退出登录")
    }
}
