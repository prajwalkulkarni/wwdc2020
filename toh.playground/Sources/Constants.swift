import SwiftUI

struct Colors{
    //disc colors
    static let colors = [UIColor.blue,UIColor.orange,UIColor.red,UIColor.green,UIColor.brown,UIColor.purple]
    
    //Peg color
    static let pegColor = UIColor(red:0.00, green:0.00, blue:0.00, alpha:1.0)

}

enum discError: Error{
    case emptyPeg
}

struct Values{
     static let diskCornerRadius: CGFloat = 8.0
     static let pegBaseWidthSpecifier: CGFloat = 1.0/4.0
    // static let xPositionMultipliers: [CGFloat] = [0.9,2.2,3.5]
     static let xPositionMultipliers: [CGFloat] = [0.9,2.2,3.4]
     static let adjustXCoordinate: CGFloat = 1.0/5.0
     static let discHeightFraction:CGFloat = 1.5/50.0
     static let discWidthFraction:CGFloat = 0.8
     static let baseYDistanceFraction:CGFloat = 1.0/10.0
}

class Hint{
    
    static var step:Int = 1
    static var hintString:String = ""
    
    //Recursive method to generate steps for solving the puzzle in optimal number of moves.
    static func towersOfHanoi(numberOfDiscs discCount:Int,Source source:Int,Destination destination:Int,Auxilary auxilary:Int) -> Void{
        
        if discCount == 1{
            hintString += "\(step).Move disc \(discCount) from peg \(source) to peg \(destination)\n"
            step += 1
            return
        }
        
        towersOfHanoi(numberOfDiscs: discCount - 1, Source: source, Destination: auxilary, Auxilary: destination)
        hintString += "\(step).Move disc \(discCount) from peg \(source) to peg \(destination)\n"
        step += 1
        towersOfHanoi(numberOfDiscs: discCount - 1, Source: auxilary, Destination: destination, Auxilary: source)
    }
    
}
