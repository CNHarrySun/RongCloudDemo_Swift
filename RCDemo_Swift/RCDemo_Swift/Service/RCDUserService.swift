//
//  UserService.swift
//  RCDemo_Swift
//
//  Created by 孙浩 on 2019/3/11.
//  Copyright © 2019 RongCloud. All rights reserved.
//

import UIKit

class RCDUserService: NSObject {
    
    static let shared = RCDUserService()
    
    func contacts() -> Array<RCUserInfo> {
        
        var userArray: [RCUserInfo] = []
        let portrait = ["https://www.kuk8.com/uploads/allimg/170916/1-1F91214235H54.jpg","https://www.toux8.com/uploads/allimg/180130/041I453U-0.jpg", "https://pic.qqtn.com/up/2018-5/15252271245423063.jpg"]
        let idArray = ["ceshi1", "ceshi2", "ceshi3"]
        let nameArray = ["测试1", "测试2", "测试3"]
        for (i, id) in idArray.enumerated() {
            let user = RCUserInfo(userId: id, name: nameArray[i], portrait: portrait[i])
            userArray.append(user ?? RCUserInfo())
        }
        return userArray
    }
    
    func groups() -> Array<RCGroup> {
        
        var groupArray: [RCGroup] = []
        let portrait = "https://www.kuk8.com/uploads/allimg/170916/1-1F91214235H54.jpg"
        let idArray = ["123456"]
        let nameArray = ["测试群组1"]
        for (i, id) in idArray.enumerated() {
            let group = RCGroup(groupId: id, groupName: nameArray[i], portraitUri: portrait)
            groupArray.append(group ?? RCGroup())
        }
        return groupArray
    }
}

extension RCDUserService: RCIMUserInfoDataSource {
    func getUserInfo(withUserId userId: String!, completion: ((RCUserInfo?) -> Void)!) {
        for userInfo in self.contacts() {
            if userInfo.userId == userId {
                completion(userInfo)
            }
        }
    }
}

extension RCDUserService: RCIMGroupInfoDataSource {
    func getGroupInfo(withGroupId groupId: String!, completion: ((RCGroup?) -> Void)!) {
        for group in self.groups() {
            if group.groupId == groupId {
                completion(group)
            }
        }
    }
}

extension RCDUserService: RCIMGroupMemberDataSource {
    func getAllMembers(ofGroup groupId: String!, result resultBlock: (([String]?) -> Void)!) {
        let array = ["ceshi1", "ceshi2", "ceshi3"]
        resultBlock(array)
    }
}

