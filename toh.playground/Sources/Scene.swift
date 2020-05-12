import SwiftUI
import SpriteKit


//infix operator '^^' to evaluate 2^n
precedencegroup PowerPrecedence { higherThan :MultiplicationPrecedence }
infix operator ^^ : PowerPrecedence

func ^^(radix:Int,power: Int) -> Int{
    return Int(pow(Double(radix), Double(power))) - 1
}

public class Scene: SKScene,ObservableObject{
    
    
    var discCount:Int = 0
    static let bgColor = UIColor(red:0.95, green:0.89, blue:0.89, alpha:1.0)
    static let shared = Scene()
    var pegs:[Peg]!
    var disc:[Disc]!
    var flag:Int = 0
    var from:Int = 0
    var labelValue:Int = 0
    var yCoordinate:CGFloat? = nil
    var pegBaseOrigin:[CGPoint]? = nil
    var sizeToNumber:[Int:Int] = [:]
    var moveDisc:Bool = false
    var gameOver:Bool = false
    var restartInitialSetup:Bool = false
    var hintButton:SKLabelNode? = nil
    var restartLabel:SKLabelNode? = nil
    //var undoLabel:SKLabelNode? = nil
    var trackMoves:Int = 0
    var arr:[[Int]] = []
    let bg = SKSpriteNode(imageNamed: "background")
    
    //notify changes to variables subscribed to ObservedObject.
    @Published var counter = 0
    @Published var showHint = false
    
    
    var emitter:CAEmitterLayer? = nil
    let population:Float = 0.8
    var active = false
    
    
    public class Disc{
        var discNode:SKShapeNode?
        var color:UIColor
        var base:Int
        var size:Int
        
        public init(color:UIColor,size:Int){
            self.color = color
            self.size = size
            self.base = 0
            self.discNode = nil
        }
        
    }

    public class Peg{
        var node: SKShapeNode
        var discStack:[Disc]
        public init(node: SKShapeNode) {
            self.node = node
            self.discStack = []
        }
    }
    
    func initializeDiscCount(_ discCount:Int) {
        self.discCount = discCount
        
        var discs = [Disc]()
        
        for i in 0..<6 {
            if i == discCount{
                break
            }
            
            discs.append(Disc(color: Colors.colors[i], size: 6-i))
            
        }
        
        self.disc = discs
        
       }
    
    
    
