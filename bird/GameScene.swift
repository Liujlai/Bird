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
    case ui
}

enum 游戏状态{
    case 主菜单
    case 教程
    case 游戏
    case 跌落
    case 显示分数
    case 结束
}

struct 物理层{
    static let 无: UInt32 = 0
    static let 游戏角色: UInt32 = 0b1 //1
    static let 障碍物: UInt32 = 0b10  //2
    static let 地面: UInt32 = 0b100   //4
}


class GameScene: SKScene,SKPhysicsContactDelegate {
    
    let 课程网址 = "https://www.baidu.com"
    let AppStore的链接 = "https://www.apple.com"
    
//   世界单位－－－ 所有角色场景的容器
    let 世界单位 = SKNode()
    var 游戏起点:CGFloat = 0
    var 游戏区域高度:CGFloat = 0
    let 主角 = SKSpriteNode(imageNamed: "Bird0")
    let 帽子 = SKSpriteNode(imageNamed: "Sombrero")
    var 上一次更新时间:TimeInterval = 0
    var dt:TimeInterval=0
    
    
    let k重力:CGFloat = -1000.0
    let k上冲速度: CGFloat = 300.0
    var 速度 = CGPoint.zero
    var 撞击了地面 = false
    var 撞击了障碍物 = false
    
    var 当前的游戏状态: 游戏状态 = .游戏
    
    let k前景地面数 = 2
    let k地面的移动速度 = -150.0
    let k底部障碍最小乘数 : CGFloat = 0.1
    let k底部障碍最大乘数 : CGFloat = 0.6
    let k缺口乘数: CGFloat = 3.5
    
    
    let k首次生成障碍延时: TimeInterval = 1.75
    let k每次重生障碍延时: TimeInterval = 1.5
    
    let k顶部留白: CGFloat = 20.0
    let k字体名称 = "AmericanTypewriter-bold"
    var 得分标签: SKLabelNode!
    var 当前分数 = 0
    
    
    let k动画延时 = 0.3
    let k角色动画总帧数 = 4
    
//    创建音效
    let 叮 = SKAction.playSoundFileNamed("ding.wav", waitForCompletion: false)
    let 拍打 = SKAction.playSoundFileNamed("flapping.wav", waitForCompletion: false)
    let 摔倒 = SKAction.playSoundFileNamed("whack.wav", waitForCompletion: false)
    let 下落 = SKAction.playSoundFileNamed("falling.wav", waitForCompletion: false)
    let 撞击地面 = SKAction.playSoundFileNamed("hitGround.wav", waitForCompletion: false)
    let 砰 = SKAction.playSoundFileNamed("pop.wav", waitForCompletion: false)
    let 得分 = SKAction.playSoundFileNamed("coin.wav", waitForCompletion: false)
    
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        //关掉重力
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        physicsWorld.contactDelegate = self
        
