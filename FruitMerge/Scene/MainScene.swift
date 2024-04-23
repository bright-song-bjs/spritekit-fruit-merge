import Foundation
import SpriteKit


class MainScene: SKScene, SKPhysicsContactDelegate
{
    let groundHeight = Shared.screenBounds.height * 0.12
    let groundSurfaceHeight = Shared.screenBounds.height * 0.015
    let currentFruitPosition = CGPoint(x: Shared.screenBounds.width * 0.5, y: (Shared.screenBounds.height - Shared.screenBounds.height * 0.11))
    let scoreTextPosition = CGPoint(x: Shared.screenBounds.width * 0.045, y: (Shared.screenBounds.height - Shared.screenBounds.height * 0.06))
    let warningHeight: CGFloat = Shared.screenBounds.height * 0.65
    let redLineHeight: CGFloat = Shared.screenBounds.height * 0.83
    let destroyFruitInterval: CGFloat = 0.016
    
    /*
    
     there are a few things to add in the future
     1.there could be five or more buff buttons at the bottom which could allow player change the current fruit or the next fruit when pressed
     ps.current fruit is null right after touches ended until next fruit is generated(0.35 sec later), so when button is pressed, both cases have to be checked
     ps.either player change to current fruit to the one he wants(if he chooses when the current fruit is nil, then generate the next one directly as he wants), or player chooses the next one he wants
     
     2.add game over menu, restart button and rule menu etc
     
     3.add more sounds effects like game over, collision with ground, collision with walls and other fruits, and different volumes based on impulse like haptic
     
    */
    
    
    var selectedNodes: [UITouch: SKNode] = [:]
    
    var currentFtuit: Fruit!
    var scoreText = SKNode()
    var currentScore: Int = 0
    {
        didSet
        {
            let text = String(self.currentScore)
            self.updateScoreText(score: text)
        }
    }
    var redLine: SKSpriteNode!
    var fruitsOnScene = Array<Fruit>()
    
    var isCurrentFruitMotivated = false
    var touchControlEnabled = true
    var motivatedFruit: [Fruit : Double] = [:]
    
    var redLineShowing = false
    var isGameOver = false
    
    var spriteGenerator: SpriteGenerator!
    
    
    override func didMove(to view: SKView)
    {
        self.physicsWorld.contactDelegate = self
        
        self.setUpReference()
        self.setUpScene()
        self.startFruitsChecking()
        
        self.spriteGenerator.generateRandomFruit()
    }
    
    override func update(_ currentTime: TimeInterval)
    {
        for (motivated, idealX) in self.motivatedFruit
        {
            if abs(idealX - motivated.position.x) > 3
            {
                let destX = idealX - 0.95 * (idealX - motivated.position.x)
                motivated.position.x = destX
            }
            else if !self.isCurrentFruitMotivated
            {
                self.motivatedFruit.removeValue(forKey: motivated)
            }
        }
    }
    
    //MARK: - Touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        guard let firstTouch = touches.first else { return }

        let location = firstTouch.location(in: self)

