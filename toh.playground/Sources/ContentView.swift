import SwiftUI


struct ContentView:View{
    
    let imageData:ImageData
    
    var transitionStyle:Int = 1

    var transition:AnyTransition{
        
        switch transitionStyle{
            
        case 0:
            return .opacity
        case 1:
            return .circular
        case 2:
            return .stripes(stripes:50,horizontal:true)
        default:
            return .opacity
            
        }
    }
    
    var body:some View{
        ZStack{
            
            
            Image(uiImage: UIImage(named: "\(imageData.image)")!)
                .resizable()
                .transition(self.transition)
                .overlay(
                    Rectangle()
                        .fill(LinearGradient(gradient: Gradient(colors: [.clear,.black]), startPoint: .center, endPoint: .bottom))
                        .clipped()
            )
                .cornerRadius(2.0)
               
                
            
            VStack(alignment: .leading) {
                    
                    Spacer()
                Text("\(imageData.title)")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                Text(imageData.country)
                    .foregroundColor(.white)
                    
                }
            .padding()
        }
        .shadow(radius:12.0)
        .cornerRadius(12.0)
        
    }
}


extension Image{
    func imageStyle(height:CGFloat) -> some View{
        let shape = RoundedRectangle(cornerRadius: 15.0)
        
        return self.resizable()
            .frame(height:height)
            .overlay(
                Rectangle()
                    .fill(LinearGradient(gradient: Gradient(colors: [.clear,.black]), startPoint: .center, endPoint: .bottom))
                .clipped()
            )
                .cornerRadius(2.0)
        .clipShape(shape)
     
    }
}


extension AnyTransition{
    
    static var circular: AnyTransition{
        get{
            AnyTransition.modifier(active: ShapeClipModifier(shape: CircleClipShape(pct:1)), identity: ShapeClipModifier(shape: CircleClipShape(pct:0)))
        }
    }
    
    static func stripes(stripes s:Int,horizontal isHorizontal:Bool) -> AnyTransition{
        
        return AnyTransition.asymmetric(insertion: AnyTransition.modifier(active: ShapeClipModifier(shape:StripeShape(insertion:true,pct:1,stripes:s,horizontal:isHorizontal)), identity:
            ShapeClipModifier(shape:StripeShape(insertion:true,pct:0,stripes:s,horizontal:isHorizontal))
            ), removal:AnyTransition.modifier(active:             ShapeClipModifier(shape:StripeShape(insertion:false,pct:1,stripes:s,horizontal:isHorizontal))
                , identity:
                ShapeClipModifier(shape:StripeShape(insertion:false,pct:0,stripes:s,horizontal:isHorizontal)))
        )
    }
    
    
}

struct ShapeClipModifier<S: Shape>: ViewModifier{
    let shape: S
    
    func body(content:Content) -> some View {
        content.clipShape(shape)
    }
}


struct StripeShape: Shape{
    
    let insertion: Bool
    var pct: CGFloat
    let stripes: Int
    let horizontal: Bool
    
    var animatableData: CGFloat{
        get{pct}
        
        set{pct = newValue}
    }
    
    func path(in rect:CGRect) -> Path{
        
        var path = Path()
        
        
        let stripeHeight = rect.height/CGFloat(stripes)
        
        
        for i in 0..<stripes{
            
            let iteratorValue = CGFloat(i)
            
                if insertion{
                    
                    path.addRect(CGRect(x: 0, y: iteratorValue * stripeHeight, width: rect.width, height: stripeHeight * (1 - pct)))
                }
                else{
                    path.addRect(CGRect(x: 0, y: iteratorValue * stripeHeight + (stripeHeight * pct), width: rect.width, height: stripeHeight * (1 - pct)))
            }
            
        }
        
        return path
        
    }
}

struct CircleClipShape: Shape{
    
    var pct:CGFloat
    
    var animatableData: CGFloat{
        get{pct}
        
        set{pct = newValue}
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        var bigRect = rect
        bigRect.size.width = bigRect.size.width * 2 * (1-pct)
        bigRect.size.height = bigRect.size.height * 2 * (1-pct)
        bigRect = bigRect.offsetBy(dx: -rect.width/2.0, dy: -rect.height/2.0)

        path = Circle().path(in: bigRect)
        
        return path
    }
    
    
}
 

