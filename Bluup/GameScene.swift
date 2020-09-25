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

    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    var lastBubbleTime: TimeInterval = 0

    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?

    let sub = SKSpriteNode(imageNamed: "yellowSub400")
    var depth: Int = 0

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
        sub.position = CGPoint(x: self.size.width/2.2, y: self.size.height/2 + sub.size.height/2)
        // scene.anchorPosition of the template GameScene sets the origin of the scene 0,0 at the center of the screen.
//        print("Screen width is \(self.size.width) by \(self.size.height)")

        sub.setScale(0.5)
        sub.zPosition = 1
        sub.zRotation = 0.25

        // .color and .colorBlendFactor allow us to gradually remove red color from sub at deeper waters.
        sub.color = UIColor(red: 0.0, green: 0.5, blue: 0.5, alpha: 0.8)
        sub.colorBlendFactor = 0
        addChild(sub)
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered

        backgroundBrightness -= 0.00025
        backgroundHue += 0.00015
        self.backgroundColor = UIColor(hue: backgroundHue, saturation: 0.5, brightness: backgroundBrightness, alpha: 1.0)
        if sub.position.y < 0 {
            sub.colorBlendFactor = -sub.position.y / 1000
        }
        sub.position.x -= 0.5
        sub.position.y -= 1

        // TODO - make sub stop just below edge of screen, preferably center.x, with bubbles continuing
        /*
            We will then give instruction to swipe up to surface.
            In fact, you could swipe up before he hits the bottom to hurry things up.
            As we surface, we get color changes until we reach the surface, and add the waves.
            I kind of feel like I need to master cameraNode before moving forward.
         */
        if !(sub.position.y > size.height/2) && !(sub.position.y < -size.height/2) {
            if (currentTime - lastBubbleTime) > 0.25 {     // every 1 second
            //            print("current \(currentTime) minus \(lastBubbleTime) ")
//                        print("Bluup \(sub.position.y)")
                        lastBubbleTime = currentTime
                        spawnBubble()
            }
        }


    }

    func spawnBubble() {

        let bubbleSize: CGFloat = CGFloat.random(in: 8 ... 12)      // varying sized bubbles!
        let bubble = SKShapeNode.init(circleOfRadius: bubbleSize)
        bubble.lineWidth = 1.0
        bubble.position = sub.position
        addChild(bubble)

        let squish = SKAction.scaleX(to: 1.2, y: 0.6, duration: 0.05)       // wobbling between circle and ellipse
        let stretch = SKAction.scaleX(to: 1.0, y: 0.9, duration: 0.05)
        let fullSquishLoop = SKAction.sequence([squish, stretch])

        // this wiggleSet gives randomized set of lateral wobble
//        let wiggle = SKAction.moveBy(x: CGFloat.random(in: -10 ... 10), y: 0, duration: 0.2)
        let wiggleSet = SKAction.sequence([
            SKAction.moveBy(x: CGFloat.random(in: -10 ... 10), y: 0, duration: 0.2),
            squish,
            SKAction.moveBy(x: CGFloat.random(in: -10 ... 10), y: 0, duration: 0.2),
            stretch,
            SKAction.moveBy(x: CGFloat.random(in: -10 ... 10), y: 0, duration: 0.2),
            squish,
            SKAction.moveBy(x: CGFloat.random(in: -10 ... 10), y: 0, duration: 0.2),
            stretch
        ])

        // the group allows the bubble to do both animations simultaneously
        let group = SKAction.group([fullSquishLoop, wiggleSet])
        bubble.run(SKAction.repeatForever(group))                       // bubble behavior is seperate from upward float

        // TODO - would like to make collding bubbles merge
        let move = SKAction.moveBy(x: 0, y: 3000, duration: (TimeInterval(8 * (10 / bubbleSize))))      //  larger bubbles go faster

        let remove = SKAction.removeFromParent()
        bubble.run(SKAction.sequence([move, remove]))

        // If we one day want to get really tricksie, real world bubble both move faster and get larger as they rise from the depths.
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
