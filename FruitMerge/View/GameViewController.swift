import UIKit
import SpriteKit


class GameViewController: UIViewController
{
    override func loadView()
    {
        let skView = SKView(frame: Shared.screenBounds)
        self.view = skView

        let mainScene = MainScene()
        mainScene.anchorPoint = CGPoint(x: 0, y: 0)
        mainScene.size = CGSize(width: Shared.screenBounds.width, height: Shared.screenBounds.height)

        skView.presentScene(mainScene)
        
        skView.ignoresSiblingOrder = false
        skView.insetsLayoutMarginsFromSafeArea = false
        skView.isMultipleTouchEnabled = false
    }

    override var shouldAutorotate: Bool
    {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask
    {
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            return .allButUpsideDown
        }
        else
        {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool
    {
        return true
    }
}
