//
//  HHContentView.swift
//  HHPageView
//
//  Created by yihui on 2017/11/15.
//  Copyright © 2017年 yihui. All rights reserved.
//

import UIKit

private let hContentCellID = "hContentCellID"

protocol HHContentViewDelegate : class {
    func contentView(_ contentView : HHContentView, targetIndex : Int)
    func contentView(_ contentView : HHContentView, targetIndex : Int, progress : CGFloat)
    
}

class HHContentView: UIView {
    
    weak var delegate : HHContentViewDelegate?

    fileprivate var childVcs : [UIViewController]
    fileprivate var parentvc : UIViewController
    fileprivate var startOffsetX : CGFloat = 0
    var isForbidScroll : Bool = false
    
    fileprivate lazy var collectionView : UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = self.bounds.size
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: hContentCellID)
        collectionView.isPagingEnabled = true
        collectionView.bounces = false
        collectionView.scrollsToTop = false
        collectionView.showsHorizontalScrollIndicator = false
        
        return collectionView
    }()
    
    init(frame : CGRect, childVcs : [UIViewController], parentvc : UIViewController) {
        
        self.childVcs = childVcs
        self.parentvc = parentvc
        
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension HHContentView {
    fileprivate func setupUI() {
        
        // 1.将所有子控制器添加到父控制器中
        for childVc in childVcs {
            parentvc.addChildViewController(childVc)
        }
        
        // 2.添加UICollectionView用于展示内容
        addSubview(collectionView)
        
    }
}

//MARK: -- UICollectionViewDataSource
extension HHContentView : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return childVcs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: hContentCellID, for: indexPath)
        
        for subView in cell.contentView.subviews {
            subView.removeFromSuperview()
        }
        
        let childVc = childVcs[indexPath.item]
        childVc.view.frame = cell.contentView.bounds
        cell.contentView.addSubview(childVc.view)
        
        return cell
    }
}

//MARK: -- UICollectionViewDelegate
extension HHContentView : UICollectionViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        contentEndScroll()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if !decelerate {
            contentEndScroll()
        }
    }
    
    private func contentEndScroll() {

        // 1.获取滚动的位置
        let currentIndex = Int(collectionView.contentOffset.x / collectionView.bounds.width)
        
        // 2.通知titleView
        delegate?.contentView(self, targetIndex: currentIndex)
    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        startOffsetX = scrollView.contentOffset.x
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        
        // 1.判断和开始时的偏移量是否一致 , 判断是否是禁止滚动
        guard startOffsetX != scrollView.contentOffset.x, !isForbidScroll else {
            return
        }

        // 1.定义targetIndex/progress
        var targetIndex = 0
        var progress : CGFloat = 0.0
        
        // 2.给targetIndex/progress赋值
        let currentIndex = Int(startOffsetX / scrollView.bounds.width)
        if startOffsetX < scrollView.contentOffset.x { // 向左边滑动
            targetIndex = currentIndex + 1
            
            if targetIndex > childVcs.count - 1 {
                targetIndex = childVcs.count - 1
            }
            
            progress = (scrollView.contentOffset.x - startOffsetX) / scrollView.bounds.width
            
        } else { // 向右边滑动
            
            targetIndex = currentIndex - 1
            
            if targetIndex < 0 {
                targetIndex = 0
            }
             
            progress = (startOffsetX - scrollView.contentOffset.x) / scrollView.bounds.width
        }
        
        // 3.通知代理
        delegate?.contentView(self, targetIndex: targetIndex, progress: progress)
        
    }
}

//MARK: -- HHTitleViewDelegate
extension HHContentView : HHTitleViewDelegate {
    
    func titleView(_ titleView: HHTitleView, targetIndex: Int) {
        
        isForbidScroll = true
        
        let indexPath = IndexPath(item: targetIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .left, animated: false)
    }
    
}
