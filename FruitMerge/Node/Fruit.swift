import Foundation
import SpriteKit


enum FruitInfo: Int, CaseIterable
{
    case grape = 0
    case cherry = 1
    case tangerine = 2
    case lemon = 3
    case kiwi = 4
    case tomato = 5
    case peach = 6
    case pineapple = 7
    case coconut = 8
    case halfWatermelon = 9
    case watermelon = 10
    
    var score: Int
    {
        switch self
        {
            case .grape:
                return 1
            case .cherry:
                return 2
            case .tangerine:
                return 3
            case .lemon:
                return 4
            case .kiwi:
                return 5
            case .tomato:
                return 6
            case .peach:
                return 7
            case .pineapple:
                return 8
            case .coconut:
                return 9
            case .halfWatermelon:
                return 10
            case .watermelon:
                return 0
        }
    }
    
    var textureImageName: String
    {
        switch self
        {
            case .grape:
                return Image.grape.imageName
            case .cherry:
                return Image.cherry.imageName
            case .coconut:
                return Image.coconut.imageName
            case .halfWatermelon:
                return Image.halfWatermelon.imageName
            case .kiwi:
                return Image.kiwi.imageName
            case .lemon:
                return Image.lemon.imageName
            case .tangerine:
                return Image.tangerine.imageName
            case .tomato:
                return Image.tomato.imageName
            case .watermelon:
                return Image.watermelon.imageName
            case .peach:
                return Image.peach.imageName
            case .pineapple:
                return Image.pineapple.imageName
        }
    }
    
    var splashImageName: String
    {
        switch self
        {
            case .grape:
                return Image.purplePiece.imageName
            case .cherry:
                return Image.redPiece.imageName
            case .tangerine:
                return Image.orangePiece.imageName
            case .lemon:
                return Image.yellowPiece.imageName
            case .kiwi:
                return Image.greenPiece.imageName
            case .tomato:
                return Image.redPiece.imageName
            case .peach:
                return Image.yellow_orangePiece.imageName
            case .pineapple:
                return Image.yellowPiece.imageName
            case .coconut:
                return Image.whitePiece.imageName
            case .halfWatermelon:
                return Image.redPiece.imageName
            case .watermelon:
                return ""
        }
    }
    
    var splashColor: UIColor
    {
        switch self
        {
            case .grape:
                return UIColor.purple
            case .cherry:
                return UIColor.red
            case .tangerine:
                return UIColor.orange
            case .lemon:
                return UIColor.yellow
            case .kiwi:
                return UIColor.green
            case .tomato:
                return UIColor.red
            case .peach:
                return UIColor.orange
            case .pineapple:
                return UIColor.yellow
            case .coconut:
                return UIColor.white
            case .halfWatermelon:
                return UIColor.red
            case .watermelon:
                return UIColor.clear
        }
    }
    
    var index: Int
    {
        return rawValue
    }
    
    var name: String
    {
        switch self
        {
            case .grape:
                return "grape"
            case .cherry:
                return "cherry"
            case .coconut:
                return "coconut"
            case .halfWatermelon:
                return "halfWatermelon"
            case .kiwi:
                return "kiwi"
            case .lemon:
                return "lemon"
            case .tangerine:
                return "tangerine"
            case .tomato:
                return "tomato"
            case .watermelon:
                return "watermelon"
            case .peach:
                return "peach"
            case .pineapple:
                return "pineapple"
        }
    }
    
    var categoryBitMask: UInt32
    {
        switch self
        {
            case .grape:
                return 1 << 0
            case .cherry:
                return 1 << 1
            case .coconut:
                return 1 << 2
            case .halfWatermelon:
                return 1 << 3
            case .kiwi:
                return 1 << 4
            case .lemon:
                return 1 << 5
            case .tangerine:
                return 1 << 6
            case .tomato:
                return 1 << 7
            case .watermelon:
                return 1 << 8
            case .peach:
                return 1 << 9
            case .pineapple:
                return 1 << 10
        }
    }
}


class Fruit: SKSpriteNode
{
    static let fruitScale: Double = 0.57
    var fruitInfo: FruitInfo!
    var canMerge = true
    var registered = false
    var merged = false
    
