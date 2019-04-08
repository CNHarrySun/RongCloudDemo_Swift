//
//  RCDContactsListViewController.swift
//  RCDemo_Swift
//
//  Created by 孙浩 on 2019/3/13.
//  Copyright © 2019 RongCloud. All rights reserved.
//

import UIKit

class RCDContactsListViewController: UIViewController {

    static let contactListVCCellID = "contactListVCCellID"
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: self.view.bounds, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.separatorColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: RCDContactsListViewController.contactListVCCellID)
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.01))
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
    }
}

extension RCDContactsListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
 
        switch section {
        case 0:
            return RCDUserService.shared.contacts().count
        case 1:
            return RCDUserService.shared.groups().count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Contacts" : "Groups"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .value1, reuseIdentifier: RCDContactsListViewController.contactListVCCellID)
        cell.selectionStyle = .none
//        let cell = tableView.dequeueReusableCell(withIdentifier: RCDContactsListViewController.contactListVCCellID, for: indexPath)
        if indexPath.section == 0 {
            let userInfo = RCDUserService.shared.contacts()[indexPath.row]
            cell.imageView?.sd_setImage(with: URL(string: userInfo.portraitUri), placeholderImage: UIImage(named: "avatar_users_72px_1108447_easyicon.net"))
            cell.textLabel?.text = userInfo.name
            cell.detailTextLabel?.text = userInfo.userId
            if let currentUserInfo = RCIM.shared()?.currentUserInfo, userInfo.userId == currentUserInfo.userId {
                cell.detailTextLabel?.text = "自己"
            }
        } else {
            let groupInfo = RCDUserService.shared.groups()[indexPath.row]
            cell.imageView?.sd_setImage(with: URL(string: groupInfo.portraitUri), placeholderImage: UIImage(named: "avatar_users_72px_1108447_easyicon.net"))
            cell.textLabel?.text = groupInfo.groupName
            cell.detailTextLabel?.text = groupInfo.groupId
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let chatVC = RCDConversationViewController()
        
        if indexPath.section == 0 {
            let userInfo = RCDUserService.shared.contacts()[indexPath.row]
            if let currentUserInfo = RCIM.shared()?.currentUserInfo, userInfo.userId == currentUserInfo.userId {
                let alertView = UIAlertView(title: "提示", message: "不能和自己聊天", delegate: self, cancelButtonTitle: "OK")
                alertView.show()
                return
            }
            chatVC.conversationType = RCConversationType.ConversationType_PRIVATE
            chatVC.targetId = userInfo.userId
            chatVC.title = userInfo.name
        } else {
            let group = RCDUserService.shared.groups()[indexPath.row]
            chatVC.conversationType = RCConversationType.ConversationType_GROUP;
            chatVC.targetId = group.groupId;
            chatVC.title = group.groupName;
        }
        chatVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
}
