import SwiftUI

public struct IntroView: View{
    
    //Enable 'internal' protection level accessibility
    public init(){}
    
    
    
    @State var disks: Int = 1
    @State private var showRules: Bool = false
    @State var gameView: Bool = false
    @State var switchColor: Bool = false
    //Track changes in Scene.swift
    @ObservedObject var moves = Scene.shared
    
    let colors:[Color] = [Color.red,Color.green,Color.blue,Color.orange,Color.pink,Color.purple]
    
    func incrementCounter(){
              moves.counter += 1
          }
    
    func decrementCounter(){
        moves.counter -= 2
    }
    
    func resetCounter(){
        moves.counter = 0
    }
    
    func toggleHintState(){
        moves.showHint = true
    }
    
    
    public var body:some View{
        
            ZStack{
                // NavigationView{
                
                Image(uiImage: UIImage(named: "introview")!)
               
                VStack{
                    
                    HStack{
                        Text("Towers of hanoi")
                            .font(.largeTitle)
                            .padding()
                        
                        Spacer()
                        
                        Button("Read me")
                        {
                            withAnimation(.easeInOut(duration: 0.8)) {
                                self.showRules = true
                            }
                        }
                        .padding()
                    }
                    
                    
                    HStack{
                        
                        VStack{
                            
                            
                            Rectangle()
                                .fill(Color.black)
                                .padding(.bottom, -10)
                                .frame(width: 20, height: 35)
                            
                            //Present Extracted subviews
                            DiskView(width: 80, color: Color.red)
                            
                            DiskView(width: 100, color: Color.green)
                            
                            DiskView(width: 120, color: Color.blue)
                            
                            Rectangle()
                                .fill(Color.black)
                                .frame(width: 140, height: 20)
                                .padding(.bottom, -10)
                        }.padding(.leading)
                            .padding(.trailing)
                            .offset(y:15)
                        
                        
                        EmptyPegs()
                        EmptyPegs()
                        
                    }
                    
                    
                   /* Stepper(value: $disks, in: 1...6){
                        Text("Number of discs:\(disks)")
                        
                    }
                    .padding(.leading, 40)
                    .padding(.trailing,40)
                    */
                    
                    //Custom stepper
                    
                    HStack(alignment: .center){
                        
                        Text("Number of discs:\(disks)")
                            .padding()
                        //Spacer()
                        
                        StepperAction(arithemeticOperator: "-",discCount: $disks,color: Color.red)
                        
                        StepperAction(arithemeticOperator: "+",discCount: $disks,color: Color.green)
                        
                    }
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.8)) {
                            self.gameView.toggle()
                        }
                    }) {
                        Text("PLAY")
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .font(.title)
                    }
                    
                    
                    
                }.padding(.bottom, 20)
                
                //.navigationBarTitle("")
                //.navigationBarHidden(true)
                
                //}
                
                if showRules{
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width: 400, height: 350, alignment: .center)
                        .overlay(ModalView(rules: $showRules))
                        .transition(.slide)
                    
                }
                
                //Load SKScene when gameView is set to true. GameView is stacked on top of IntroView.
                if gameView{
                    GameView(discCount: disks)
                        .transition(.opacity)
                    HStack{
                        
                      //  TextColorTransition(fromColor:UIColor.black,toColor:UIColor.green,percent: switchColor ? 1:0){
                            
                            Text("Moves:\(moves.counter)").position(x: 60, y: 380)
                     //  }
                        
                        
                        Button(action: {
                            self.gameView = false
                            self.moves.counter = 0
                        }) {
                            Text("Main menu")
                                .foregroundColor(.black)
                            .underline()
                        }.position(x:120,y:380)
                    }
                    
                    if moves.showHint{
                       RoundedRectangle(cornerRadius: 1)
                        .frame(width: 350, height: 300)
                        .overlay(hintSection(moves:moves))
                        .transition(.customTransition)
                        .zIndex(10)
                        
                    }
                   
                }
            }
    }
    
}


struct DiskView: View {
    var width: CGFloat
    var color: Color
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(color)
            .frame(width: width, height: 20)
            .padding(.bottom, -10)
    }
}

struct EmptyPegs: View {

    var body: some View {
        // Draw an inverted 'T' known as a peg,which acts as a base,atop which discs could be placed.
        Path { path in
           
            path.move(to: CGPoint(x: 50, y: 155))
            path.addLine(to: CGPoint(x: 190, y: 155))
            path.addLine(to: CGPoint(x: 190, y: 135))
            path.addLine(to: CGPoint(x: 130, y: 135))
            path.addLine(to: CGPoint(x: 130, y: 35))
            path.addLine(to: CGPoint(x: 110, y: 35))
            path.addLine(to: CGPoint(x: 110, y: 135))
            path.addLine(to: CGPoint(x: 50, y: 135))
        }.fill(Color.black)
    }
}

struct StepperAction: View{
    
    
    var arithemeticOperator:String
    @Binding var discCount:Int
    var color:Color
    
