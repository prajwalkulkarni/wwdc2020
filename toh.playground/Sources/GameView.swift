import SwiftUI


struct GameView:View{
    var discCount:Int
    var body:some View{
        
        GameScene(discs:discCount)
    }
}

