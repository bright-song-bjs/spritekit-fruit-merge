import Foundation
import SpriteKit
import SwiftUI


class SpriteGenerator
{
    unowned var mainSene: MainScene
    
    let grapeProportion = 105
    let cherryProportion = 94
    let tangerineProportion = 112
    let lemonProportion = 89
    let kiwiProportion = 100
    
    var grapeThreshold: Double!
    var cherryThreshold: Double!
    var tangerineThreshold: Double!
    var lemonThreshold: Double!
    var generateFruitCount: Int = 0
    
    
    init(mainScene: MainScene)
    {
        let totalProportion = self.grapeProportion + self.cherryProportion + self.tangerineProportion + self.lemonProportion + self.kiwiProportion
        
        self.mainSene = mainScene
        
        self.grapeThreshold = Double(self.grapeProportion) / Double(totalProportion)
        self.cherryThreshold = Double(self.cherryProportion) / Double(totalProportion) + self.grapeThreshold
        self.tangerineThreshold = Double(self.tangerineProportion) / Double(
            totalProportion) + self.cherryThreshold
        self.lemonThreshold = Double(self.lemonProportion) / Double(totalProportion) + self.tangerineThreshold
    }
    
    func generateRandomFruit()
    {
        self.mainSene.touchControlEnabled = false
        self.generateFruitCount += 1
        
        switch self.generateFruitCount
        {
            case 1...3:
                self.mainSene.currentFtuit = Grape(merged: false)
            
            case 4:
                self.mainSene.currentFtuit = Cherry(merged: false)
            
            case 5:
                self.mainSene.currentFtuit = Tangerine(merged: false)
            
            default:
                let random = Double.random(in: 0...1)
                
                if random < self.grapeThreshold
                {
                    self.mainSene.currentFtuit = Grape(merged: false)
                }
                else if random < self.cherryThreshold
                {
                    self.mainSene.currentFtuit = Cherry(merged: false)
                }
                else if random < self.tangerineThreshold
                {
                    self.mainSene.currentFtuit = Tangerine(merged: false)
                }
                else if random < self.lemonThreshold
                {
                    self.mainSene.currentFtuit = Lemon(merged: false)
                }
                else
                {
                    self.mainSene.currentFtuit = Kiwi(merged: false)
                }
        }
        
        self.mainSene.currentFtuit.position = CGPoint(x: self.mainSene.currentFruitPosition.x, y: Shared.screenBounds.height * 1.3)
        
        self.mainSene.addChild(self.mainSene.currentFtuit)
        
        self.mainSene.currentFtuit.run(.sequence([
            .moveTo(y: (self.mainSene.currentFruitPosition.y - 20), duration: 0.4),
            .moveBy(x: 0, y: 30, duration: 0.15),
            .moveBy(x: 0, y: -10, duration: 0.1),
            .run
            {
                self.mainSene.touchControlEnabled = true
            }
        ]))
    }
    
    func mergeFruit(nodeA: SKNode, nodeB: SKNode, contactPoint: CGPoint)
    {
        guard let fruitA = nodeA as? Fruit else { return }
        guard let fruitB = nodeB as? Fruit else { return }
        if fruitA.fruitInfo != fruitB.fruitInfo { return }
        if fruitA.fruitInfo == FruitInfo.watermelon { return }
        if !fruitA.canMerge { return }
        
        //update score
        self.mainSene.currentScore += fruitA.fruitInfo.score
        
        //previous fruits disappear animation
        self.runAction_previousFruitsDisappear(fruitA: fruitA, fruitB: fruitB, at: contactPoint)
        
        //generate new fruit
        if fruitA.fruitInfo == FruitInfo.halfWatermelon
        {
            self.mainSene.physicsWorld.speed = 0
            self.mainSene.touchControlEnabled = false
            self.mainSene.runAction_matermelonMerged(at: contactPoint)
            Utilities.notificationFeedback_success()
            
            self.mainSene.run(.sequence([
                .wait(forDuration: 3.6),
                .run
                {
                    self.mainSene.physicsWorld.speed = 1
                    self.mainSene.touchControlEnabled = true
                    
                    let watermelon = Watermelon(merged: true)
                    watermelon.position = contactPoint
                    watermelon.physicsBody?.affectedByGravity = true
                    self.mainSene.addChild(watermelon)
                    self.mainSene.fruitsOnScene.append(watermelon)
                    self.mainSene.currentScore += 100
                }
            ]))
        }
        else
        {
            var newFruit: Fruit!
            switch fruitA.fruitInfo
            {
                case .grape:
                    newFruit = Cherry(merged: true)
                case .cherry:
                    newFruit = Tangerine(merged: true)
                case .tangerine:
                    newFruit = Lemon(merged: true)
                case .lemon:
                    newFruit = Kiwi(merged: true)
                case .kiwi:
                    newFruit = Tomato(merged: true)
                case .tomato:
                    newFruit = Peach(merged: true)
                case .peach:
                    newFruit = Pineapple(merged: true)
                case .pineapple:
                    newFruit = Coconut(merged: true)
                case .coconut:
                    newFruit = HalfWatermelon(merged: true)
                default: break
            }
        
            //new fruit pops up animation
            newFruit.setScale(0)
            newFruit.position = contactPoint
            self.mainSene.addChild(newFruit)
            self.mainSene.fruitsOnScene.append(newFruit)
            newFruit.run(.sequence([
                .wait(forDuration: 0.2),
                .scale(to: Fruit.fruitScale, duration: 0.12)
            ]))
            newFruit.run(.sequence([
                .wait(forDuration: 0.26),
                .run
                {
                    newFruit.physicsBody?.affectedByGravity = true
                }
            ]))
        }
    }
    
    private func runAction_previousFruitsDisappear(fruitA: Fruit, fruitB: Fruit, at contactPoint: CGPoint)
    {
        //fruitA disappear
        fruitA.physicsBody = nil
        self.mainSene.fruitsOnScene.remove(
            at: self.mainSene.fruitsOnScene.firstIndex(of: fruitA)!)
        fruitA.run(.sequence([
            .scale(to: 0, duration: 0.2),
            .removeFromParent()
        ]))
        fruitA.run(.move(to: contactPoint, duration: 0.05))
        
        //fruitB disappear
        fruitB.physicsBody = nil
        self.mainSene.fruitsOnScene.remove(
            at: self.mainSene.fruitsOnScene.firstIndex(of: fruitB)!)
        fruitB.run(.sequence([
            .scale(to: 0, duration: 0.2),
            .removeFromParent()
        ]))
        fruitB.run(.move(to: contactPoint, duration: 0.05))
        
        //splash animation
        fruitA.runAction_splash(at: contactPoint, in: self.mainSene)
    }
}