    //setup game scene.
    override public func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed:"gameBackground.png")
        background.position = CGPoint(x: 300, y: 200)
        background.zPosition = -1
        addChild(background)
        //self.backgroundColor = Scene.bgColor
        self.addPegs()
        self.addDiscs()
        self.setUpHintButton()
        self.restartGame()
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       
        var to:Int = 0
        let stackXPositions = Values.xPositionMultipliers.map({$0 *  Values.adjustXCoordinate * UIScreen.main.bounds.width})
        
        
        for touch in touches{
            
            let location = touch.location(in: self)
            if hintButton!.contains(location){
                if !gameOver{
                    
                    //show/hide hints.
                    Hint.towersOfHanoi(numberOfDiscs: discCount, Source: 1, Destination: 3, Auxilary: 2)
                    IntroView().toggleHintState()
                    
                    break;
                }
                
            }
            
            
            //Determine the touched peg/disc stack.
            let touchX = location.x
            var touchedStack = -1
            var minDistance:CGFloat = -1.0
            for (n,xPosition) in stackXPositions.enumerated(){
                let distance = abs(xPosition - touchX)
                if minDistance == -1 || distance < minDistance{
                    minDistance = distance
                    touchedStack = n
                    
                }
                
            }
            
            
            flag = flag + 1
           
            if flag == 1{
                
                from = touchedStack
                
                
                do{
                  let status =  try isEmpty(f: from)

                    if status{
                        let discToMove = self.pegs[from].discStack.last!
                        let discHeight = Values.discHeightFraction * UIScreen.main.bounds.height
                        let baseHeight = UIScreen.main.bounds.height * (1.0/50.0)
                        let baseYPosition = Values.baseYDistanceFraction * (view?.frame.maxY)! + baseHeight + 102.4
                        let yOffset = (CGFloat(self.pegs[from].discStack.count) * discHeight) + 1.0 * (CGFloat)(self.pegs[from].discStack.count + 2)
                        let yPosition = baseYPosition + yOffset
                        yCoordinate = (view?.frame.maxY)! - yPosition
//                        print("Distance moved:\((view?.frame.maxY)! - yPosition)")
                        let action = SKAction.moveBy(x: 0.0, y: (view?.frame.maxY)! - yPosition, duration: 2)
                        discToMove.discNode!.run(action)
                        
                    }
                }
                catch{
                    flag = 0
                    print("Empty peg")
                }
                
            }
            if flag > 1{
                to = touchedStack
                print("Move disc from\(from) to \(to)")
                
                if from != to{
                     moveDiscFromStack(from: from, to: to)
                     arr.append([from,to])
                }
                else{
                    self.pegs[from].discStack.last!.discNode!.run(SKAction.moveBy(x: 0.0, y: -yCoordinate!, duration: 2))
                }
               
                flag = 0
                from = 0
                
            }
        }
        
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            
            let touchCoordinate = touch.location(in: self)
            
            if restartLabel!.contains(touchCoordinate){
                
                removeAllChildren()
                removeAllActions()
                
                flag = 0
                from = 0
                trackMoves = 0
                IntroView().resetCounter()
                addPegs()
                initializeDiscCount(self.discCount)
                self.restartInitialSetup = true
                addDiscs()
                setUpHintButton()
                restartGame()
                let background = SKSpriteNode(imageNamed:"gameBackground.png")
                background.position = CGPoint(x: 300, y: 200)
                background.zPosition = -1
                addChild(background)
                self.restartInitialSetup = false
               
                continue
            }
            
        }
    }
    
    
    private func isEmpty(f from:Int) throws -> Bool{
        if self.pegs[from].discStack.count > 0{
            return true
        }
        else{
            throw discError.emptyPeg
        }
    }
    
   
    private func moveDiscFromStack(from fromStack:Int,to toStack:Int){
        
        let fromPeg = self.pegs[fromStack]
        let toPeg = self.pegs[toStack]
        let discToMove = fromPeg.discStack.last!
        var canMoveNode = true
        var toTopNode: Disc? = nil
        if toPeg.discStack.count > 0{
            toTopNode = toPeg.discStack.last!
            
            if toTopNode!.size < discToMove.size{
                canMoveNode = false
                
                
                let label = SKLabelNode(text: "Invalid move.")
                label.fontColor = UIColor.white
                label.fontSize = 50.0
                label.fontName = "AvenirNext-Bold"
                label.position = CGPoint(x: (view?.frame.maxX)!/2, y: (view?.frame.maxY)!/2)
                addChild(label)
                discToMove.discNode!.run(playSound(fileName: "error.mp3"))
                
                DispatchQueue.main.asyncAfter(deadline: .now()+2.0) {
                    label.removeFromParent()
                }
                
                discToMove.discNode!.run(SKAction.moveBy(x: 0.0, y: -yCoordinate!, duration: 2))
                
            }
            
        }
        
        
        
        if canMoveNode{
            
            
            discToMove.base = toStack
            let xPositionMultipliers = Values.xPositionMultipliers
            let frameHeight = UIScreen.main.bounds.height
            let offsetDifference = CGFloat(frameHeight/100.0)
            let discWidth = 160.0 * (CGFloat(discToMove.size)/8.0)
        //--->    discToMove.node!.position.x = pegBaseOrigin![toStack].x - offsetDifference
            self.moveDisc = true
            let newNode = createDiscNode(disc: discToMove)
            discToMove.discNode!.removeFromParent()
            self.addChild(newNode)
            discToMove.discNode! = newNode
            discToMove.discNode!.position.y -= 40.0
            toPeg.discStack.append(discToMove)
            fromPeg.discStack.removeLast()
            discToMove.discNode!.run(playSound(fileName: "discDown.mp3"))
            IntroView().incrementCounter()
            trackMoves += 1
            
            //Executed upon completion of the puzzle.
            if(self.pegs[2].discStack.count == discCount){
                
                self.counter = 0
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    let duration = 1.0

                    let endGame:SKSpriteNode = self.blurCurrentScene()

                    endGame.alpha = 0
                    endGame.zPosition = self.zPosition + 1
                    endGame.run(SKAction.fadeAlpha(to: 1, duration: duration))

                    self.addChild(endGame)
                    
                    self.gameOver = true
                    
                    let userScore = self.getScore()
                    var stringEquivalent:String{
                        get{
                            return self.stringTitle(userScore)
                        }
                    }
            
                    let winMessage = SKLabelNode()
                    winMessage.verticalAlignmentMode = .center // Keep the origin in the center
                    winMessage.text = "\(stringEquivalent) \nScore:\(userScore)/100\nYou completed the puzzle in \(self.trackMoves) move(s)."
                    winMessage.fontName = "MarkerFelt-Thin"
                    let message = winMessage.multiLineString()
                    message.position = CGPoint(x: 30, y: 100)
                    endGame.addChild(message)
                    let restartScene = SKAction.move(to: CGPoint(x: (self.view?.frame.maxX)!/2, y: (self.view?.frame.maxY)!/2), duration: 1)
                    self.restartLabel!.run(restartScene)
                    self.restartLabel!.zPosition = 2000
                    
                    let fireworks = SKAction.run {
                        let fireAction = SKEmitterNode(fileNamed: "confetti")
                        fireAction?.position = CGPoint(x: CGFloat.random(in: -150...150), y: CGFloat.random(in: 50...200))
                        endGame.addChild(fireAction!)
                        
                        let fireAction1 = SKEmitterNode(fileNamed: "confetti")
                        fireAction1?.position = CGPoint(x: CGFloat.random(in: -150...150), y: CGFloat.random(in: 50...200))
                        self.run(SKAction.wait(forDuration: Double.random(in: 0...0.4))){
                            endGame.addChild(fireAction1!)
                        }
                        
                        let fireAction2 = SKEmitterNode(fileNamed: "confetti")
                        fireAction2?.position = CGPoint(x: CGFloat.random(in: -150...150), y: CGFloat.random(in: 50...200))
                        self.run(SKAction.wait(forDuration: Double.random(in: 0...0.4))){
                            endGame.addChild(fireAction2!)
                        }
                        
                        self.run(SKAction.wait(forDuration: 2)){
                            fireAction?.removeFromParent()
                            fireAction1?.removeFromParent()
                            fireAction2?.removeFromParent()
                        }
                    }
                    
                    let waitAction = SKAction.wait(forDuration: Double.random(in: 1.1...1.6))
                    
                    //self.run(SKAction.repeat(SKAction.sequence([fireworks, waitAction]), count: 2))
                    self.run(SKAction.repeatForever(SKAction.sequence([fireworks,waitAction])))
                    
                   // let confettiView = SAConfettiView(frame: self.view!.bounds)
                    
                  //  self.view?.addSubview(confettiView)
  
                }
            }
        }
        
    }

    func addPegs(){
        let frameWidth = UIScreen.main.bounds.width
        let frameHeight = UIScreen.main.bounds.height
        
        _ = view?.frame.maxX
        let maxY = view?.frame.maxY
        let pegBaseWidth = 220.0
        
        let pegBaseHeight = maxY! * (1.0/50.0)
        let horizontalOffset = pegBaseWidth/2.0 // /2.0
        
        let xCoordinates = Values.xPositionMultipliers
        let yPosition = frameHeight/10.0
        let pegBaseOriginCoordinates = xCoordinates.map { CGPoint(x: $0 * frameWidth * Values.adjustXCoordinate - CGFloat(horizontalOffset), y: yPosition)
        }
        
        pegBaseOrigin = pegBaseOriginCoordinates
        var node:SKShapeNode?
        
        //Draw shape using array of points.
        let setUpEmptyPegs = pegBaseOriginCoordinates.map {
            
            var points:[CGPoint] = [CGPoint(x: $0.x, y: $0.y),
                          CGPoint(x: $0.x + 160, y: $0.y),
                          CGPoint(x: $0.x + 160, y: $0.y + 20),
                          CGPoint(x: $0.x + 90, y: $0.y + 20),
                          CGPoint(x: $0.x + 90, y: $0.y + 200),
                          CGPoint(x: $0.x + 70, y: $0.y + 200),
                          CGPoint(x: $0.x + 70, y: $0.y + 20),
                          CGPoint(x: $0.x, y: $0.y + 20)]
            
            node = SKShapeNode(points: &points, count: points.count)
            node!.fillColor = Colors.pegColor
            self.addChild(node!)
           
            
        }
        self.pegs = setUpEmptyPegs.map{Peg(node: node!)}
        }
    
    private func addDiscs(){
        
        let discs = self.disc.sorted(by: { $0.size > $1.size })
        labelValue = discs.count
        
        for disc in discs{
            let node = createDiscNode(disc: disc)
            self.pegs[disc.base].discStack.append(disc)
            self.addChild(node)
            disc.discNode = node
        }
        
        labelValue = discs.count
    }
    
    private func createDiscNode(disc: Disc) ->SKShapeNode{
        
        let frameWidth = UIScreen.main.bounds.width
        let frameHeight = UIScreen.main.bounds.height
        
        let maxX = view?.frame.maxX
        let maxY = view?.frame.maxY
        let baseWidth = frameWidth * Values.pegBaseWidthSpecifier * 0.9
        //let baseWidth = maxX! * Scene.pegBaseWidthSpecifier * 0.9
        let baseHeight = frameHeight * (1.0/50.0)
        let xPositionMultipliers = Values.xPositionMultipliers
        let discHeight = Values.discHeightFraction * frameHeight
       // let discHeight = Scene.discHeightFraction * maxY!
        let offsetDifference = CGFloat(frameHeight/35.0)
        let baseNum = disc.base
        let peg = self.pegs[baseNum]
        let discPositionInStack = peg.discStack.count
        let discWidth = Values.discWidthFraction * baseWidth * CGFloat(disc.size)/6.0
        //let discWidth = Scene.discWidthFraction * baseWidth * CGFloat(disc.size)/8.0
       // let xPosition = 0.60 * frameWidth * Scene.adjustXCoordinate - (discWidth / 2.0)
        let xPosition = xPositionMultipliers[baseNum] * frameWidth * Values.adjustXCoordinate - (discWidth/2.0) - offsetDifference
    //    let baseYPosition = Values.baseYDistanceFraction * maxY! + baseHeight + 102.4
        var baseYPosition:CGFloat{
            return self.restartInitialSetup ? Values.baseYDistanceFraction * maxY! + baseHeight + 62.4 : Values.baseYDistanceFraction * maxY! + baseHeight + 102.4
        }
        let yOffset = (CGFloat(discPositionInStack) * discHeight) + 1.0 * (CGFloat)(discPositionInStack + 2)
        let yPosition = baseYPosition + yOffset
        let discRect = CGRect(x: xPosition, y: CGFloat(yPosition), width: discWidth, height: discHeight)
        let node = SKShapeNode(rect: discRect,cornerRadius: Values.diskCornerRadius)
        let labelSize = SKLabelNode(text: String(getNumberForDisc(labelValue,disc.size)))
        let adjustXFactor = discWidth/2
        labelSize.position = CGPoint(x: xPosition+adjustXFactor, y: CGFloat(yPosition+5))
        labelSize.zPosition = 1000
        labelSize.fontSize = 25
        labelSize.fontName = "AvenirNext-Bold"
        labelSize.color = UIColor.white
        node.addChild(labelSize)
        node.fillColor = disc.color
        
        
        return node
        
    }
    
    private func playSound(fileName sound:String) -> SKAction{
        return SKAction.playSoundFileNamed(sound, waitForCompletion: false)
    }
    
    private func getNumberForDisc(_ stackCount:Int,_ size:Int) -> Int{
        if !moveDisc{
            sizeToNumber.updateValue(stackCount, forKey: size)
            labelValue -= 1
            return stackCount
        }
        else{
            
            return sizeToNumber[size]!
        }
        
    }
    
    func blurCurrentScene() -> SKSpriteNode{

        //create the graphics context
        UIGraphicsBeginImageContextWithOptions(CGSize(width: self.view!.frame.size.width, height: self.view!.frame.size.height), true, 1)

        self.view!.drawHierarchy(in: self.view!.frame, afterScreenUpdates: true)

        // retrieve graphics context
        _ = UIGraphicsGetCurrentContext()

        // query image from it
        let image = UIGraphicsGetImageFromCurrentImageContext()

        // create Core Image context
        let ciContext = CIContext(options: nil)
        // create a CIImage, think of a CIImage as image data for processing, nothing is displayed or can be displayed at this point
        let coreImage = CIImage(image: image!)
        // pick the filter we want
        let filter = CIFilter(name: "CIGaussianBlur")
        // pass our image as input
        filter?.setValue(coreImage, forKey: kCIInputImageKey)

        //edit the amount of blur
        filter?.setValue(3, forKey: kCIInputRadiusKey)

        //retrieve the processed image
        let filteredImageData = filter?.value(forKey: kCIOutputImageKey) as! CIImage
        // return a Quartz image from the Core Image context
        let filteredImageRef = ciContext.createCGImage(filteredImageData, from: filteredImageData.extent)
        // final UIImage
        let filteredImage = UIImage(cgImage: filteredImageRef!)

        // create a texture, pass the UIImage
        let texture = SKTexture(image: filteredImage)
        // wrap it inside a sprite node
        let sprite = SKSpriteNode(texture:texture)

        // make image the position in the center
        sprite.position = CGPoint(x: self.frame.midX, y: self.frame.midY)

        
        return sprite

    }
    
    private func setUpHintButton(){
        hintButton = SKLabelNode(fontNamed: "Chalkduster")
        hintButton!.text = "Hint"
        hintButton!.fontColor = UIColor.purple
        hintButton!.position = CGPoint(x: 150, y: 20)
        //hintButton!.color = .black
        addChild(hintButton!)
               
    }
    
    private func getScore() -> Int{
        
        let optimalMoves = 2 ^^ discCount
        print("Optimal  moves:\(optimalMoves)")
        let differenceInMoves = abs(optimalMoves - trackMoves)
        let OffsetScore = Double(differenceInMoves)/Double(optimalMoves) * 100.0
        let actualScore = 100 - Int(OffsetScore)
        
        return actualScore
    }
    
    private func restartGame(){
        let restart = SKLabelNode(fontNamed: "Chalkduster")
        restart.text = "Restart"
        restart.fontColor = UIColor.red
        restart.position = CGPoint(x: 270, y: 20)
    
        restartLabel = restart
        
        addChild(restartLabel!)
        
    }
    
    
    private func stringTitle(_ score:Int) -> String{
        switch score {
        case 100:
            return "Perfect!"
        case 75...99:
            return "Awesome"
        case 50...74:
            return "Great job"
        default:
            return "Congratulations."
        }
    }
    
    
}

extension SKLabelNode {
  func multiLineString() -> SKLabelNode {
    let substrings: [String] = self.text!.components(separatedBy: "\n")
    return substrings.enumerated().reduce(SKLabelNode()) {
      let labelDescription = SKLabelNode(fontNamed: self.fontName)
      labelDescription.text = $1.element
      labelDescription.fontColor = self.fontColor
      labelDescription.fontSize = self.fontSize
      labelDescription.position = self.position
      labelDescription.horizontalAlignmentMode = self.horizontalAlignmentMode
      labelDescription.verticalAlignmentMode = self.verticalAlignmentMode
      let y = CGFloat($1.offset - substrings.count / 2) * self.fontSize
      labelDescription.position = CGPoint(x: 0, y: -y)
      $0.addChild(labelDescription)
      return $0
    }
  }
}


