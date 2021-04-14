//
//  Copyright © Borna Noureddin. All rights reserved.
//

import GLKit

extension ViewController: GLKViewControllerDelegate {
    func glkViewControllerUpdate(_ controller: GLKViewController) {
        glesRenderer.update()
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

        let newPoint = CGPoint(
            x: senderView.center.x,
            y: senderView.center.y + translation.y
        )
        
        NSLog("PLEASE: %f", newPoint.y)

         // 3
        sender.setTranslation(.zero, in: view)
    }

}
