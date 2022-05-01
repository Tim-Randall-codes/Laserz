//
//  ContentView.swift
//  Laserz
//
//  Created by Tim Randall on 28/4/22.
//

import SwiftUI
import SpriteKit

var hit: Int = 0
var miss: Int = 0

struct ContentView: View {
    var scene: SKScene {
            let scene = GameScene()
            scene.size = CGSize(width: 300, height: 400)
            scene.scaleMode = .fill
            return scene
        }
    var body: some View {
        SpriteView(scene: scene).ignoresSafeArea()
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate { // makes the class conform to the SKPCD
    let player = SKSpriteNode(color: SKColor.green, size: CGSize(width: 20, height: 20))
    var hitLabel:SKLabelNode!
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self // this applies the contact delegate to an instance of this game scene
        backgroundColor = SKColor.black
        player.position = CGPoint(x: size.width * 0.5, y: 0)
        addChild(player)
        hitLabel = SKLabelNode(fontNamed: "Chalkduster")
        hitLabel.text = "Hits: \(hit)"
        hitLabel.fontSize = 16
        hitLabel.position = CGPoint(x: 50, y: 40)
        self.addChild(hitLabel)
        // runs the addStar function at regular interval
        run(SKAction.repeatForever(
              SKAction.sequence([
                SKAction.run(addStar),
                SKAction.wait(forDuration: 0.4)
                ])))
        run(SKAction.repeatForever(
              SKAction.sequence([
                SKAction.run(addAsteroid),
                SKAction.wait(forDuration: 1.0)
                ])))
    }
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "asteroid" {
            collisionBetween(asteroid: contact.bodyA.node!, object: contact.bodyB.node!)
        }
        else if contact.bodyB.node?.name == "asteroid" {
            collisionBetween(asteroid: contact.bodyB.node!, object: contact.bodyA.node!)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // makes sure that if there are multiple touches, any but the first one will end this function
        guard let touch = touches.first else {
            return
          }
        // puts a laser (blue square) at the same place as the player (green square)
        let laser = SKSpriteNode(color: SKColor.blue, size: CGSize(width: 5, height: 5))
        laser.position = player.position
        laser.physicsBody = SKPhysicsBody(rectangleOf: laser.size)
        addChild(laser)
        // moves the laser through place where the user touches
        let touchLocation = touch.location(in: self)
        let distanceFromPlayerX = player.position.x - touchLocation.x
        let distanceFromPlayerY = touchLocation.y - player.position.y
        let placeToThrow = CGPoint(x: -2000 * (distanceFromPlayerX / distanceFromPlayerY), y: 2500)
        let actionMove = SKAction.move(to: placeToThrow, duration: 1.0)
        let actionMoveDone = SKAction.removeFromParent()
        laser.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    func addStar(){
        //creates star at the random point on the x axis.
        let randomStarSize = Int.random(in: 1...2)
        let star = SKShapeNode(circleOfRadius: CGFloat(randomStarSize))
        star.fillColor = .gray
        star.name = "star"
        let randomX = Int.random(in: 1..<301)
        star.position = CGPoint(x: randomX, y: 400)
        addChild(star)
        // moves the stars down the screen so it looks like you are moving
        let actionMove = SKAction.move(to: CGPoint(x: star.position.x, y: 0), duration: TimeInterval(15.0))
        let actionMoveDone = SKAction.removeFromParent()
        star.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    func addAsteroid(){
        // create asteroid at random part of the x axis
        let asteroid = SKShapeNode(circleOfRadius: CGFloat(10))
        asteroid.fillColor = .orange
        asteroid.name = "asteroid"
        let randomX = Int.random(in: 1..<301)
        asteroid.position = CGPoint(x: randomX, y: 800)
        asteroid.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(10)) // applies physics to the asteroid.
        asteroid.physicsBody?.isDynamic = false // this keeps the asteroid from moving when it is hit
        asteroid.physicsBody!.contactTestBitMask = asteroid.physicsBody!.collisionBitMask // every collision that this object has will be communicated.
        addChild(asteroid)
        // moves the asteroid down the screen
        let actionMove = SKAction.move(to: CGPoint(x: asteroid.position.x, y: 0), duration: TimeInterval(10.0))
        let actionMoveDone = SKAction.removeFromParent()
        asteroid.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    func collisionBetween(asteroid: SKNode, object: SKNode) {
        if object.name == "star" {
            return
        }
        else {
            hit += 1
            hitLabel.text = "Hits: \(hit)"
            asteroid.removeFromParent()
        }
    }
}
