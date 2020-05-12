
import UIKit
import QuartzCore

public class SAConfettiView: UIView {

    public enum ConfettiType {
        case confetti
        case triangle
        case star
        case diamond
        case image(UIImage)
    }

    var emitter: CAEmitterLayer!
    public var colors: [UIColor]!
    public var intensity: Float!
    public var type: ConfettiType!
    private var active :Bool!

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    func setup() {
        colors = [UIColor(red:0.95, green:0.40, blue:0.27, alpha:1.0),
            UIColor(red:1.00, green:0.78, blue:0.36, alpha:1.0),
            UIColor(red:0.48, green:0.78, blue:0.64, alpha:1.0),
            UIColor(red:0.30, green:0.76, blue:0.85, alpha:1.0),
            UIColor(red:0.58, green:0.39, blue:0.55, alpha:1.0)]
        intensity = 0.5
        type = .confetti
        active = false
    }

    public func startConfetti() {
        emitter = CAEmitterLayer()

        emitter.emitterPosition = CGPoint(x: frame.size.width / 2.0, y: 0)
        emitter.emitterShape = CAEmitterLayerEmitterShape.line
        emitter.emitterSize = CGSize(width: frame.size.width, height: 1)

        var cells = [CAEmitterCell]()
        for color in colors {
            cells.append(confettiWithColor(color: color))
        }

        emitter.emitterCells = cells
        layer.addSublayer(emitter)
        active = true
    }

    public func stopConfetti() {
        emitter?.birthRate = 0
        active = false
    }

    func imageForType(type: ConfettiType) -> UIImage? {

        var fileName: String!

        switch type {
        case .confetti:
            fileName = "confetti"
        case .triangle:
            fileName = "triangle"
        case .star:
            fileName = "star"
        case .diamond:
            fileName = "diamond"
        case let .image(customImage):
            return customImage
        }

        let path = Bundle(for: SAConfettiView.self).path(forResource: "SAConfettiView", ofType: "bundle")
        let bundle = Bundle(path: path!)
        let imagePath = bundle?.path(forResource: fileName, ofType: "png")
        let url = URL(fileURLWithPath: imagePath!)
        do {
            let data = try Data(contentsOf: url)
            return UIImage(data: data)
        } catch {
            print(error)
        }
        return nil
    }

    func confettiWithColor(color: UIColor) -> CAEmitterCell {
        let confetti = CAEmitterCell()
        confetti.birthRate = 6.0 * intensity
        confetti.lifetime = 14.0 * intensity
        confetti.lifetimeRange = 0
        confetti.color = color.cgColor
        confetti.velocity = CGFloat(350.0 * intensity)
        confetti.velocityRange = CGFloat(80.0 * intensity)
        confetti.emissionLongitude = CGFloat(Double.pi)
        confetti.emissionRange = CGFloat(Double.pi)
        confetti.spin = CGFloat(3.5 * intensity)
        confetti.spinRange = CGFloat(4.0 * intensity)
        confetti.scaleRange = CGFloat(intensity)
        confetti.scaleSpeed = CGFloat(-0.1 * intensity)
        confetti.contents = imageForType(type: type)!.cgImage
        return confetti
    }

    public func isActive() -> Bool {
            return self.active
    }
}


/*
 import SwiftUI


 public class Confetti:UIView{
     
     
     var emitter:CAEmitterLayer? = nil
     let population:Float = 0.8
     var active = false
     
     public override init(frame: CGRect){
         super.init(frame:frame)
         initializeConfetti()
     }
     
     required public init?(coder aDecoder: NSCoder) {
         super.init(coder: aDecoder)
         initializeConfetti()
         fatalError("init(coder:) has not been implemented")
     }
     public func initializeConfetti(){
         emitter = CAEmitterLayer()
         
         emitter?.position = CGPoint(x: frame.size.width/2.0, y: frame.size.height - 10)
         emitter?.emitterShape = .line
         emitter?.emitterSize = CGSize(width: frame.size.width, height: 1)
         emitter?.zPosition = 100000
         var cellNodes = [CAEmitterCell]()
         
         for color in Colors.colors{
             cellNodes.append(coloredConfetti(color:color))
         }
         
         emitter?.emitterCells = cellNodes
         CALayer().addSublayer(emitter!)
         active = true
     
     }
     
     
     func coloredConfetti(color confettiColor:UIColor) -> CAEmitterCell{
         
         let confetti = CAEmitterCell()
         confetti.birthRate = 8.0 * population
         confetti.lifetime = 14.0 * population
         confetti.color = confettiColor.cgColor
         confetti.velocity = CGFloat(350 * population)
         confetti.velocityRange = CGFloat(80 * population)
         confetti.lifetimeRange = 0
         confetti.emissionLongitude = CGFloat(Double.pi)
         confetti.emissionRange = CGFloat(Double.pi)
         confetti.spin = CGFloat(5 * population)
         confetti.spinRange = CGFloat(4.0 * population)
         confetti.scaleRange = CGFloat(population)
         confetti.scaleSpeed = CGFloat(-0.1 * population)
         
         return confetti
     }
 }
 */

