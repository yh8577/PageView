//
//  ViewController.swift
//  HHPageView
//
//  Created by yihui on 2017/11/15.
//  Copyright © 2017年 yihui. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 禁用掉自动设置的内边距
        automaticallyAdjustsScrollViewInsets = false
        
        // 1.标题
//        let titles = ["游戏","娱乐","趣玩","新闻","视频"]
        let titles = ["游戏","娱乐","趣视频视频玩","新视闻","视频","趣视频视频玩","新视频闻","视频","趣视频玩","新闻","视视频视频视频频"]
        let style = HHTitleStyle()
        // 是否滚动
//        style.isScrollEnable = true
        // 是否显示滚动条
        style.isShowScrollLine = true
        
        // 2.所有的自控制器
        var childVcs = [UIViewController]()
        for _ in 0..<titles.count {
            let vc = UIViewController()
            vc.view.backgroundColor = UIColor.randomColor()
            childVcs.append(vc)
        }
        
        // 3.PageView的frame
        let pageFrame = CGRect(x: 0, y: 64, width: view.bounds.width, height: view.bounds.height - 64)
        
        // 4.创建并添加子控制器
        let pageView = HHPageView(frame: pageFrame, titles: titles, childVcs: childVcs, parentVc: self, style : style)
        
        view.addSubview(pageView)
    
    }

  


}

