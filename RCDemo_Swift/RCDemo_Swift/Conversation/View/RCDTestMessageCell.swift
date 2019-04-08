//
//  RCDTestMessageCell.swift
//  RCDemo_Swift
//
//  Created by 孙浩 on 2019/3/22.
//  Copyright © 2019 RongCloud. All rights reserved.
//

import UIKit

let textMessageFontSize: CGFloat = 16.0

class RCDTestMessageCell: RCMessageCell {

    // 消息显示的 label
    lazy var textLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.font = UIFont.systemFont(ofSize: textMessageFontSize)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .left
        label.textColor = .black
        label.isUserInteractionEnabled = true
        return label
    }()
    
    // 消息背景
    lazy var bubbleBackgroundView: UIImageView = {
        let imageView = UIImageView(frame: CGRect.zero)
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    // 自定义消息 Cell 的 Size
    override class func size(for model: RCMessageModel!, withCollectionViewWidth collectionViewWidth: CGFloat, referenceExtraHeight extraHeight: CGFloat) -> CGSize {
        
        let message = model.content as? RCDTestMessage
        let size = getBubbleBackgroundViewSize(message ?? RCDTestMessage.messageWithContent(content: ""))
        
        var messagecontentviewHeight = size.height;
        messagecontentviewHeight = messagecontentviewHeight + extraHeight;
        return CGSize(width: collectionViewWidth, height: messagecontentviewHeight)
    }
    
    override init!(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func initialize() {
        messageContentView.addSubview(bubbleBackgroundView)
        bubbleBackgroundView.addSubview(textLabel)
        
        // (UIApplication.registerUserNotificationSettings(_:))
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(_:)))
        bubbleBackgroundView.addGestureRecognizer(longPress)
        
        let textMessageTap = UITapGestureRecognizer(target: self, action: #selector(tapTextMessage(_:)))
        textMessageTap.numberOfTapsRequired = 1
        textMessageTap.numberOfTouchesRequired = 1
        textLabel.addGestureRecognizer(textMessageTap)
    }
    
    @objc private func longPressed(_ sender: UILongPressGestureRecognizer) {
        
    }
    
    @objc private func tapTextMessage(_ tap: UITapGestureRecognizer) {
        
        if let delegate = delegate {
            delegate.didTapMessageCell!(model)
        }
    }
    
    override func setDataModel(_ model: RCMessageModel!) {
        super.setDataModel(model)
        setAutoLayout()
    }
    
    private func setAutoLayout() {
        let testMessage = model.content as? RCDTestMessage
        textLabel.text = testMessage?.content
        
        let textLabelSize = RCDTestMessageCell.getTextLabelSize(testMessage ?? RCDTestMessage.messageWithContent(content: ""))
        let bubbleBackgroundViewSize = RCDTestMessageCell.getBubbleSize(textLabelSize)
        var messageContentViewRect = messageContentView.frame
        
        if RCMessageDirection.MessageDirection_RECEIVE == messageDirection {
            textLabel.frame = CGRect(x: 20, y: 7, width: textLabelSize.width, height: textLabelSize.height)
            
            messageContentViewRect.size.width = bubbleBackgroundViewSize.width
            messageContentView.frame = messageContentViewRect
            
            bubbleBackgroundView.frame = CGRect(x: 0, y: 0, width: bubbleBackgroundViewSize.width, height: bubbleBackgroundViewSize.height)
            let image = RCKitUtility.imageNamed("chat_from_bg_normal", ofBundle: "RongCloud.bundle")
            let imageHeigth = image?.size.height ?? 0
            let imageWidth = image?.size.width ?? 0
            bubbleBackgroundView.image = image?.resizableImage(withCapInsets: UIEdgeInsets(top: imageHeigth * 0.8, left: imageWidth * 0.8, bottom: imageHeigth * 0.2, right: imageWidth * 0.2))
        } else {
            textLabel.frame = CGRect(x: 12, y: 7, width: textLabelSize.width, height: textLabelSize.height)
            
            messageContentViewRect.size.width = bubbleBackgroundViewSize.width
            messageContentViewRect.size.height = bubbleBackgroundViewSize.height
            
            let portraitWidht = RCIM.shared().globalMessagePortraitSize.width
            messageContentViewRect.origin.x = baseContentView.bounds.size.width - (messageContentViewRect.size.width + CGFloat(HeadAndContentSpacing) + portraitWidht + 10)
            
            messageContentView.frame = messageContentViewRect
            
            bubbleBackgroundView.frame = CGRect(x: 0, y: 0, width: bubbleBackgroundViewSize.width, height: bubbleBackgroundViewSize.height)
            let image = RCKitUtility.imageNamed("chat_to_bg_normal", ofBundle: "RongCloud.bundle")
            let imageHeigth = image?.size.height ?? 0
            let imageWidth = image?.size.width ?? 0
            bubbleBackgroundView.image = image?.resizableImage(withCapInsets: UIEdgeInsets(top: imageHeigth * 0.8, left: imageWidth * 0.2, bottom: imageHeigth * 0.2, right: imageWidth * 0.8))
        }
        
    }
    
    private class func getTextLabelSize(_ message: RCDTestMessage) -> CGSize {
        let content = message.content
        if !content.isEmpty {
            let screenWidth = UIScreen.main.bounds.size.width
            let portraitWidth = RCIM.shared()?.globalMessagePortraitSize.width
            let portrait = (10 + (portraitWidth ?? 0.0) + 10) * 2
            let maxWidth = screenWidth - portrait - 5 - 35
                
                // Float(screenWidth - (10.0 + portraitWidth + 10.0) * 2 - 5 - 35)
            
            var textRect = (message.content).boundingRect(with: CGSize(width: maxWidth, height: 8000), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: textMessageFontSize)], context: nil)
            textRect.size.height = CGFloat(ceilf(Float(textRect.size.height)))
            textRect.size.width = CGFloat(ceilf(Float(textRect.size.width)))
            return CGSize(width: textRect.size.width + 5, height: textRect.size.height + 5)
        } else {
            return CGSize.zero
        }
    }
    
    private class func getBubbleSize(_ textLabelSize: CGSize) -> CGSize {
        var bubbleSize = CGSize(width: textLabelSize.width, height: textLabelSize.height)
        
        if bubbleSize.width + 12 + 20 > 50 {
            bubbleSize.width = bubbleSize.width + 12 + 20
        } else {
            bubbleSize.width = 50
        }
        
        if bubbleSize.height + 7 + 7 > 40 {
            bubbleSize.height = bubbleSize.height + 7 + 7
        } else {
            bubbleSize.height = 40
        }
        
        return bubbleSize
    }
    
    public class func getBubbleBackgroundViewSize(_ message: RCDTestMessage) -> CGSize {
        let textLabelSize = RCDTestMessageCell.getTextLabelSize(message)
        return RCDTestMessageCell.getBubbleSize(textLabelSize)
    }
    
}
