//
//  MainTabBarController.swift
//  RCDemo_Swift
//
//  Created by 孙浩 on 2019/3/13.
//  Copyright © 2019 RongCloud. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let conversationListVC = RCDConversationListViewController()
        let conversationListNav = UINavigationController(rootViewController: conversationListVC)
        conversationListVC.title = "消息"
        conversationListNav.tabBarItem.image = UIImage(named: "消息")
        
        let contactsListVC = RCDContactsListViewController()
        let contactsListNav = UINavigationController(rootViewController: contactsListVC)
        contactsListVC.title = "联系人"
        contactsListNav.tabBarItem.image = UIImage(named: "联系人")
        
        viewControllers = [conversationListNav, contactsListNav]
    }
}
