//
//  Copyright © Borna Noureddin. All rights reserved.
//

import GLKit

extension ViewController: GLKViewControllerDelegate {
    func glkViewControllerUpdate(_ controller: GLKViewController) {
        glesRenderer.update()
        
        //NSLog("x: %f ", glesRenderer.box2d.getBallX())
        // Player Lose
        if(glesRenderer.box2d.getBallX() < 0 ) {
            glesRenderer.box2d.resetGame()
        }
        // Player Win
        if(glesRenderer.box2d.getBallX() > 800 ) {
            glesRenderer.box2d.resetGame()
        }
        
        
        
    }
}



class ViewController: GLKViewController {
    
    
    private var context: EAGLContext?
    private var glesRenderer: Renderer!
    
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
