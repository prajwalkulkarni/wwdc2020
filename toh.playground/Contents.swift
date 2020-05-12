import SwiftUI
import PlaygroundSupport

/*:
 ## Welcome to my Playground💡
 This playground consists of two screens, the first one being the Home Screen and the second one being Game play screen.
 Gameplay instructions and a brief history about the game , could be found by clicking on 'Read me' button on the top right corner of the home screen.
 Before, proceeding to play you could choose the number of discs you want to have, this ranges from **1 to 6**.
 ## Game play🕹
 Shift all the discs from leftmost rod to rightmost rod(or pegs) following the given rules in minimum number of moves.
 You may look up to the hint section which shows the combination of moves to made in order to solve the puzzle in optimal moves.
 You can quit the game by clicking on **Main menu** . Also, you could restart the game at any point by clicking on **Restart**.
 The **Moves** label in the bottom left corner shows the number of moves made by the player.
 A score is given after solving the puzzle(full marks if you solve the puzzle in optimal moves😃😉)
 ## Resources and Assets🔨
 All the assets used in this playground are either license-free or self-created.
 
 *Credits*:
 - ☞  [Zapslat - Royalty free music](https://zapslat.com)
 - ☞  [Wikipedia - History of towers of hanoi](https://en.wikipedia.org/wiki/Tower_of_Hanoi)
 - ☞  [Canva - background images](https://www.canva.com)
 
 I hope you like my playground 🥳

 */


let v = UIHostingController(rootView: IntroView().environmentObject(Scene()))
v.preferredContentSize = CGSize(width: 600, height: 400)


PlaygroundPage.current.setLiveView(v)


    