    init(type: FruitInfo, merged: Bool)
    {
        let texture = SKTexture(imageNamed: type.textureImageName)
        
        super.init(texture: texture, color: .clear, size: texture.size())
        
        self.name = type.name
        self.merged = merged
        
        self.fruitInfo = type
        
        self.physicsBody = SKPhysicsBody(circleOfRadius: self.size.height * 0.5)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = type.categoryBitMask
        self.physicsBody?.contactTestBitMask = 0xFFFFFFFF
        self.physicsBody?.restitution = 0.05
        self.physicsBody?.linearDamping = 0.5
        self.physicsBody?.angularDamping = 0.95
        self.physicsBody?.friction = 0.4
        self.physicsBody?.density = 0.5
    
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.setScale(Fruit.fruitScale)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func runAction_splash(at point: CGPoint, in scene: SKScene)
    {
        let ratio = pow((self.size.width / 50), 2)
        let baseNumber = Int(ratio * 15)
        let offset = Int(ratio * 3)
        let number = Int.random(in: (baseNumber - offset)...(baseNumber + offset))
        
        for _ in 0...number
        {
            let splash = SKSpriteNode(imageNamed: self.fruitInfo.splashImageName)
            let fromPoint = Utilities.getRandomPointInCircle(center: point, outerRadius: self.size.width * 0.5)
            let toPoint = Utilities.getRandomPointInCircle(center: point, outerRadius: self.size.width * 0.9, inerRadius: self.size.width * 0.5)
            let duration = CGFloat.random(in: 0.1...0.2)
            let scale = CGFloat.random(in: 0.3...0.5)
            let fromRotation = CGFloat.random(in: 0...(2 * CGFloat.pi))
            let toRotation = CGFloat.random(in: 0...(2 * CGFloat.pi))
            
            splash.setScale(scale)
            splash.zRotation = fromRotation
            splash.position = fromPoint
            scene.addChild(splash)
            
            splash.run(.sequence([
                .wait(forDuration: 0.05),
                .run
                {
                    splash.run(.move(to: toPoint, duration: duration))
                    splash.run(.rotate(toAngle: toRotation, duration: duration))
                    splash.run(.sequence([
                        .wait(forDuration: 0.1),
                        .fadeAlpha(to: 0.2, duration: 0.25),
                        .fadeAlpha(to: 0, duration: 0.35),
                        .removeFromParent()
                    ]))
                    splash.run(.moveBy(x: 0, y: -CGFloat.random(in: 12...28), duration: 0.5))
                }
            ]))
        }
    }
}


class Grape: Fruit
{
    init(merged: Bool)
    {
        super.init(type: FruitInfo.grape, merged: merged)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}


class Cherry: Fruit
{
    init(merged: Bool)
    {
        super.init(type: FruitInfo.cherry, merged: merged)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}


class Tangerine: Fruit
{
    init(merged: Bool)
    {
        super.init(type: FruitInfo.tangerine, merged: merged)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}


class Lemon: Fruit
{
    init(merged: Bool)
    {
        super.init(type: FruitInfo.lemon, merged: merged)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}


class Kiwi: Fruit
{
    init(merged: Bool)
    {
        super.init(type: FruitInfo.kiwi, merged: merged)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}


class Tomato: Fruit
{
    init(merged: Bool)
    {
        super.init(type: FruitInfo.tomato, merged: merged)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}


class Peach: Fruit
{
    init(merged: Bool)
    {
        super.init(type: FruitInfo.peach, merged: merged)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}


class Pineapple: Fruit
{
    init(merged: Bool)
    {
        super.init(type: FruitInfo.pineapple, merged: merged)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}


class Coconut: Fruit
{
    init(merged: Bool)
    {
        super.init(type: FruitInfo.coconut, merged: merged)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}


class HalfWatermelon: Fruit
{
    init(merged: Bool)
    {
        super.init(type: FruitInfo.halfWatermelon, merged: merged)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}


class Watermelon: Fruit
{
    init(merged: Bool)
    {
        super.init(type: FruitInfo.watermelon, merged: merged)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}
