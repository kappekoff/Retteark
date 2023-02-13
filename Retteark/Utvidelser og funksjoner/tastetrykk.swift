import UIKit
import SwiftUI

struct tastetrykk: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> tasteTrykkOntroller {
        let vc  = tasteTrykkOntroller()
        return vc
    }
    
    func updateUIViewController(_ uiViewController: tasteTrykkOntroller, context: Context) {
        
    }
    
    typealias UIViewControllerType = tasteTrykkOntroller
}

class tasteTrykkOntroller: UIViewController {
    
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        var elevIndeksFokus: Int = 0
        var oppgaveIndeksFokus: Int = 0
        
        guard let key = presses.first?.key else { return }
        
        switch key.keyCode {
        case .keyboardLeftArrow:
            oppgaveIndeksFokus -= 1
            print("keyboardLeftArrow")
        case .keyboardRightArrow:
            oppgaveIndeksFokus += 1
            print("keyboardRightArrow")
        case .keyboardDownArrow:
            elevIndeksFokus += 1
            print("keyboardDownArrow")
        case .keyboardUpArrow:
            elevIndeksFokus -= 1
            print("keyboardUpArrow")
            
        default:
            super.pressesBegan(presses, with: event)
        }
    }
}
