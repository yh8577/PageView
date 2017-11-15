//
//  HHTitleView.swift
//  HHPageView
//
//  Created by yihui on 2017/11/15.
//  Copyright © 2017年 yihui. All rights reserved.
//

import UIKit

protocol HHTitleViewDelegate : class {
    func titleView(_ titleView : HHTitleView, targetIndex : Int)
    
}

class HHTitleView: UIView {

    weak var delegate : HHTitleViewDelegate?
    
    fileprivate var titles : [String]
    fileprivate var style: HHTitleStyle
    fileprivate lazy var titleLabels : [UILabel] = [UILabel]()
    fileprivate lazy var currentIndex : Int = 0
    
    fileprivate lazy var scrollView : UIScrollView = {
       
        let scrollView = UIScrollView(frame: self.bounds)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.scrollsToTop = false
        
        return scrollView
        
    }()
    
    fileprivate lazy var bottomLine : UIView = {
        
        let bottomLine = UIView()
        bottomLine.backgroundColor = self.style.scrollLineColor
        bottomLine.frame.size.height = self.style.scrollLineHeight
        bottomLine.frame.origin.y = self.bounds.height - self.style.scrollLineHeight
        return bottomLine
    }()
    
    init(frame: CGRect, titles: [String], style: HHTitleStyle) {
        
        self.titles = titles
        self.style = style
        
        super.init(frame: frame)
  
        setupUI()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension HHTitleView {
    
    fileprivate func setupUI() {
        // 1.将scrollView添加到View
        addSubview(scrollView)
        
        // 2.将titleLabel添加到scrollView中
        setupTitleLabels()
        
        // 3.设置titlLabel的frame
        setupTitleLabelsFrame()
        
        // 4.设置bottomLine
        if style.isShowScrollLine {
            scrollView.addSubview(bottomLine)
        }
    }
    
    private func setupTitleLabels() {
        
        for (i, title) in titles.enumerated() {
            
            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.textColor = i == 0 ? style.selectColor : style.normalColor
            titleLabel.font = UIFont.systemFont(ofSize: style.fontSize)
            titleLabel.tag = i
            titleLabel.textAlignment = .center
            
            scrollView.addSubview(titleLabel)
            titleLabels.append(titleLabel)
            
            let tapGes = UITapGestureRecognizer(target: self, action: #selector(self.titleLabelClick(_:)))
            titleLabel.addGestureRecognizer(tapGes)
            titleLabel.isUserInteractionEnabled = true
            
        }
    }
    
    private func setupTitleLabelsFrame() {
        
        let count = titles.count
        
        for (i, label) in titleLabels.enumerated() {
            
            var w : CGFloat = 0
            let h : CGFloat = bounds.height
            var x : CGFloat = 0
            let y : CGFloat = 0
            
            if style.isScrollEnable { // 可以滚动
                w = (titles[i] as NSString).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: 0), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName : label.font], context: nil).width
                if i == 0 {
                    x = style.itemMargin * 0.5
                    if style.isShowScrollLine {
                        bottomLine.frame.origin.x = x
                        bottomLine.frame.size.width = w
                    }
                    
                } else {
                    
                    let preLabel = titleLabels[i - 1]
                    x = preLabel.frame.maxX + style.itemMargin
                    
                }
                
                
            } else { // 不能滚动
                w = bounds.width / CGFloat(count)
                x = w * CGFloat(i)
                
                if i == 0 && style.isShowScrollLine {
                    bottomLine.frame.origin.x = 0
                    bottomLine.frame.size.width = w
                }
                
            }
            
            label.frame = CGRect(x: x, y: y, width: w, height: h)
            
        }
        
        scrollView.contentSize = style.isScrollEnable ? CGSize(width: titleLabels.last!.frame.maxX + style.itemMargin * 0.5, height: 0) : CGSize.zero
        
        
    }
}

//MARK: --监听事件
extension HHTitleView {

    @objc fileprivate func titleLabelClick(_ tapGes : UITapGestureRecognizer) {
        // 1.取出用户点击的View
        let targetLabel = tapGes.view as! UILabel
        
        // 2. 调整title
        adjustTitleLabel(targetIndex: targetLabel.tag)
        
        // 3. 通知ContentView进行调整
        delegate?.titleView(self, targetIndex: currentIndex)
        
    }
    
    fileprivate func adjustTitleLabel(targetIndex : Int) {
        
        if targetIndex == currentIndex { return }
        
        // 1.取出label
        let targetLabel = titleLabels[targetIndex]
        let sourceLabel = titleLabels[currentIndex]
        
        // 2.切换文字颜色
        targetLabel.textColor = style.selectColor
        sourceLabel.textColor = style.normalColor
        
        // 3.记录下标值
        currentIndex = targetIndex
        
        // 4.调整位置
        if style.isScrollEnable {
            
            var offset = targetLabel.center.x - scrollView.bounds.width * 0.5
            
            if offset < 0 {
                offset = 0
            }
            if offset > (scrollView.contentSize.width - scrollView.bounds.width) {
                offset = (scrollView.contentSize.width - scrollView.bounds.width)
            }
            
            scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
        }
        
        // 5.调整bottomLine
        if style.isShowScrollLine {
            
            UIView.animate(withDuration: 0.25) {
                self.bottomLine.frame.origin.x = targetLabel.frame.origin.x
                self.bottomLine.frame.size.width = targetLabel.frame.width
            }
        }
    }
}

//MARK: --  HHContentViewDelegate 
extension HHTitleView : HHContentViewDelegate {
    
    func contentView(_ contentView: HHContentView, targetIndex: Int) {
        
        adjustTitleLabel(targetIndex: targetIndex)
    
    }
    
    func contentView(_ contentView: HHContentView, targetIndex: Int, progress: CGFloat) {
        // 1.取出label
        let targetLabel = titleLabels[targetIndex]
        let sourceLabel = titleLabels[currentIndex]
        
        // 2.颜色渐变
        let deltaRGB = UIColor.getRGBDelta(style.selectColor, style.normalColor)
        let selectRGB = style.selectColor.getRGB()
        let normalRGB = style.normalColor.getRGB()
        
        
        targetLabel.textColor = UIColor(r: normalRGB.0 + deltaRGB.0 * progress, g: normalRGB.1 + deltaRGB.1 * progress, b: normalRGB.2 + deltaRGB.2 * progress)
        sourceLabel.textColor = UIColor(r: selectRGB.0 - deltaRGB.0 * progress, g: selectRGB.1 - deltaRGB.1 * progress, b: selectRGB.2 - deltaRGB.2 * progress)
        
        if style.isShowScrollLine {
            let deltaX = targetLabel.frame.origin.x - sourceLabel.frame.origin.x
            let deltaW = targetLabel.frame.width - sourceLabel.frame.width
            bottomLine.frame.origin.x = sourceLabel.frame.origin.x + deltaX * progress
            bottomLine.frame.size.width = sourceLabel.frame.width + deltaW * progress
        }
    
    }
    
    
}
