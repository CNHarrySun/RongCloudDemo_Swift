//
//  RCDTestMessage.swift
//  RCDemo_Swift
//
//  Created by 孙浩 on 2019/3/11.
//  Copyright © 2019 RongCloud. All rights reserved.
//

import UIKit

// Demo 测试用的自定义消息类
class RCDTestMessage: RCMessageContent, NSCoding {
    
    // 测试消息的类型名
    static let RCDTestMessageTypeIdentifier = "RCD:TstMsg"
    
    // 测试消息的内容
    var content: String = ""
    
    // 测试消息的附加信息
    var extra: String? = ""
    
    // 根据参数创建消息对象
    class func messageWithContent(content: String) -> RCDTestMessage {
        let testMessage = RCDTestMessage()
        testMessage.content = content
        return testMessage
    }
    
    // 返回消息的存储策略
    override class func persistentFlag() -> RCMessagePersistent {
        return RCMessagePersistent(rawValue: RCMessagePersistent.MessagePersistent_ISPERSISTED.rawValue | RCMessagePersistent.MessagePersistent_ISCOUNTED.rawValue) ?? RCMessagePersistent.MessagePersistent_ISCOUNTED
    }
    
    override init() {
        super.init()
    }
    
    // NSCoding
    required init(coder aDecoder: NSCoder) {
        super.init()
        content = aDecoder.decodeObject(forKey: "content") as? String ?? ""
        extra = aDecoder.decodeObject(forKey: "extra") as? String ?? ""
    }
    
    // NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(content, forKey: "content")
        aCoder.encode(extra, forKey: "extra")
    }
    
    // 序列化，将消息内容编码成 json
    override func encode() -> Data! {
        var dataDict: [String : Any] = [:]
        
        dataDict["content"] = content
        if let extra = extra {
            dataDict["extra"] = extra
        }
        
        if let senderUserInfo = senderUserInfo {
            dataDict["user"] = self.encode(senderUserInfo)
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: dataDict, options: .prettyPrinted)
            return data
        } catch {
            print(error)
            return Data()
        }
    }
    
    // 反序列化，解码生成可用的消息内容
    override func decode(with data: Data!) {
        do {
            let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String : Any]
            content = dictionary["content"] as? String ?? ""
            extra = dictionary["extra"] as? String ?? ""
            let userInfoDict = dictionary["user"] as? [String : Any] ?? [:]
            decodeUserInfo(userInfoDict)
        } catch {
            print(error)
        }
    }
    
    // 显示的消息内容摘要
    override func conversationDigest() -> String! {
        return content
    }
    
    // 返回消息的类型名
    override class func getObjectName() -> String! {
        return RCDTestMessageTypeIdentifier
    }
}