        addChild(世界单位)
        切换到主菜单()

    }
    //MARK:    设置相关方法
    
    func 设置主菜单(){
        let logo = SKSpriteNode(imageNamed: "Logo")
        logo.position = CGPoint(x: size.width/2, y: size.height*0.8)
        logo.name = "主菜单"
        logo.zPosition = 图层.ui.rawValue
        世界单位.addChild(logo)
        
        
        let 开始游戏按钮 = SKSpriteNode(imageNamed: "Button")
        开始游戏按钮.position = CGPoint(x: size.width*0.25, y: size.height*0.25)
        开始游戏按钮.name = "主菜单"
        开始游戏按钮.zPosition = 图层.ui.rawValue
        世界单位.addChild(开始游戏按钮)
        
        
        let 游戏 = SKSpriteNode(imageNamed: "Play")
        游戏.position = CGPoint.zero
        开始游戏按钮.addChild(游戏)
        
        
        
        
        
        let 评价按钮 = SKSpriteNode(imageNamed: "Button")
        评价按钮.position = CGPoint(x: size.width*0.75, y: size.height*0.25)
        评价按钮.name = "主菜单"
        评价按钮.zPosition = 图层.ui.rawValue
        世界单位.addChild(评价按钮)
        
        
        let 评价 = SKSpriteNode(imageNamed: "Rate")
        评价.position = CGPoint.zero
        评价按钮.addChild(评价)
    
        
        let 学习 = SKSpriteNode(imageNamed: "button_learn")
        学习.position = CGPoint(x: size.width*0.5, y: 学习.size.height/2 + k顶部留白)
        学习.name = "主菜单"
        学习.zPosition = 图层.ui.rawValue
        世界单位.addChild(学习)
        
//        学习按钮的动画
        let 放大动画 = SKAction.scale(to: 1.02, duration: 0.75)
        放大动画.timingMode = .easeInEaseOut
        
        let 缩小动画 = SKAction.scale(to: 0.98, duration: 0.75)
        缩小动画.timingMode = .easeInEaseOut
        
        
        学习.run(SKAction.repeatForever(SKAction.sequence([放大动画,缩小动画])))

        
    }
    
    func 设置教程(){
        let 教程 = SKSpriteNode(imageNamed: "Tutorial")
        教程.position = CGPoint(x: size.width*0.5, y: 游戏区域高度*0.54 + 游戏起点)
        教程.name = "教程"
        教程.zPosition = 图层.ui.rawValue
        世界单位.addChild(教程)
        
        
        
        
        let 准备 = SKSpriteNode(imageNamed: "Ready")
        准备.position = CGPoint(x: size.width*0.5, y: 游戏区域高度*0.8 + 游戏起点)
        准备.name = "教程"
        准备.zPosition = 图层.ui.rawValue
        世界单位.addChild(准备)
        
        
        let 向上移动 = SKAction.moveBy(x: 0, y: 50, duration: 0.4)
        向上移动.timingMode = .easeInEaseOut
        let 向下移动 = 向上移动.reversed()
        
        主角.run(SKAction.repeatForever(SKAction.sequence([
            向上移动,向下移动
            ])), withKey: "起飞")
        
        var 角色贴图组: Array<SKTexture> = []
        
        for i in 0..<k角色动画总帧数 {
            角色贴图组.append(SKTexture(imageNamed: "Bird\(i)"))
        }
        
        for i in stride(from: (k角色动画总帧数-1), through: 0, by: -1) {
            角色贴图组.append(SKTexture(imageNamed: "Bird\(i)"))
        }
        
        let 扇动翅膀的动画 = SKAction.animate(with: 角色贴图组, timePerFrame: 0.07)
        主角.run(SKAction.repeatForever(扇动翅膀的动画))
    }
    
    
    
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
        
        
        let 左下 = CGPoint(x: 0, y: 游戏起点)
        let 右下 = CGPoint(x: size.width, y: 游戏起点)
        self.physicsBody = SKPhysicsBody(edgeFrom: 左下, to: 右下)
        self.physicsBody?.categoryBitMask = 物理层 .地面
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.collisionBitMask = 物理层.游戏角色
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
        
        
        /**
        /碰撞体积的设置
        / 在网址https://stackoverflow.com/questions/19040144中，
        ／选择Xelt的，点击Run code snippet后点 Full page，
        ／拖入图片，在图片上点击选择碰撞体积
        ／复制Output中生成的代码
        */
        
        let offsetX = 主角.size.width * 主角.anchorPoint.x
        let offsetY = 主角.size.height * 主角.anchorPoint.y
        
        let path = CGMutablePath()
        //如何更改错误的网址：https://stackoverflow.com/questions/39041888/why-is-nil-not-compatible-with-unsafepointercgaffinetransform-in-swift-3/39927882
        path.move(to: CGPoint(x: 2 - offsetX,y: 13 - offsetY))
        path.addLine(to: CGPoint(x:  17 - offsetX, y: 21 - offsetY))
        path.addLine(to: CGPoint(x:  25 - offsetX, y: 26 - offsetY))
        path.addLine(to: CGPoint(x:  35 - offsetX, y: 27 - offsetY))
        path.addLine(to: CGPoint(x:  38 - offsetX, y: 21 - offsetY))
        path.addLine(to: CGPoint(x:  37 - offsetX, y: 9 - offsetY))
        path.addLine(to: CGPoint(x:  34 - offsetX, y: 3 - offsetY))
        path.addLine(to: CGPoint(x:  24 - offsetX, y: 2 - offsetY))
        path.addLine(to: CGPoint(x:  19 - offsetX, y: 0 - offsetY))
        path.addLine(to: CGPoint(x:  9 - offsetX,  y: 1 - offsetY))
        path.addLine(to: CGPoint(x:  4 - offsetX,  y: 2 - offsetY))
        
        path.closeSubpath()
        
        主角.physicsBody = SKPhysicsBody(polygonFrom: path)
