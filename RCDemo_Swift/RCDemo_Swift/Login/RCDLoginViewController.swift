//
//  RCDLoginViewController.swift
//  RCDemo_Swift
//
//  Created by 孙浩 on 2019/3/13.
//  Copyright © 2019 RongCloud. All rights reserved.
//

import UIKit

class RCDLoginViewController: UIViewController {

    static let loginCellID = "loginCellID"
    
    // 使用时建议修改 tokenArray 和 AppDelegate 中的 appKey
    let tokenArray: [String] = [
        "LyNrhRcNvEoZyhWKSytkuLqaWRw6IZ1fAWHoOwniB4RtU7QCUjb3mGXCubS40wBWmtnvp/8wliFEerY9Kg2ENg==",
        "sSk67DwhaMadLfNuO+OHV7qaWRw6IZ1fAWHoOwniB4RtU7QCUjb3mFO0P6NyFgN50w2giayfgwfTR7MSLt523w==",
        "LlSwOuFDmX69fDGwKwMN0LqaWRw6IZ1fAWHoOwniB4RtU7QCUjb3mLEq1j+tFisXjFg0Pr0NXGY/uvYMJumnaw=="
    ]
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: self.view.bounds, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.separatorColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: RCDLoginViewController.loginCellID)
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.01))
        return tableView
    }()
    
    lazy var progressHUD: MBProgressHUD = {
        let hud = MBProgressHUD(for: view)
        return hud ?? MBProgressHUD()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "选择账号"
        view.addSubview(tableView)
        tableView.addSubview(progressHUD)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loginSuccess), name: .LoginSuccess, object: nil)
    }
}

extension RCDLoginViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RCDUserService.shared.contacts().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .value1, reuseIdentifier: RCDLoginViewController.loginCellID)
        
        let userInfo = RCDUserService.shared.contacts()[indexPath.row]
        cell.imageView?.sd_setImage(with: URL(string: userInfo.portraitUri), placeholderImage: UIImage(named: "avatar_users_72px_1108447_easyicon.net"))
        cell.textLabel?.text = userInfo.name
        cell.detailTextLabel?.text = userInfo.userId
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        progressHUD.show(animated: true)
        // 连接服务器
        RCIM.shared()?.connect(withToken: tokenArray[indexPath.row], success: { (userId) in
            RCDUserService.shared.getUserInfo(withUserId: userId, completion: { (userInfo) in
                DispatchQueue.main.async {
                    self.progressHUD.hide(animated: true)
                }
                // 设置当前的用户
                RCIM.shared()?.currentUserInfo = userInfo
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .LoginSuccess, object: nil)
                }
                print("登陆成功。当前登录的用户ID：\(String(describing: userId))")
            })
        }, error: { (status) in
            print("登录的错误码为：\(status)")
        }, tokenIncorrect: {
            // token 过期或者不正确。
            // 如果设置了 token 有效期并且 token 过期，请重新请求您的服务器获取新的 token
            // 如果没有设置 token 有效期却提示 token 错误，请检查您客户端和服务器的 appkey 是否匹配，还有检查您获取 token 的流程。
            DispatchQueue.main.async {
                self.progressHUD.hide(animated: true)
            }
            print("token 错误")
        })
    }
    
    @objc func loginSuccess() {
        progressHUD.hide(animated: true)
        dismiss(animated: true, completion: nil)
    }
}
