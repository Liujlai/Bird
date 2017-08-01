//
//  GameViewController.swift
//  bird
//
//  Created by idea_liujl on 17/7/11.
//  Copyright (c) 2017年 idea_liujl. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let skview = self.view as? SKView{
            if skview.scene == nil{
//                创建游戏的场景
                let 长宽比 = skview.bounds.height / skview.bounds.width
                let 场景 = GameScene(size:CGSize(width: 320, height: 320*长宽比))
                
//                看到帧数
                skview.showsFPS = true
//                场景中（节点）单位的数量
                skview.showsNodeCount = true
//                物理模型的外边框（轮廓）
                skview.showsPhysics = true
//                忽略游戏中增加元素的顺序（所有元素在同一层级）
                skview.ignoresSiblingOrder = true
                
//                场景的拉伸模式是——————等比例缩放
                场景.scaleMode = .aspectFill
//                把场景加入sk视图中
                skview.presentScene(场景)
            }
        }
    }
    
    
//    手机顶部栏是否隐藏 —>是
    override var prefersStatusBarHidden : Bool {
        return true
    }
}
