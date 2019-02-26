//
//  SHMessageCell.swift
//  RCDemo_Swift
//
//  Created by 孙浩 on 2019/2/25.
//  Copyright © 2019 HarrySun. All rights reserved.
//

import UIKit

class SHMessageCell: RCMessageBaseCell {
    
    
    override class func size(for model: RCMessageModel!, withCollectionViewWidth collectionViewWidth: CGFloat, referenceExtraHeight extraHeight: CGFloat) -> CGSize {
        
        return CGSize(width: 10, height: 10)
    }
    
    override func setDataModel(_ model: RCMessageModel!) {
        
    }
}