        if (self.currentFtuit != nil) && self.touchControlEnabled
        {
            if !self.selectedNodes.values.contains(self.currentFtuit)
            {
                self.selectedNodes[firstTouch] = self.currentFtuit
                self.motivatedFruit[self.currentFtuit] = location.x
                self.isCurrentFruitMotivated = true
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        guard let firstTouch = touches.first else { return }

        let location = firstTouch.location(in: self)

        if let node = self.selectedNodes[firstTouch] as? Fruit
        {
            self.motivatedFruit[node] = location.x
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        guard let firstTouch = touches.first else { return }

        if let node = self.selectedNodes[firstTouch]
        {
            if node is Fruit
            {
                self.isCurrentFruitMotivated = false
                self.currentFtuit.physicsBody?.affectedByGravity = true
                self.currentFtuit = nil

                self.run(.sequence([
                    .wait(forDuration: 0.35),
                    .run
                    {
                        //generate next current fruit
                        if !self.isGameOver
                        {
                            self.spriteGenerator.generateRandomFruit()
                        }
                        
                        //remove touch node after the next fruit is generated
                        self.selectedNodes.removeValue(forKey: firstTouch)
                    }
                ]))
            }
        }
    }
    
    //MARK: - Collision
    func didBegin(_ contact: SKPhysicsContact)
    {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        let collisionMask = nodeA.physicsBody!.categoryBitMask | nodeB.physicsBody!.categoryBitMask
        
        //haptic
        switch contact.collisionImpulse
        {
            case 300..<1000:
                let intensity = ((contact.collisionImpulse - 300) / 700 * 0.2) + 0.8
                Utilities.impactFeedback_heavy(intensity: intensity)
            
            case 150..<300:
                let intensity = ((contact.collisionImpulse - 150) / 150 * 0.3) + 0.5
                Utilities.impactFeedback_heavy(intensity: intensity)
            
            case 30..<150:
                let intensity = (contact.collisionImpulse - 30) / 120 * 0.5
                Utilities.impactFeedback_heavy(intensity: intensity)
            
            default:
                if contact.collisionImpulse >= 1000
                {
                    Utilities.impactFeedback_heavy(intensity: 1)
                }
        }
        
        //register fruit to fruitsOnScene
        if let fruitA = nodeA as? Fruit
        {
            if (!fruitA.registered) && (!fruitA.merged) && (fruitA.position.y < self.currentFruitPosition.y)
            {
                self.fruitsOnScene.append(fruitA)
                fruitA.registered = true
                if self.motivatedFruit.keys.contains(fruitA)
                {
                    self.motivatedFruit.removeValue(forKey: fruitA)
                }
            }
        }
        if let fruitB = nodeB as? Fruit
        {
            if (!fruitB.registered) && (!fruitB.merged) && (fruitB.position.y < self.currentFruitPosition.y)
            {
                self.fruitsOnScene.append(fruitB)
                fruitB.registered = true
                if self.motivatedFruit.keys.contains(fruitB)
                {
                    self.motivatedFruit.removeValue(forKey: fruitB)
                }
            }
        }
        
        //check if two identical fruits collide
        for fruitInfo in FruitInfo.allCases
        {
            if (collisionMask == fruitInfo.categoryBitMask) && (collisionMask != FruitInfo.watermelon.categoryBitMask)
            {
                self.spriteGenerator.mergeFruit(nodeA: nodeA, nodeB: nodeB, contactPoint: contact.contactPoint)
            }
        }
    }
}


extension MainScene
{
    //MARK: - Other Functions
    private func setUpScene()
    {
        //background
        let background = SKSpriteNode(color: UIColor(#colorLiteral(red: 0.9333333333, green: 0.737254902, blue: 0.3529411765, alpha: 1)), size: CGSize(width: Shared.screenBounds.width, height: Shared.screenBounds.height))
        background.anchorPoint = CGPoint.zero
        background.position = CGPoint.zero
        self.addChild(background)
      
        //ground
        let ground = SKSpriteNode(color: #colorLiteral(red: 0.4816809297, green: 0.3267268538, blue: 0.2180004716, alpha: 1), size: CGSize(width: Shared.screenBounds.width, height: self.groundHeight))
        ground.anchorPoint = CGPoint.zero
        ground.position = CGPoint.zero
        self.addChild(ground)
        
        //ground surface
        let groundSurface = SKSpriteNode(color: #colorLiteral(red: 0.6745098039, green: 0.537254902, blue: 0.3490196078, alpha: 1), size: CGSize(width: Shared.screenBounds.width, height: self.groundSurfaceHeight))
        groundSurface.anchorPoint = CGPoint.zero
        groundSurface.position = CGPoint(x: 0, y: self.groundHeight)
        groundSurface.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0, y: 0, width: groundSurface.size.width, height: groundSurface.size.height))
        groundSurface.physicsBody?.categoryBitMask = CategoryBitMask.wall_ground.uint32
        groundSurface.physicsBody?.friction = 0.6
        self.addChild(groundSurface)
      
        //frame physicsBody
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0, y: 0, width: Shared.screenBounds.width, height: Shared.screenBounds.height * 1.8))
        self.physicsBody?.isDynamic = false
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = CategoryBitMask.wall_bounds.uint32
        self.physicsBody?.friction = 0.9
        
        //red line
        self.redLine = SKSpriteNode(imageNamed: "redline")
        self.redLine.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.redLine.setScale(0.6)
        self.redLine.position = CGPoint(x: Shared.screenBounds.midX, y: self.redLineHeight)
        self.redLine.alpha = 0
        self.addChild(self.redLine)
        
        //update score text (set default value won't call didSet)
        self.currentScore = 0
    }
    
    private func setUpReference()
    {
        self.spriteGenerator = SpriteGenerator(mainScene: self)
    }
        
    func updateScoreText(score: String)
    {
        if self.scoreText.parent != nil
        {
            self.scoreText.removeFromParent()
        }
        
        self.scoreText = Utilities.getNumberNode(from: score, anchor_x: false, anchor_y: true)
        self.scoreText.zPosition = 1
        self.scoreText.position = self.scoreTextPosition
        
        self.addChild(self.scoreText)
    }
    
    func runAction_matermelonMerged(at contactPoint: CGPoint)
    {
        //gray background animation
        let gray = SKSpriteNode(color: UIColor(#colorLiteral(red: 0.4127599895, green: 0.4127599895, blue: 0.4127599895, alpha: 0.3628932119)), size: CGSize(width: Shared.screenBounds.width, height: Shared.screenBounds.height))
        gray.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        gray.position = CGPoint(x: Shared.screenBounds.midX, y: Shared.screenBounds.midY)
        gray.alpha = 0
        self.addChild(gray)
        gray.run(.sequence([
            .fadeIn(withDuration: 0.3),
            .wait(forDuration: 3),
            .fadeOut(withDuration: 0.3),
            .removeFromParent()
        ]))
        
        //yellow light animation
        let light = SKSpriteNode(imageNamed: "yellowLight")
        light.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        light.position = CGPoint(x: Shared.screenBounds.midX, y: Shared.screenBounds.midY)
        light.setScale(2.1)
        light.alpha = 0
        self.addChild(light)
        light.run(.sequence([
            .wait(forDuration: 0.3),
            .fadeIn(withDuration: 0.35)
        ]))
        light.run(.sequence([
            .wait(forDuration: 0.3),
            .rotate(byAngle: 6, duration: 3),
            .fadeOut(withDuration: 0.3),
            .removeFromParent()
        ]))
        
        //watermelon animation
        let watermelon = SKSpriteNode(imageNamed: Image.watermelon.imageName)
        watermelon.position = contactPoint
        watermelon.setScale(0)
        self.addChild(watermelon)
        watermelon.run(.sequence([
            .move(to: CGPoint(x: Shared.screenBounds.midX, y: Shared.screenBounds.midY), duration: 0.2),
            .wait(forDuration: 3.2),
            .move(to: contactPoint, duration: 0.2),
            .removeFromParent()
        ]))
        watermelon.run(.sequence([
            .scale(to: 0.65, duration: 0.2),
            .scale(to: 0.55, duration: 0.1),
            .wait(forDuration: 3.1),
            .scale(to: Fruit.fruitScale, duration: 0.2)
        ]))
    }
    
    private func startFruitsChecking()
    {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true)
        {
            (timer) in
            
            if self.redLineShowing
            {
                var count: Int = 0
                for fruit in self.fruitsOnScene
                {
                    if fruit.position.y < self.warningHeight
                    {
                        count += 1
                    }
                    else if (fruit.position.y + fruit.size.height * 0.5) >= self.redLineHeight
                    {
                        self.endGame()
                        return
                    }
                }
                
                if count == self.fruitsOnScene.count
                {
                    self.hideRedLine()
                }
            }
            else
            {
                for fruit in self.fruitsOnScene
                {
                    if fruit.position.y >= self.warningHeight
                    {
                        self.showRedLine()
                        break
                    }
                }
            }
        }
    }
    
    func showRedLine()
    {
        self.redLineShowing = true
        self.redLine.run(.repeatForever(.sequence([
            .fadeIn(withDuration: 0.4),
            .fadeOut(withDuration: 0.4),
            .wait(forDuration: 0.3)
        ])))
    }
    
    func hideRedLine()
    {
        self.redLineShowing = false
        self.redLine.removeAllActions()
        self.redLine.alpha = 0
    }
    
    func endGame()
    {
        self.isGameOver = true
        self.touchControlEnabled = false
        self.fruitsOnScene.forEach { $0.canMerge = false }
        Utilities.notificationFeedback_error()
        
        if self.currentFtuit != nil
        {
            self.currentFtuit.removeAllActions()
            self.currentFtuit.removeFromParent()
            self.currentFtuit = nil
        }
        
        self.destroyLastAddedFruit()
        self.run(.sequence([
            .wait(forDuration: 3),
            .run
            {
                self.currentScore = 0
                self.spriteGenerator.generateFruitCount = 0
                self.spriteGenerator.generateRandomFruit()
                self.isGameOver = false
                self.touchControlEnabled = true
            }
        ]))
    }
    
    func destroyLastAddedFruit()
    {
        if let fruit = self.fruitsOnScene.popLast()
        {
            self.run(.sequence([
                .wait(forDuration: self.destroyFruitInterval),
                .run
                {
                    fruit.removeAllActions()
                    fruit.run(.sequence([
                        .scale(to: 0, duration: 0.15),
                        .removeFromParent(),
                        .run
                        {
                            Utilities.impactFeedback_soft()
                            self.destroyLastAddedFruit()
                        }
                    ]))
                    fruit.runAction_splash(at: fruit.position, in: self)
                }
            ]))
        }
        else { return }
    }
}
