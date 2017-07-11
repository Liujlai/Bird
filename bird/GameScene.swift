//
//  GameScene.swift
//  bird
//
//  Created by idea_liujl on 17/7/11.
//  Copyright (c) 2017年 idea_liujl. All rights reserved.
//

import SpriteKit


enum 图层:CGFloat{
    case 背景
    case 障碍物
    case 前景
    case 游戏角色
}



class GameScene: SKScene {
    
//   世界单位－－－ 所有角色场景的容器
    let 世界单位 = SKNode()
    var 游戏起点:CGFloat = 0
    var 游戏区域高度:CGFloat = 0
    let 主角 = SKSpriteNode(imageNamed: "Bird0")
    var 上一次更新时间:NSTimeInterval = 0
    var dt:NSTimeInterval=0
    
    
    let k重力:CGFloat = -1000.0
    let k上冲速度: CGFloat = 300.0
    var 速度 = CGPoint.zero
    
    let k前景地面数 = 2
    let k地面的移动速度 = -100.0
    let k底部障碍最小乘数 : CGFloat = 0.1
    let k底部障碍最大乘数 : CGFloat = 0.6
    let k缺口乘数: CGFloat = 3.5
    
    
//    创建音效
    let 叮 = SKAction.playSoundFileNamed("ding.wav", waitForCompletion: false)
    let 拍打 = SKAction.playSoundFileNamed("flapping.wav", waitForCompletion: false)
    let 摔倒 = SKAction.playSoundFileNamed("whack.wav", waitForCompletion: false)
    let 下落 = SKAction.playSoundFileNamed("falling.wav", waitForCompletion: false)
    let 撞击地面 = SKAction.playSoundFileNamed("hitGround.wav", waitForCompletion: false)
    let 砰 = SKAction.playSoundFileNamed("pop.wav", waitForCompletion: false)
    let 得分 = SKAction.playSoundFileNamed("coin.wav", waitForCompletion: false)
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
     addChild(世界单位)
     设置背景()
     设置前景()
     设置主角()
     生成障碍()
    }
//    设置相关方法
    func 设置背景(){
//        设置背景文件
       let 背景 = SKSpriteNode(imageNamed: "Background")
//        设置锚点位置
        背景.anchorPoint = CGPoint(x: 0.5, y: 1.0)
//        位置
        背景.position = CGPoint(x: size.width/2, y: size.height)
        
        背景.zPosition = 图层.背景.rawValue
        
        世界单位.addChild(背景)
        
        
        游戏起点 = size.height - 背景.size.height
        游戏区域高度 = 背景.size.height
        
    }
    func 设置前景(){
        for i in 0..<k前景地面数{
            let 前景 = SKSpriteNode(imageNamed: "Ground")
            前景.anchorPoint = CGPoint(x: 0, y: 1.0)
            前景.position = CGPoint(x: CGFloat(i) * 前景.size.width, y: 游戏起点)
            前景.zPosition = 图层.前景.rawValue
            前景.name = "前景"
            世界单位.addChild(前景)
        }
    }
    func 设置主角(){
        主角.position = CGPoint(x: size.width*0.2, y: 游戏区域高度*0.4+游戏起点)
        
        主角.zPosition = 图层.游戏角色.rawValue
        世界单位.addChild(主角)
    }
    
    
    // MARK: 游戏流程
    
    func 创建障碍物(图片名: String) ->SKSpriteNode{
        let 障碍物 = SKSpriteNode(imageNamed: 图片名)
        障碍物.zPosition = 图层.障碍物.rawValue
        return 障碍物
    }
    
    func 生成障碍(){
        let 底部障碍 = 创建障碍物("CactusBottom")
        let 起始X坐标 = size.width/2
        let Y坐标最小值 = (游戏起点 - 底部障碍.size.height) + 游戏区域高度 * k底部障碍最小乘数
        let Y坐标最大值 = (游戏起点 - 底部障碍.size.height) + 游戏区域高度 * k底部障碍最大乘数
        底部障碍.position = CGPointMake(起始X坐标, CGFloat.random(min:Y坐标最小值, max:Y坐标最大值))
        世界单位.addChild(底部障碍)
        
        
        let 顶部障碍 = 创建障碍物("CactusTop")
        顶部障碍.zRotation = CGFloat(180).degreesToRadians()
        顶部障碍.position = CGPoint(x: 起始X坐标, y: 底部障碍.position.y + 底部障碍.size.height/2 + 顶部障碍.size.height/2 + 主角.size.height * k缺口乘数)
        世界单位.addChild(顶部障碍)
    }
    
    
    func 主角飞(){
      速度 = CGPoint(x: 0, y: k上冲速度)
    }
    
    
    //   用回点击屏幕时触发该方法
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        runAction(拍打)
        
        主角飞()
        
    }

    override func update(当前时间: CFTimeInterval) {
        /* Called before each frame is rendered */
        if 上一次更新时间 > 0{
            dt = 当前时间 - 上一次更新时间
            
        }else{
            dt = 0
        }
        上一次更新时间 = 当前时间
        更新主角()
        更新前景()
        
    }
    
    func 更新主角(){
        let 加速度 = CGPoint(x: 0, y: k重力)
        速度 = 速度 + 加速度 * CGFloat(dt)
        主角.position = 主角.position + 速度 * CGFloat(dt)
      
        
        
//        检测碰撞地面时让他停在地面上
        if 主角.position.y - 主角.size.height/2 < 游戏起点{
            主角.position = CGPoint(x: 主角.position.x, y: 游戏起点 + 主角.size.height/2)
        }
        
        
    }
    
    func 更新前景(){
        世界单位.enumerateChildNodesWithName("前景", usingBlock: { 匹配单位, _ in
            if let 前景 = 匹配单位 as? SKSpriteNode{
                let 地面移动速度 = CGPoint(x: self.k地面的移动速度, y: 0)
                前景.position += 地面移动速度 * CGFloat(self.dt)
                
                if 前景.position.x < -前景.size.width{
                    前景.position += CGPoint(x: 前景.size.width * CGFloat(self.k前景地面数), y: 0)
                }
            }
        })
    }

}
