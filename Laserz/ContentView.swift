//
//  ContentView.swift
//  Laserz
//
//  Created by Tim Randall on 28/4/22.
//

import SwiftUI
import SpriteKit

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

class GameScene: SKScene {
    let player = SKSpriteNode(color: SKColor.green, size: CGSize(width: 20, height: 20))
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        player.position = CGPoint(x: size.width * 0.5, y: 0)
        addChild(player)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // makes sure that if there are multiple touches, any but the first one will end this function
        guard let touch = touches.first else {
            return
          }
        // puts a laser (blue square) at the same place as the player (green square)
        let laser = SKSpriteNode(color: SKColor.blue, size: CGSize(width: 5, height: 5))
        laser.position = player.position
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
}
