import Foundation
import SpriteKit


class Utilities
{
    static let impactFeedbackGenerator_heavy = UIImpactFeedbackGenerator(style: .heavy)
    static let impactFeedbackGenerator_rigid = UIImpactFeedbackGenerator(style: .rigid)
    static let impactFeedbackGenerator_soft = UIImpactFeedbackGenerator(style: .soft)
    static let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
    
    
    static func impactFeedback_heavy(intensity: CGFloat = 1.0)
    {
        Utilities.impactFeedbackGenerator_heavy.impactOccurred(intensity: intensity)
    }
    
    static func impactFeedback_rigid(intensity: CGFloat = 1.0)
    {
        Utilities.impactFeedbackGenerator_rigid.impactOccurred(intensity: intensity)
    }
    static func impactFeedback_soft(intensity: CGFloat = 1.0)
    {
        Utilities.impactFeedbackGenerator_soft.impactOccurred(intensity: intensity)
    }
    
    static func notificationFeedback_success()
    {
        Utilities.notificationFeedbackGenerator.notificationOccurred(.success)
    }
    
    static func notificationFeedback_warning()
    {
        Utilities.notificationFeedbackGenerator.notificationOccurred(.warning)
    }
    
    static func notificationFeedback_error()
    {
        Utilities.notificationFeedbackGenerator.notificationOccurred(.error)
    }
    
    static func getNumberNode(from number: String, anchor_x centeredHorizontally: Bool = false, anchor_y centeredVertically: Bool = false) -> SKNode
    {
        let numberNode = SKNode()
        var width: Double = 0
        let height: Double = 40
        
        for character in number
        {
            var characterNode = SKSpriteNode()
            characterNode.anchorPoint = CGPoint(x: 0, y: 0)
            characterNode.position = CGPoint(x: width, y: 0)
            
            if character == "0"
            {
                characterNode.texture = SKTexture(imageNamed: Image.number0.imageName)
                characterNode.size.width = 26
                characterNode.size.height = 40
            }
            else if character == "1"
            {
                characterNode.texture = SKTexture(imageNamed: Image.number1.imageName)
                characterNode.size.width = 27
                characterNode.size.height = 40
            }
            else if character == "2"
            {
                characterNode.texture = SKTexture(imageNamed: Image.number2.imageName)
                characterNode.size.width = 27.5
                characterNode.size.height = 40
            }
            else if character == "3"
            {
                characterNode.texture = SKTexture(imageNamed: Image.number3.imageName)
                characterNode.size.width = 29.5
                characterNode.size.height = 40
            }
            else if character == "4"
            {
                characterNode.texture = SKTexture(imageNamed: Image.number4.imageName)
                characterNode.size.width = 28.4
                characterNode.size.height = 40
            }
            else if character == "5"
            {
                characterNode.texture = SKTexture(imageNamed: Image.number5.imageName)
                characterNode.size.width = 29
                characterNode.size.height = 40
            }
            else if character == "6"
            {
                characterNode.texture = SKTexture(imageNamed: Image.number6.imageName)
                characterNode.size.width = 28
                characterNode.size.height = 40
            }
            else if character == "7"
            {
                characterNode.texture = SKTexture(imageNamed: Image.number7.imageName)
                characterNode.size.width = 28.5
                characterNode.size.height = 40
            }
            else if character == "8"
            {
                characterNode.texture = SKTexture(imageNamed: Image.number8.imageName)
                characterNode.size.width = 30
                characterNode.size.height = 40
            }
            else if character == "9"
            {
                characterNode.texture = SKTexture(imageNamed: Image.number9.imageName)
                characterNode.size.width = 28
                characterNode.size.height = 40
            }
            else
            {
                characterNode = SKSpriteNode()
            }
            
            numberNode.addChild(characterNode)
            width += characterNode.size.width
        }
        
        
        if centeredVertically
        {
            if centeredHorizontally
            {
                let node = SKNode()
                numberNode.position = CGPoint(x: -width / 2, y: -height / 2)
                node.addChild(numberNode)
                return node
            }
            else
            {
                let node = SKNode()
                numberNode.position = CGPoint(x: 0, y: -height / 2)
                node.addChild(numberNode)
                return node
            }
        }
        else
        {
            if centeredHorizontally
            {
                let node = SKNode()
                numberNode.position = CGPoint(x: -width / 2, y: 0)
                node.addChild(numberNode)
                return node
            }
            else
            {
                return numberNode
            }
        }
    }
    
    static func getRandomPointInCircle(center: CGPoint, outerRadius: CGFloat, inerRadius: CGFloat = 0) -> CGPoint
    {
        //get random angle
        let randomAngle = CGFloat.random(in: (-2 * CGFloat.pi)...(2 * CGFloat.pi))
        //get random radius
        let randomRadius = CGFloat.random(in: inerRadius...outerRadius)
        //get random point
        let randomX = randomRadius * cos(randomAngle)
        let randomY = randomRadius * sin(randomAngle)
        //return final point
        return CGPoint(x: (center.x + randomX), y: (center.y + randomY))
    }
}


enum Image: String
{
    case greenPiece = "Explode/greenpiece"
    case orangePiece = "Explode/orangepiece"
    case purplePiece = "Explode/purplepiece"
    case redPiece = "Explode/redpiece"
    case yellowPiece = "Explode/yellowpiece"
    case whitePiece = "Explode/whitepiece"
    case yellow_orangePiece = "Explode/yellow_orangepiece"
    
    case purpleSplash = "Explode/purple"
    case yellowSplash = "Explode/yellow"
    
    case grape = "Fruit/grape"
    case cherry = "Fruit/cherry"
    case coconut = "Fruit/coconut"
    case halfWatermelon = "Fruit/halfwatermelon"
    case kiwi = "Fruit/kiwi"
    case lemon = "Fruit/lemon"
    case tangerine = "Fruit/tangerine"
    case tomato = "Fruit/tomato"
    case watermelon = "Fruit/watermelon"
    case peach = "Fruit/peach"
    case pineapple = "Fruit/pineapple"
    
    case number0 = "number/0"
    case number1 = "number/1"
    case number2 = "number/2"
    case number3 = "number/3"
    case number4 = "number/4"
    case number5 = "number/5"
    case number6 = "number/6"
    case number7 = "number/7"
    case number8 = "number/8"
    case number9 = "number/9"
    
    
    var imageName: String
    {
        return rawValue
    }
}


enum Sound: String
{
    case bomb = "bomb.mp3"
    case fallsDown = "fallsDown.mp3"
    case win = "win.mp3"
    
    var fileName: String
    {
        return rawValue
    }
}

enum CategoryBitMask
{
    case wall_ground
    case wall_bounds
    
    var uint32: UInt32
    {
        switch self
        {
            case .wall_ground:
                return 1 << 31
            case .wall_bounds:
                return 1 << 30
        }
    }
}