//        定义类别掩码----物理引擎能够识别的类似图层
        主角.physicsBody?.categoryBitMask = 物理层.游戏角色
        主角.physicsBody?.categoryBitMask = 0
        主角.physicsBody?.contactTestBitMask = 物理层.障碍物 | 物理层.地面
        
        
        世界单位.addChild(主角)
    }
    func 设置帽子(){
        帽子.position = CGPoint(x: 31 - 帽子.size.width/2, y: 29 - 帽子.size.height/2)
        主角.addChild(帽子)
    }
    func 设置得分标签(){
        得分标签 = SKLabelNode(fontNamed: k字体名称)
        得分标签.fontColor = SKColor(red: 101.0/255.0, green: 71.0/255.0, blue: 73.0/255.0, alpha: 1.0)
        得分标签.position = CGPoint(x: size.width/2, y: size.height - k顶部留白)
//        对齐方式
        得分标签.verticalAlignmentMode = .top
        得分标签.text = "0"
        得分标签.zPosition = 图层.ui.rawValue
        世界单位.addChild(得分标签)
    }
    
    func 设置记分板(){
        if 当前分数 > 最高分(){
            设置最高分(当前分数)
        }
        let 记分板 = SKSpriteNode(imageNamed: "ScoreCard")
        记分板.position = CGPoint(x: size.width/2, y: size.height/2)
        记分板.zPosition = 图层.ui.rawValue
        世界单位.addChild(记分板)
        
        
        let 当前分数标签 = SKLabelNode(fontNamed: k字体名称)
        当前分数标签.fontColor = SKColor(red: 101.0/255.0, green: 71.0/255.0, blue: 73.0/255.0, alpha: 1.0)
        当前分数标签.position = CGPoint(x: -记分板.size.width/4, y: -记分板.size.height/3)
        当前分数标签.text = "\(当前分数)"
        当前分数标签.zPosition = 图层.ui.rawValue
        记分板.addChild(当前分数标签)
        
        
        let 最高分标签 = SKLabelNode(fontNamed: k字体名称)
        最高分标签.fontColor = SKColor(red: 101.0/255.0, green: 71.0/255.0, blue: 73.0/255.0, alpha: 1.0)
        最高分标签.position = CGPoint(x: 记分板.size.width/4, y: -记分板.size.height/3)
        最高分标签.text = "\(最高分())"
        最高分标签.zPosition = 图层.ui.rawValue
        记分板.addChild(最高分标签)
        
        
        let 游戏结束 = SKSpriteNode(imageNamed: "GameOver")
        游戏结束.position = CGPoint(x: size.width/2, y: size.height/2 + 记分板.size.height/2 + k顶部留白 + 游戏结束.size.height/2)
        游戏结束.zPosition = 图层.ui.rawValue
        世界单位.addChild(游戏结束)
        
        
        let ok按钮 = SKSpriteNode(imageNamed: "Button")
        ok按钮.position = CGPoint(x: size.width/4, y: size.height/2 - 记分板.size.height/2 - k顶部留白 - ok按钮.size.height/2)
        ok按钮.zPosition = 图层.ui.rawValue
        世界单位.addChild(ok按钮)
        
        
        
        let ok = SKSpriteNode(imageNamed: "OK")
        ok.position = CGPoint.zero
        ok.zPosition = 图层.ui.rawValue
        ok按钮.addChild(ok)

        let 分享按钮 = SKSpriteNode(imageNamed: "ButtonRight")
        分享按钮.position = CGPoint(x: size.width * 0.75, y: size.height/2 - 记分板.size.height/2 - k顶部留白 - 分享按钮.size.height/2)
        分享按钮.zPosition = 图层.ui.rawValue
        世界单位.addChild(分享按钮)
        
        
        
        let 分享 = SKSpriteNode(imageNamed: "Share")
        分享.position = CGPoint.zero
        分享.zPosition = 图层.ui.rawValue
        分享按钮.addChild(分享)
        
//
        /**
        设置记分页面特效
        
        -
        */
        游戏结束.setScale(0)
//        alpha 值为透明度
        游戏结束.alpha = 0
        let 动画 = SKAction.group([SKAction.fadeIn(withDuration: k动画延时),SKAction.scale(to: 1.0, duration: k动画延时)])
        动画.timingMode = .easeInEaseOut
        游戏结束.run(SKAction.sequence([SKAction.wait(forDuration: k动画延时),动画]))
        
        记分板.position = CGPoint(x: size.width/2, y: -记分板.size.height/2)
        let 向上移动的动画 = SKAction.move(to: CGPoint(x: size.width/2, y: size.height/2), duration: k动画延时)
        向上移动的动画.timingMode = .easeInEaseOut
        记分板.run(SKAction.sequence([SKAction.wait(forDuration: k动画延时*2),向上移动的动画]))
        
        
        ok按钮.alpha = 0
        分享按钮.alpha = 0
        
        let  渐变动画 = SKAction.sequence([SKAction.wait(forDuration: k动画延时*3),SKAction.fadeIn(withDuration: k动画延时)])
        ok按钮.run(渐变动画)
        分享按钮.run(渐变动画)
        
        
        
        
        let 声音特效 = SKAction.sequence([SKAction.wait(forDuration: k动画延时),砰,SKAction.wait(forDuration: k动画延时),砰,SKAction.wait(forDuration: k动画延时),砰,SKAction.run(切换到结束状态)])
        run(声音特效)
        
    }
    
    // MARK: 游戏流程
    
    func 创建障碍物(_ 图片名: String) ->SKSpriteNode{
        let 障碍物 = SKSpriteNode(imageNamed: 图片名)
        障碍物.zPosition = 图层.障碍物.rawValue
        障碍物.userData = NSMutableDictionary()
        
        //碰撞体积设置同上方主角
        let offsetX = 障碍物.size.width * 障碍物.anchorPoint.x
        let offsetY = 障碍物.size.height * 障碍物.anchorPoint.y
        
        let path = CGMutablePath()
        
        path.move(to:CGPoint(x: 4 - offsetX,y: 0 - offsetY))
        path.addLine(to:CGPoint(x: 5 - offsetX, y: 309 - offsetY))
        path.addLine(to:CGPoint(x: 46 - offsetX,y: 309 - offsetY))
        path.addLine(to:CGPoint(x: 47 - offsetX,y: 3 - offsetY))
        
        path.closeSubpath()
        
        障碍物.physicsBody = SKPhysicsBody(polygonFrom: path)
        障碍物.physicsBody?.categoryBitMask = 物理层.障碍物
        障碍物.physicsBody?.collisionBitMask = 0
        障碍物.physicsBody?.contactTestBitMask = 物理层.游戏角色
        
        return 障碍物
    }
    
    func 生成障碍(){
        let 底部障碍 = 创建障碍物("CactusBottom")
        let 起始X坐标 = size.width + 底部障碍.size.width/2
        let Y坐标最小值 = (游戏起点 - 底部障碍.size.height/2) + 游戏区域高度 * k底部障碍最小乘数
        let Y坐标最大值 = (游戏起点 - 底部障碍.size.height/2) + 游戏区域高度 * k底部障碍最大乘数
        底部障碍.position = CGPoint(x: 起始X坐标, y: CGFloat.random(min:Y坐标最小值, max:Y坐标最大值))
        底部障碍.name = "底部障碍"
        世界单位.addChild(底部障碍)
        
        
        let 顶部障碍 = 创建障碍物("CactusTop")
        顶部障碍.zRotation = CGFloat(180).degreesToRadians()
        顶部障碍.position = CGPoint(x: 起始X坐标, y: 底部障碍.position.y + 底部障碍.size.height/2 + 顶部障碍.size.height/2 + 主角.size.height * k缺口乘数)
        顶部障碍.name = "顶部障碍"
        
        世界单位.addChild(顶部障碍)
        
        
        let X轴移动距离 = -(size.width + 底部障碍.size.width)
        let 移动持续时间 = TimeInterval(X轴移动距离) / k地面的移动速度
        let 移动的动作队列 = SKAction.sequence([SKAction.moveBy(x: X轴移动距离, y: 0, duration: TimeInterval(移动持续时间)),SKAction.removeFromParent()
            ])
        
        顶部障碍.run(移动的动作队列)
        底部障碍.run(移动的动作队列)
    
    }
    
    func 无限重生障碍(){
        let 首次延时 = SKAction.wait(forDuration: k首次生成障碍延时)
        let 重生障碍 = SKAction.run(生成障碍)
        let 每次重生间隔 = SKAction.wait(forDuration: k每次重生障碍延时)
        let 重生动作队列 = SKAction.sequence([重生障碍,每次重生间隔])
        let 无限重生  =  SKAction.repeatForever(重生动作队列)
        let 总的动作队列 = SKAction.sequence([首次延时,无限重生])
        run(总的动作队列,withKey:"重生")
    }
    
    func 停止重生障碍(){
        removeAction(forKey: "重生")
        
        世界单位.enumerateChildNodes(withName: "顶部障碍", using :{ 匹配单位, _ in
            匹配单位.removeAllActions()
        })
        
        世界单位.enumerateChildNodes(withName: "底部障碍", using : { 匹配单位, _ in
            匹配单位.removeAllActions()
        })
    }
    
    func 主角飞(){
      速度 = CGPoint(x: 0, y: k上冲速度)
//        移动帽子
        let 向上移动 = SKAction.moveBy(x: 0, y: 12, duration: 0.15)
        向上移动.timingMode = .easeInEaseOut
        let 向下移动 = 向上移动.reversed()
        帽子.run(SKAction.sequence([向上移动,向下移动]))
        
        
        run(拍打)
    }
    
    
    //   用回点击屏幕时触发该方法
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       /* Called when a touch begins */
        
        guard let 点击 = touches.first else {
            return
        }
        let 点击位置 = 点击.location(in: self)
        
        switch 当前的游戏状态{
        case .主菜单:
            
            if 点击位置.y < size.height*0.15{
                去学习()
            }else if 点击位置.x < size.width/2{
                切换到教程状态()
            }else{
                去评价()
            }
            break
        case .教程:
            切换到游戏状态()
            break
        case .游戏:
            主角飞()
            break
        case .跌落:
            break
        case .显示分数:
            
            break
        case .结束:
            切换到新游戏()
            break
        }
        
        
        
      
        
    }

    override func update(_ 当前时间: TimeInterval) {
        /* Called before each frame is rendered */
        if 上一次更新时间 > 0{
            dt = 当前时间 - 上一次更新时间
            
        }else{
            dt = 0
        }
        上一次更新时间 = 当前时间
//        更新主角()
//        更新前景()
//        撞击障碍物检查()
        switch 当前的游戏状态{
        case .主菜单:
            break
        case .教程:
            break
        case .游戏:
            更新前景()
            更新主角()
            撞击障碍物检查()
            撞击地面检查()
            更新得分()
            break
        case .跌落:
            更新主角()
            撞击地面检查()
            break
        case .显示分数:
            break
        case .结束:
            break
        }
        
        
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
        世界单位.enumerateChildNodes(withName: "前景"){ 匹配单位, _ in
            if let 前景 = 匹配单位 as? SKSpriteNode{
                let 地面移动速度 = CGPoint(x: self.k地面的移动速度, y: 0)
                前景.position += 地面移动速度 * CGFloat(self.dt)
                
                if 前景.position.x < -前景.size.width{
                    前景.position += CGPoint(x: 前景.size.width * CGFloat(self.k前景地面数), y: 0)
                }
            }
        }
    }
    
    func 撞击障碍物检查(){
        if 撞击了障碍物{
             撞击了障碍物 = false
             切换到跌落状态()
            
            
        }
    }
    func 撞击地面检查(){
        if 撞击了地面{
            撞击了地面 = false
            速度 = CGPoint.zero
            主角.zRotation = CGFloat(-90).degreesToRadians()
            主角.position = CGPoint(x: 主角.position.x, y: 游戏起点 + 主角.size.width/2)
            run(撞击地面)
            切换到显示分数状态()
        }
    }
    
    
    func 更新得分(){
        世界单位.enumerateChildNodes(withName: "顶部障碍", using: {匹配单位, _ in
            if let 障碍物 = 匹配单位 as? SKSpriteNode{
                if let 已通过 = 障碍物.userData?["已通过"] as? NSNumber{
                    if 已通过.boolValue{
                        return
                    }
                }
                if self.主角.position.x > 障碍物.position.x + 障碍物.size.width/2{
                    
                    self.当前分数 += 1
                    self.得分标签.text = "\(self.当前分数)"
                    self.run(self.得分)
                    障碍物.userData?["已通过"] = NSNumber(value: true as Bool)
                    
                    
                }
            }
        })
    }
    // MARK: 游戏状态
    
    
    func 切换到主菜单(){
        当前的游戏状态 = .主菜单
        设置背景()
        设置前景()
        设置主角()
        设置帽子()
        设置主菜单()
    }
    
    func 切换到教程状态(){
         当前的游戏状态 = .教程
//        设置背景()
//        设置前景()
//        设置主角()
//        设置帽子()
       
        
        世界单位.enumerateChildNodes(withName: "主菜单"){ 匹配单位, _ in
            匹配单位.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.05),SKAction.removeFromParent()]))
        }


        
        设置得分标签()
        设置教程()
      
    }
    
    
    func 切换到游戏状态(){
        当前的游戏状态 = .游戏
        
        世界单位.enumerateChildNodes(withName: "教程"){ 匹配单位, _ in
            匹配单位.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.05),SKAction.removeFromParent()]))
        }
        
        主角.removeAction(forKey: "起飞")
        无限重生障碍()
        主角飞()
    }


    
    func 切换到跌落状态(){
       当前的游戏状态 = .跌落
        run(SKAction.sequence([摔倒,SKAction.wait(forDuration: 0.1),下落]))
        
        主角.removeAllActions()
        停止重生障碍()
    }
    
    func 切换到显示分数状态(){
        当前的游戏状态 = .显示分数
        主角.removeAllActions()
        停止重生障碍()
        设置记分板()
    }
    
    func 切换到新游戏(){
        run(砰)
        let 新的游戏场景 = GameScene.init(size:size)
        
        let 切换音效 = SKTransition.fade(with: SKColor.black, duration: 0.05)
        view?.presentScene(新的游戏场景, transition: 切换音效)
    }
    func 切换到结束状态(){
        当前的游戏状态 = .结束
    }
    
    // MARK: 分数
    func 最高分() ->Int{
        return UserDefaults.standard.integer(forKey: "最高分")
    
    }
    func 设置最高分(_ 最高分:Int){
        UserDefaults.standard.set(最高分, forKey: "最高分")
        UserDefaults.standard.synchronize()
    }
        
    //MARK: 物理引擎
    func didBegin(_ 碰撞双方: SKPhysicsContact) {
        let 被撞对象 = 碰撞双方.bodyA.categoryBitMask == 物理层.游戏角色 ? 碰撞双方.bodyB : 碰撞双方.bodyA
      
        if 被撞对象.categoryBitMask == 物理层.地面{
            撞击了地面 = true
        }
        /**
        *  经测试 被撞对象.categoryBitMask 的值要么4，要么是0，所以暂时将 物理层.障碍物 改为 物理层.无
        */
        
//        if 被撞对象.categoryBitMask == 物理层.障碍物{
//            撞击了障碍物 = true
//        }
        if 被撞对象.categoryBitMask == 物理层.无{
            撞击了障碍物 = true
        }
    }
    
    //MARK: 其他
    func 去学习(){
        let 网址 = URL(string: 课程网址)
        UIApplication.shared.openURL(网址!)
    }
    
    func 去评价(){
        let 网址 = URL(string: AppStore的链接)
        UIApplication.shared.openURL(网址!)
        
    }

}
