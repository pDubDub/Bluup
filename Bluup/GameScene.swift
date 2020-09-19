//
//  GameScene.swift
//  Bluup
//
//  Created by Patrick Wheeler on 9/11/20.
//  Copyright © 2020 Patrick Wheeler. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?

    let sub = SKSpriteNode(imageNamed: "yellowSub400")

    var backgroundBrightness: CGFloat = 0.5
    var backgroundHue: CGFloat = 0.5

    override func didMove(to view: SKView) {
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        label?.zPosition = 5
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }

        self.backgroundColor = UIColor(hue: backgroundHue, saturation: 0.5, brightness: backgroundBrightness, alpha: 1.0)
            // this works to set background color of scene.
            // TODO - next would be to use touches to see if we can change it by touch.
            // Note, in this model, we would need to overlap any surface waves on top of the scene, as opposed to previous thought of adjusting the top
            //    edge of water. Don't think I can move the top edge of scene.

        sub.anchorPoint = CGPoint(x: 0.5, y: 0.5)
//        sub.position = CGPoint(x: self.size.width,
//                               y: self.size.height)
        sub.position = CGPoint(x: self.size.width/4, y: self.size.height/2 + sub.size.height/2)
        // Something about the template GameScene sets the origin of the scene 0,0 at the center of the screen.
//        print("Screen width is \(self.size.width) by \(self.size.height)")

        sub.setScale(0.5)
        sub.zPosition = 1
        sub.zRotation = 0.25
        addChild(sub)
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered

        backgroundBrightness -= 0.00025
        backgroundHue += 0.00015
        self.backgroundColor = UIColor(hue: backgroundHue, saturation: 0.5, brightness: backgroundBrightness, alpha: 1.0)
        sub.position.x -= 0.3
        sub.position.y -= 1
    }
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
//            print(n.position.x)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    

}
