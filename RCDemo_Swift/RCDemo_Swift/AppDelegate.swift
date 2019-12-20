//
//  AppDelegate.swift
//  RCDemo_Swift
//
//  Created by 孙浩 on 2019/2/25.
//  Copyright © 2019 RongCloud. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    // 使用时建议修改 appKey 和 RCDLoginViewController 中的 tokenArray
    static let appKey = "pwe86ga5p44p6"
    
    lazy var mainTabbarVC: MainTabBarController = {
        let vc = MainTabBarController()
        return vc
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        window?.makeKeyAndVisible()
        window?.rootViewController = mainTabbarVC
        
        // fix：tabbar 的 item 偏移错乱
        UITabBar.appearance().isTranslucent = false
        
        showLoginVC()
        
        configRCSDK()
        
        // 推送处理 1
        registerUserNotification()
        
        // 统计推送打开率 1
        RCIMClient.shared()?.recordLaunchOptionsEvent(launchOptions)
        
        // 获取融云推送服务扩展字段 1
        if let pushServiceData = RCIMClient.shared()?.getPushExtra(fromLaunchOptions: launchOptions) {
            print("该启动事件包含来自融云的推送服务")
            for key in pushServiceData.keys {
                print(pushServiceData[key] ?? "")
            }
        } else {
            print("该启动事件不包含来自融云的推送服务")
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveMessageNotification), name: .RCKitDispatchMessage, object: nil)
        
        return true
    }
    
    func configRCSDK() {
        
        // 初始化 SDK
        RCIM.shared()?.initWithAppKey(AppDelegate.appKey)
        
//        RCIM.shared()?.connect(withToken: "YourTestUserToken", success: { (userId) in
//            print("登陆成功。当前登录的用户ID：\(String(describing: userId))")
//        }, error: { (status) in
//            print("登陆的错误码为：\(status)")
//        }, tokenIncorrect: {
//            // token过期或者不正确。
//            // 如果设置了token有效期并且token过期，请重新请求您的服务器获取新的token
//            // 如果没有设置token有效期却提示token错误，请检查您客户端和服务器的appkey是否匹配，还有检查您获取token的流程。
//            print("token错误")
//        })
        
        // 设置导航按钮字体颜色
        RCIM.shared()?.globalNavigationBarTintColor = .blue;

        // 注册自定义消息
        RCIM.shared()?.registerMessageType(RCDTestMessage.self)

        // IMKit连接状态的监听器
        RCIM.shared()?.connectionStatusDelegate = self

        // SDK 会话列表界面中显示的头像大小，高度必须大于或者等于36
        RCIM.shared()?.globalConversationPortraitSize = CGSize(width: 46, height: 46)

        // 开启用户信息和群组信息的持久化
//        RCIM.shared()?.enablePersistentUserInfoCache = true

        // 设置用户信息源和群组信息源
        RCIM.shared()?.userInfoDataSource = RCDUserService.shared
        RCIM.shared()?.groupInfoDataSource = RCDUserService.shared
        RCIM.shared()?.groupMemberDataSource = RCDUserService.shared

        // 设置接收消息代理
        RCIM.shared()?.receiveMessageDelegate = self

        // 开启输入状态监听
        RCIM.shared()?.enableTypingStatus = true

        // 开启发送已读回执
        RCIM.shared()?.enabledReadReceiptConversationTypeList = [RCConversationType.ConversationType_PRIVATE.rawValue, RCConversationType.ConversationType_DISCUSSION.rawValue, RCConversationType.ConversationType_GROUP.rawValue]

        // 开启多端未读状态同步
        RCIM.shared()?.enableSyncReadStatus = true

        // 设置显示未注册的消息
        // 如：新版本增加了某种自定义消息，但是老版本不能识别，开发者可以在旧版本中预先自定义这种未识别的消息的显示
        RCIM.shared()?.showUnkownMessage = true
        RCIM.shared()?.showUnkownMessageNotificaiton = true

        // 开启消息 @ 功能（只支持群聊和讨论组，App 需要实现群成员数据源 groupMemberDataSource）
        RCIM.shared()?.enableMessageMentioned = true

        // 开启消息撤回功能
        RCIM.shared()?.enableMessageRecall = true

        // 选择媒体资源时，包含视频文件
        RCIM.shared()?.isMediaSelectorContainVideo = true

        // 设置头像为圆形
//        RCIM.shared()?.globalMessageAvatarStyle = RCUserAvatarStyle.USER_AVATAR_CYCLE
//        RCIM.shared()?.globalConversationAvatarStyle = RCUserAvatarStyle.USER_AVATAR_CYCLE

        // 设置优先使用 WebView 打开 URL
//        RCIM.shared()?.embeddedWebViewPreferred = true

        // 设置通话视频分辨率
//        RCCallClient.shared()?.setVideoProfile(RCVideoProfile._VIDEO_PROFILE_480P)

        // 设置 Log 级别，开发阶段打印详细 log
        RCIMClient.shared()?.logLevel = RCLogLevel.log_Level_Info

        // 设置断线重连时是否踢出重连设备
        RCIMClient.shared()?.setReconnectKickEnable(true)
        
        // 重定向 log 到本地问题
//        redirectNSlogToDocumentFolder()
    }
    
    func registerUserNotification() {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { (_, _) in })
            center.delegate = self
        } else {
            let settings = UIUserNotificationSettings(types: [.alert, .sound, .badge], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    
    @objc func didReceiveMessageNotification(notification: NSNotification) {
        let left = notification.userInfo?["left"] as? NSNumber ?? 0
        if (RCIMClient.shared()?.sdkRunningMode == RCSDKRunningMode.background && 0 == left.intValue) {
            let unreadMsgCount = RCIMClient.shared()?.getUnreadCount([RCConversationType.ConversationType_PRIVATE, RCConversationType.ConversationType_DISCUSSION, RCConversationType.ConversationType_PUBLICSERVICE, RCConversationType.ConversationType_GROUP])
            let unreadMsgNumber = NSNumber(value: unreadMsgCount ?? 0)
            
            DispatchQueue.main.async {
                UIApplication.shared.applicationIconBadgeNumber = unreadMsgNumber.intValue
            }
        }
    }
    
    // 当App处于前台时，接收到消息并播放提示音的回调方法
    func onRCIMCustomAlertSound(_ message: RCMessage!) -> Bool {
        // 设置群组通知消息没有提示音
        if let content = message.content {
            if content.isMember(of: RCGroupNotificationMessage.self) {
                return true
            }
        }
        return false
    }
    
    // log 重定向
    func redirectNSlogToDocumentFolder() {
        print("Log 重定向到本地，如果您需要控制台Log，注释掉重定向逻辑即可。")
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectory = paths[0]
        let currentDate = Date()
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "MMddHHmmss"
        let formatterDate = dateformatter.string(from: currentDate)
        
        let fileName = "rc\(formatterDate).log"
        let logFilePath = documentDirectory.appending("/\(fileName)")
        freopen(logFilePath.cString(using: .ascii), "a+", stdout)
        freopen(logFilePath.cString(using: .ascii), "a+", stderr);
    }
    
    func showLoginVC() {
        let vc = UINavigationController(rootViewController: RCDLoginViewController())
        mainTabbarVC.present(vc, animated: true, completion: nil)
        mainTabbarVC.selectedIndex = 0
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

// MARK: - 通知相关
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        
        // 统计推送打开率 3
        RCIMClient.shared()?.recordLocalNotificationEvent(notification)
    }
    
    // 推送处理 2
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        application.registerForRemoteNotifications()
    }
    
    // 推送处理 3
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        RCIMClient.shared()?.setDeviceTokenData(deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("获取 DeviceToken 失败！！！")
        print("ERROR：\(error)")
    }
    
    // 推送处理 4
    // userInfo 内容请参考官网文档
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        // 处理推送
        getPushExtra(userInfo)
    }

    // iOS10 新增：处理后台点击通知的代理方法
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        // 处理推送
        getPushExtra(userInfo)
    }

    // iOS10 新增：处理前台收到通知的代理方法
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    // 统计推送打开率，获取融云推送服务扩展字段
    func getPushExtra(_ userInfo: [AnyHashable : Any]) {
        // 统计推送打开率 2
        RCIMClient.shared()?.recordRemoteNotificationEvent(userInfo)
        
        // 获取融云推送服务扩展字段 2
        if let pushServiceData = RCIMClient.shared()?.getPushExtra(fromRemoteNotification: userInfo) {
            print("该远程推送包含来自融云的推送服务")
            for key in pushServiceData.keys {
                print("key = \(key), value = \(String(describing: pushServiceData[key]))")
            }
        } else {
            print("该远程推送不包含来自融云的推送服务")
        }
    }
}

// MARK: - RCIMConnectionStatusDelegate IMKit 连接状态的监听器
extension AppDelegate: RCIMConnectionStatusDelegate {
    func onRCIMConnectionStatusChanged(_ status: RCConnectionStatus) {
        
        DispatchQueue.main.async {
            switch status {
            case .ConnectionStatus_Connected:
                NotificationCenter.default.post(name: .LoginSuccess, object: nil)
                RCIM.shared()?.userInfoDataSource = RCDUserService.shared
            default:
                print("RCConnectErrorCode is\(status)")
            }
        }
        
        if status == RCConnectionStatus.ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT {
            
            showLoginVC()
            
            let alertView = UIAlertView(title: "提示", message: "您的帐号在别的设备上登录，您被迫下线！", delegate: self, cancelButtonTitle: "OK")
            alertView.show()
        }
    }
    
}


// MARK: - RCIMReceiveMessageDelegate
extension AppDelegate: RCIMReceiveMessageDelegate {
    // 接收消息的回调方法
    func onRCIMReceive(_ message: RCMessage!, left: Int32) {
        print("接收消息的回调方法")
    }
    
}
