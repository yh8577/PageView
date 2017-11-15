//
//  HHPageView.swift
//  HHPageView
//
//  Created by yihui on 2017/11/15.
//  Copyright © 2017年 yihui. All rights reserved.
//

import UIKit

class HHPageView: UIView {

    
    fileprivate var titles : [String]
    fileprivate var childVcs : [UIViewController]
    fileprivate var parentVc : UIViewController
    fileprivate var style : HHTitleStyle
    fileprivate var titleView : HHTitleView!

    init(frame: CGRect, titles: [String], childVcs: [UIViewController], parentVc: UIViewController, style: HHTitleStyle) {
        
        self.titles = titles
        self.childVcs = childVcs
        self.parentVc = parentVc
        self.style = style
        
        super.init(frame: frame)
        
        setupUI()
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

//MARK: --设置UI界面
extension HHPageView {
    
    fileprivate func setupUI(){
        setupTitleView()
        setupContentView()
    }
    
    private func setupTitleView() {
        
        let titleFrame = CGRect(x: 0, y: 0, width: bounds.width, height: style.titleHeight)
        titleView = HHTitleView(frame: titleFrame, titles: titles, style: style)
        addSubview(titleView)
        
        titleView.backgroundColor = UIColor.randomColor()
    }
    
    private func setupContentView() {
        
        let contentFrame = CGRect(x: 0, y: style.titleHeight, width: bounds.width, height: bounds.height - style.titleHeight)
        
        let contentView = HHContentView(frame: contentFrame, childVcs: childVcs, parentvc: parentVc)
        
        addSubview(contentView)
        
        contentView.backgroundColor = UIColor.randomColor()
        
        // 让contentView&&titleView代理
        titleView.delegate = contentView
        contentView.delegate = titleView
        
    }
    
}
































































