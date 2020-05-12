import SwiftUI


struct SwipeView:View{
    
    @State private var difference: CGFloat = 0
    @State private var index = 0
    
    let spacing:CGFloat = 10
    
  /*  var body: some View{
        GeometryReader { (geometry) in
            return ScrollView(.horizontal, showsIndicators: true) {
                HStack(spacing: self.spacing) {
                    ForEach(images,id: \.self){
                        image in
                        ContentView(imageData: image)
                            .frame(width:geometry.size.width)
                        
                    }
                }
            }
            .content.offset(x:self.difference)
            .frame(width:geometry.size.width,alignment: .leading)
        .gesture(
            DragGesture()
                .onChanged({ (value) in
                    self.difference = value.translation.width - geometry.size.width * CGFloat(self.index)
                    
                })
                .onEnded({ (value) in
                    if -value.predictedEndTranslation.width > geometry.size.width/2 , self.index < images.count - 1{
                        self.index += 1
                    }
                    if value.predictedEndTranslation.width > geometry.size.width / 2, self.index > 0 {
                        self.index -= 1
                    }
                    withAnimation { self.difference = -(geometry.size.width + self.spacing) * CGFloat(self.index) }
                }) 
            
            )
        }
    }*/
    
    
    
    var timer: Timer{
        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { (timer) in
            
            if self.index < images.count - 1{
                self.index += 1
            }
            else{
                self.index = 0
            }
        }
    }
    
    var body:some View{
        
        ContentView(imageData: images[self.index])
            .onAppear {
                let _ = self.timer
        }
    }
    
}

public struct ImageData:Identifiable{
    public let id:Int
    let image:String
    let title:String
    let country:String
}

let images = [ImageData(id:0,image:"hanoi.jpg",title: "About", country: "The tower of Hanoi (also called the tower of Brahma or the Lucas tower) was invented by a French mathematician Édouard Lucas in the 19th century."),
              ImageData(id:1,image:"towerOfHanoi.jpg",title: "Age old story", country: "There is a story about an Indian temple in Kashi Vishwanath which contains a large room with three time-worn posts in it, surrounded by 64 golden disks.Brahmin priests, acting out the command of an ancient prophecy--"),
              ImageData(id:2,image:"kashiVishwanath.jpg",title: "Kashi Vishwananth temple", country: ",have been moving these disks in accordance with the immutable rules of Brahma since that time. The puzzle is therefore also known as the Tower of Brahma puzzle. According to the legend, when the last move of the puzzle is completed, the world will end.")]




