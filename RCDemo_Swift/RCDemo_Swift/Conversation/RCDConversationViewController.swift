//
//  RCDConversationViewController.swift
//  RCDemo_Swift
//
//  Created by 孙浩 on 2019/3/13.
//  Copyright © 2019 RongCloud. All rights reserved.
//

import UIKit

class RCDConversationViewController: RCConversationViewController, RCRealTimeLocationObserver, RealTimeLocationStatusViewDelegate {
    
    weak var realTimeLocation: RCRealTimeLocationProxy?
    lazy var realTimeLocationStatusView: RealTimeLocationStatusView = {
        let statusView = RealTimeLocationStatusView(frame: CGRect(x: 0, y: 62, width: view.frame.size.width, height: 0))
        statusView.delegate = self
        view.addSubview(statusView)
        return statusView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatSessionInputBarControl.pluginBoardView.insertItem(with: UIImage(named: "urlPic"), title: "测试消息", tag: 2001)
        /*!
         注册自定义消息的Cell
         
         @param cellClass     自定义消息cell的类
         @param messageClass  自定义消息Cell对应的自定义消息的类，该自定义消息需要继承于RCMessageContent
         
         @discussion
         你需要在cell中重写RCMessageBaseCell基类的sizeForMessageModel:withCollectionViewWidth:referenceExtraHeight:来计算cell的高度。
         */
        self.register(RCDTestMessageCell.self, forMessageClass: RCDTestMessage.self)
        
        
        /*******************实时地理位置共享***************/
        register(RealTimeLocationStartCell.self, forMessageClass: RCRealTimeLocationStartMessage.self)
        register(RealTimeLocationEndCell.self, forMessageClass: RCRealTimeLocationEndMessage.self)
        
        RCRealTimeLocationManager.shared()?.getRealTimeLocationProxy(conversationType, targetId: targetId, success: { [weak self] (realTimeLocation) in
            guard let `self` = self else { return }
            self.realTimeLocation = realTimeLocation
            self.realTimeLocation?.add(self)
            self.updateRealTimeLocationStatus()
            }, error: { (status) in
                print("get location share failure with code \(status)")
        })
        /*******************实时地理位置共享***************/
        
        
        if conversationType != RCConversationType.ConversationType_APPSERVICE && conversationType != RCConversationType.ConversationType_PUBLICSERVICE {
            let imageFile = RCKitUtility.imageNamed("actionbar_file_icon", ofBundle: "RongCloud.bundle")
            let pluginBoardView = chatSessionInputBarControl.pluginBoardView
            pluginBoardView?.insertItem(with: imageFile, title: "File", at: 3, tag: Int(PLUGIN_BOARD_ITEM_FILE_TAG))
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var frame = realTimeLocationStatusView.frame
        frame.size.width = view.bounds.size.width
        realTimeLocationStatusView.frame = frame
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 设置输入框的默认输入模式
        //        defaultInputType = RCChatSessionInputBarInputType.voice
        
        // 设置公众号
        //        chatSessionInputBarControl.setInputBarType(RCChatSessionInputBarControlType.pubType, style: RCChatSessionInputBarControlStyle.CHAT_INPUT_BAR_STYLE_SWITCH_CONTAINER_EXTENTION)
        //        let speatItem = RCPublicServiceMenuItem()
        //        speatItem.name = "开始发言"
        //        speatItem.type = RCPublicServiceMenuItemType.PUBLIC_SERVICE_MENU_ITEM_VIEW
        //        speatItem.url = "www.rongcloud.cn"
        //        let menu = RCPublicServiceMenu()
        //        menu.menuItems = [speatItem]
        //        chatSessionInputBarControl.publicServiceMenu = menu
    }
    
    // 修改已读样式
    override func willDisplayMessageCell(_ cell: RCMessageBaseCell!, at indexPath: IndexPath!) {
        
        let messageCell = cell as? RCMessageCell
        
        // 修改头像
//        let imageView = RCSwiftTool.getImageView(from: messageCell ?? RCMessageCell())
//        imageView.layer.masksToBounds = true
//        imageView.layer.cornerRadius = imageView.frame.width / 2
        
        if let subviews = messageCell?.messageHasReadStatusView.subviews {
            for subView in subviews {
                subView.isHidden = true
            }
        }
        let label = UILabel(frame: CGRect(x: -10, y: -5, width: 24, height: 12))
        label.text = "已读"
        label.clipsToBounds = true
        label.layer.cornerRadius = 3
        label.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        label.font = UIFont.systemFont(ofSize: 10)
        messageCell?.messageHasReadStatusView.addSubview(label)
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
            
            if content.isKind(of: RCRealTimeLocationStartMessage.self) {
                showRealTimeLocationViewController()
                print("跳转实时位置共享")
            } else if content.isKind(of: RCContactCardMessage.self) {
                
                let cardMsg = content as? RCContactCardMessage
                let user = RCUserInfo(userId: cardMsg?.userId, name: cardMsg?.name, portrait: cardMsg?.portraitUri)
                let alertView = UIAlertView(title: "名片消息", message: "userId = \(String(describing: user?.userId)), name = \(String(describing: user?.name))，portraitUrl = \(String(describing: user?.portraitUri))", delegate: self, cancelButtonTitle: "OK")
                alertView.show()
            } else if content.isKind(of: RCDTestMessage.self) {
                let alertView = UIAlertView(title: "RCDTestMessage", message: "RCDTestMessage 测试消息", delegate: self, cancelButtonTitle: "OK")
                alertView.show()
            }
        }
    }
    
