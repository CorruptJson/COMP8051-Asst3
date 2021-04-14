//
//  Copyright © Borna Noureddin. All rights reserved.
//

import GLKit
import UIKit

extension ViewController: GLKViewControllerDelegate {
    func glkViewControllerUpdate(_ controller: GLKViewController) {
        glesRenderer.update()
    }
}

class ViewController: GLKViewController {
    
    
    private var context: EAGLContext?
    private var glesRenderer: Renderer!
    private var playerScore: UILabel!
    private var AIScore: UILabel!
    
    private func setupGL() {
        context = EAGLContext(api: .openGLES3)
        EAGLContext.setCurrent(context)
        if let view = self.view as? GLKView, let context = context {
            view.context = context
            delegate = self as GLKViewControllerDelegate
            glesRenderer = Renderer()
            glesRenderer.setup(view)
            glesRenderer.loadModels()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // LABELS
        playerScore = UILabel.init()
        playerScore.frame = CGRect(x:(self.view.frame.width/2)-50, y:0, width:50, height:50)
        playerScore.text = "0"
        playerScore.textAlignment = NSTextAlignment.center
        playerScore.font = playerScore.font.withSize(40)
        playerScore.textColor = UIColor.blue
        self.view.addSubview(playerScore)
        
        AIScore = UILabel.init()
        AIScore.frame = CGRect(x:self.view.frame.width/2, y:0, width:50, height:50)
        AIScore.text = "0"
        AIScore.textAlignment = NSTextAlignment.center
        AIScore.font = AIScore.font.withSize(40)
        AIScore.textColor = UIColor.red
        self.view.addSubview(AIScore)
        
        
        setupGL()
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.doSingleTap(_:)))
        singleTap.numberOfTapsRequired = 1
        view.addGestureRecognizer(singleTap)
        
        let dragFinger = UIPanGestureRecognizer(target: self, action: #selector(self.doFingerDrag(_:)))
        view.addGestureRecognizer(dragFinger)
    }
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        glesRenderer.draw(rect)
    }
    
    @objc func doSingleTap(_ sender: UITapGestureRecognizer) {
        glesRenderer.box2d.launchBall()
    }
    
    @IBAction func doFingerDrag(_ sender: UIPanGestureRecognizer){
        let translation = sender.translation(in: view)

         guard let senderView = sender.view else {
           return
         }
        
        //NSLog("PLEASE: %f", translation.y)
        
        glesRenderer.box2d.movePaddle(Float(translation.y))

         // 3
        sender.setTranslation(.zero, in: view)
    }
}
