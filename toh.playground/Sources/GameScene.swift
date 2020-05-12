import SwiftUI
import SpriteKit


struct GameScene:UIViewRepresentable{
    
    let discs:Int
    
    let scene = Scene()
    
    func makeUIView(context: Context) -> SKView {
        let view = SKView(frame: .zero)
        scene.initializeDiscCount(discs)
        view.preferredFramesPerSecond = 60
        view.showsFPS = true
        view.showsNodeCount = true
        
        return view
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {
        
        scene.scaleMode = .resizeFill
        uiView.presentScene(scene)
        
    }
}