    override func pluginBoardView(_ pluginBoardView: RCPluginBoardView!, clickedItemWithTag tag: Int) {
        
        switch tag {
        case Int(PLUGIN_BOARD_ITEM_LOCATION_TAG):
            if realTimeLocation != nil {
                let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "cancel", destructiveButtonTitle: nil, otherButtonTitles: "发送位置", "位置实时共享")
                actionSheet.show(in: view)
            }
        case 2001:
            let messageContent = RCDTestMessage.messageWithContent(content: "RCDTestMessage 测试消息")
            sendMessage(messageContent, pushContent: "测试消息")
        default:
            super.pluginBoardView(pluginBoardView, clickedItemWithTag: tag)
        }
        
    }
    
    // 图片上传至自己的服务器
    override func uploadMedia(_ message: RCMessage!, uploadListener: RCUploadMediaStatusListener!) {
        DispatchQueue.global().async {
            // 这里是模仿图片、文件上传的过程
            var isSuccess = false
            for i in 0..<100 {
                uploadListener.updateBlock(Int32(i))
                Thread.sleep(forTimeInterval: 0.2)
                isSuccess = true
            }
            
            if isSuccess {
                uploadListener.successBlock(RCImageMessage())
            } else {
                uploadListener.errorBlock(RCErrorCode.ERRORCODE_UNKNOWN)
            }
        }
    }
    
    /*******************实时地理位置共享***************/
    // RealTimeLocationStatusViewDelegate
    func onJoin() {
        showRealTimeLocationViewController()
    }
    
    func onShowRealTimeLocationView() {
        showRealTimeLocationViewController()
    }
    
    func getStatus() -> RCRealTimeLocationStatus {
        return realTimeLocation?.getStatus() ?? RCRealTimeLocationStatus.REAL_TIME_LOCATION_STATUS_IDLE
    }
    
    // RCRealTimeLocationObserver
    func onRealTimeLocationStatusChange(_ status: RCRealTimeLocationStatus) {
        DispatchQueue.main.async { [weak self] in
            self?.updateRealTimeLocationStatus()
        }
    }
    
    func onReceive(_ location: CLLocation!, type: RCRealTimeLocationType, fromUserId userId: String!) {
        DispatchQueue.main.async { [weak self] in
            self?.updateRealTimeLocationStatus()
        }
    }
    
    func onParticipantsJoin(_ userId: String!) {
        if let currentUserInfo = RCIMClient.shared()?.currentUserInfo, userId == currentUserInfo.userId {
            notifyParticipantChange(text: "你退出地理位置共享")
        } else {
            RCIM.shared()?.userInfoDataSource.getUserInfo(withUserId: userId, completion: { [weak self] (userInfo) in
                if let name = userInfo?.name, !name.isEmpty {
                    self?.notifyParticipantChange(text: "\(name)退出地理位置共享")
                } else {
                    self?.notifyParticipantChange(text: "user<\(String(describing: userId))>退出地理位置共享")
                }
            })
        }
    }
    
    func onStartRealTimeLocationFailed(_ messageId: Int) {
        DispatchQueue.main.async { [weak self] in
            
            if let conversationDataRepository = self?.conversationDataRepository {
                for model in conversationDataRepository {
                    if let model = model as? RCMessageModel, model.messageId == messageId {
                        model.sentStatus = RCSentStatus.SentStatus_FAILED
                    }
                }
                
                if let visibleItem = self?.conversationMessageCollectionView.indexPathsForVisibleItems {
                    for indexPath in visibleItem {
                        let model = conversationDataRepository[indexPath.row] as? RCMessageModel
                        if model?.messageId == messageId {
                            self?.conversationMessageCollectionView.reloadItems(at: [indexPath])
                        }
                    }
                }
            }
        }
    }
    
    func notifyParticipantChange(text: String) {
        DispatchQueue.main.async { [weak self] in
            self?.realTimeLocationStatusView.updateText(text)
            self?.perform(#selector(self?.updateRealTimeLocationStatus), with: nil, afterDelay: 0.5)
        }
    }
    
    func onUpdateLocationFailed(_ description: String!) {
    }
    
    
    func showRealTimeLocationViewController() {
        
        let locationVC = RealTimeLocationViewController()
        locationVC.realTimeLocationProxy = realTimeLocation
        if realTimeLocation?.getStatus() == RCRealTimeLocationStatus.REAL_TIME_LOCATION_STATUS_INCOMING {
            realTimeLocation?.joinRealTimeLocation()
        } else if realTimeLocation?.getStatus() == RCRealTimeLocationStatus.REAL_TIME_LOCATION_STATUS_IDLE {
            realTimeLocation?.startRealTimeLocation()
        }
        navigationController?.present(locationVC, animated: true, completion: nil)
    }
    
    @objc func updateRealTimeLocationStatus() {
        if let realTimeLocation = realTimeLocation {
            realTimeLocationStatusView.updateRealTimeLocationStatus()
            var participants: Array<String>? = []
            switch realTimeLocation.getStatus() {
            case .REAL_TIME_LOCATION_STATUS_OUTGOING:
                self.realTimeLocationStatusView.updateText("你正在共享位置")
            case .REAL_TIME_LOCATION_STATUS_CONNECTED, .REAL_TIME_LOCATION_STATUS_INCOMING:
                participants = self.realTimeLocation?.getParticipants() as? Array<String>
                
                if participants?.count == 1 {
                    let userId = participants?[0]
                    self.realTimeLocationStatusView.updateText("user<\(String(describing: userId))>正在共享位置")
                    RCIM.shared()?.userInfoDataSource.getUserInfo(withUserId: userId, completion: { [weak self] (userInfo) in
                        if !(userInfo?.name.isEmpty)! {
                            DispatchQueue.main.async {
                                self?.realTimeLocationStatusView.updateText("\(String(describing: userInfo?.name))正在共享位置")
                            }
                        }
                    })
                } else {
                    if participants?.count ?? 0 < 0 {
                        realTimeLocationStatusView.removeFromSuperview()
                    } else {
                        realTimeLocationStatusView.updateText("\(String(describing: participants?.count))人正在共享地理位置")
                    }
                }
            default:
                break
            }
        }
    }
}

// UIAlertViewDelegate
extension RCDConversationViewController: UIAlertViewDelegate, UIActionSheetDelegate {
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        switch buttonIndex {
        case 1:
            super.pluginBoardView(chatSessionInputBarControl.pluginBoardView, clickedItemWithTag: Int(PLUGIN_BOARD_ITEM_LOCATION_TAG))
        case 2:
            showRealTimeLocationViewController()
        default:
            break
        }
    }
}