    var body:some View{
                
        Button(action: {
            if self.arithemeticOperator == "-"{
                if self.discCount != 1{
                    self.discCount -= 1
                }
            }
            
            if self.arithemeticOperator == "+"{
                if self.discCount != 6{
                    self.discCount += 1
                }
            }
        }) {
            
            Circle()
                .fill(color)
                .frame(width: 30, height: 30,alignment: .center)
                .overlay(Text("\(arithemeticOperator)").foregroundColor(Color.white).font(.custom("Arial", size: 30)))
            
        }
        .padding()
    }
}

struct ModalView: View{
    
    @Binding var rules: Bool
    
    var body: some View{
        
        TabView{
            VStack(alignment: .leading){
                
                Text("Rules").font(.largeTitle)
                    .padding(.leading)
                Text("1.Move all the disks from leftmost peg to the rightmost peg.")
                    .padding()
                Text("2.You can move only 1 disk at a time.")
                    .padding()
                Text("3.Bigger disk cannot be placed on smaller disk.")
                    .padding()
                
                Button(action:{
                    self.rules.toggle()
                    
                    
                }){
                    Text("Got it")
                        .font(.custom("Arial", size: 18))
                        .foregroundColor(.blue)
                    
                }
                .padding(.leading)
                
            }
            .background(Color.yellow)
        
            .tabItem {
                Image(systemName: "info")
            }
            
            VStack(alignment: .leading){
               
                
                    SwipeView()
                        .padding()
                    
                    Button("Close"){
                        self.rules.toggle()
                    }.padding(.leading)
                
                
                
            }
                .background(Color.yellow)
            
            .tabItem {
                VStack{
                    Image(systemName:"book.fill")
                    Spacer()
                }
                
            }
            
        }
        .edgesIgnoringSafeArea(.all)
    }
}


//Show hint to solve puzzle.
struct hintSection:View{
    
    @ObservedObject var moves:Scene
    
    var body:some View{
        
        
        GeometryReader{ reader in
            ScrollView(.vertical,showsIndicators: true) {
                ZStack(alignment: .top) {
                    VStack{
                        
                        //Display hint in steps, hints as string extracted from 'hintString' (Constants.swift)
                        Text(Hint.hintString)
                            .font(Font.custom("Chalkduster", size: 20))
                            .foregroundColor(.white)
                            Button(action: {
                                withAnimation(.easeInOut(duration: 1.0)){
                                    self.moves.showHint = false
                                    Hint.hintString = ""
                                    Hint.step = 1
                                }
                            }) {
                                HStack{
                                    Spacer()
                                    Text("OK")
                                    Spacer()
                                }
                            }
                        }
                    .padding()
                }
                .background(Image(uiImage: UIImage(named: "board")!).resizable().scaledToFill())
                
            }
        
            
        }
    
        
    }
    
}

struct TextColorTransition:View{
    
    let fromColor: UIColor
    let toColor: UIColor
    let percent: CGFloat
    let text: () -> Text
    
    var body:some View{
        let textView = text()
        
        return textView.foregroundColor(Color.clear)
            .overlay(Color.clear.modifier(TextColorModifier(from: fromColor,to:toColor,prct: percent,string:textView)))
    }
    
    struct TextColorModifier: AnimatableModifier{
        
        let from: UIColor
        let to: UIColor
        var prct: CGFloat
        let string: Text
        
        var animatableData: CGFloat{
            get{
                prct
            }
            set{
                prct = newValue
            }
        }
        
        func body(content: Content) -> some View {
            return string.foregroundColor(interpolateColors(initialColor: from,finalColor:to,prct:prct))
        }
        
        func interpolateColors(initialColor i:UIColor,finalColor f:UIColor,prct pct:CGFloat) -> Color{
            
            guard let i1 = i.cgColor.components else { return Color(i)}
            guard let f1 = f.cgColor.components else { return Color(f)}
            
            let r = ( i1[0] + (f1[0] - f1[0]) * pct)
            let g = ( i1[1] + (f1[1] - f1[1]) * pct)
            let b = ( i1[2] + (f1[2] - f1[2]) * pct)
            
            return Color(red:Double(r),green: Double(g),blue: Double(b))
            
        }
    }
    
}


extension AnyTransition{
    static var customTransition: AnyTransition{ get{
        AnyTransition.modifier(active: HintTransition(pct:0), identity: HintTransition(pct:1))
        }
    }
}

struct HintTransition:GeometryEffect{
    
    var pct:Double
    var animatableData: Double{
        get{ pct }
        set{ pct = newValue }
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        let rotationPercent = pct
        let a = CGFloat(Angle(degrees: 90 *  (1 - rotationPercent)).radians)
        
        var transform3d = CATransform3DIdentity
        transform3d.m34 =  -1/max(size.width,size.height)
        
        transform3d = CATransform3DRotate(transform3d, a, 1, 0, 0)
        transform3d = CATransform3DTranslate(transform3d, -size.width/2.0, -size.height/2.0, 0)
        
        let affineTransform1 = ProjectionTransform(CGAffineTransform(translationX: size.width/2.0, y: size.height/2.0))
        let affineTransform2 = ProjectionTransform(CGAffineTransform(scaleX: CGFloat(pct * 2), y: CGFloat(pct * 2)))
        
        if pct <= 0.5{
            return ProjectionTransform(transform3d).concatenating(affineTransform2).concatenating(affineTransform1)
            
        }
        else{
            
            return ProjectionTransform(transform3d).concatenating(affineTransform1)
        }
    }
    
}
