//
//  ViewController.swift
//  ARithmetics
//
//  Created by Dante Cervantes Vega on 01/11/19.
//  Copyright © 2019 Dante Cervantes Vega. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

enum MathOperations: CaseIterable {
    case add, substract, miltiply, divide
}

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var questionLabel: UILabel!
    @IBOutlet var tickImageView: UIImageView!
    
    var correctAnswer : Int? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        askQuestion()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        
        guard let trackingIMages = ARReferenceImage.referenceImages(inGroupNamed: "Numbers", bundle: nil) else {
            fatalError("No se encontro el grupo de imagenes")
        }
        
        configuration.trackingImages = trackingIMages
        configuration.maximumNumberOfTrackedImages = 2

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        guard let imageAnchor = anchor as? ARImageAnchor else{
            return nil
        }
        
        let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width,
                             height: imageAnchor.referenceImage.physicalSize.height)
        plane.firstMaterial?.diffuse.contents = UIColor.green.withAlphaComponent(0.4)
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.eulerAngles.x = -.pi / 2
        
        let node = SCNNode()
        node.addChildNode(planeNode)
        return node
    }
    
    //MARK: Game Methods
    
    func createNewQuestions() -> (question : String, answer : Int){
        
        let operation = MathOperations.allCases.randomElement()!
        var question : String
        var answer : Int
        
        repeat{
            switch operation {
            case .add:
                let x = Int.random(in: 1...49)
                let y = Int.random(in: 1...49)
                question = "\(x) + \(y) =?"
                answer = x+y
                
            case .substract:
                let x = Int.random(in:  1...49)
                let y = Int.random(in: 1...49)
                question = "\(x*y) - \(y) =?"
                answer = x*y-y
                
            case .miltiply:
                let x = Int.random(in: 1...10)
                let y = Int.random(in: 1...9)
                question = "\(x) * \(y) = ?"
                answer = x * y
                
            case .divide:
                let x = Int.random(in: 1...10)
                let y = Int.random(in: 1...9)
                question = "\(x*y) / \(x) =?"
                answer = x*y/x
            }
        }while !answer.hasUniqueDigits
            return (question,answer)
    }
    
    func askQuestion()  {
        let newQuestion = createNewQuestions()
        questionLabel.text = newQuestion.question
        correctAnswer = newQuestion.answer
        
        questionLabel.alpha = 0
        UIView.animate(withDuration: 0.7) {
            self.questionLabel.alpha = 1
            self.tickImageView.alpha = 0
            self.tickImageView.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
        }
    }
    
    func showcorrectAnswer(){
        
        tickImageView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        UIView.animate(withDuration: 0.7) {
            self.tickImageView.transform = .identity
            self.tickImageView.alpha = 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1.2) {
            self.askQuestion()
        }
    }
    
    // MARK: Update Scene Kit
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        guard let anchors = sceneView.session.currentFrame?.anchors else {
            return
        }
        
        let visibleAnchors = anchors.filter {
            guard let anchor = $0 as? ARImageAnchor else{
                return false
            }
            return anchor.isTracked
        }
        
        let nodes = visibleAnchors.sorted { (anchor1, anchor2) -> Bool in
            guard let node1 = sceneView.node(for: anchor1) else{
                return false
            }
            guard let node2 = sceneView.node(for: anchor2) else {
                return false
            }
            return node1.worldPosition.x < node2.worldPosition.x
        }
        
        let strAnswer = nodes.reduce("") { $0 + ($1.name ?? "")}
        
        let userAnswer = Int(strAnswer) ?? 0
        
        if userAnswer == correctAnswer{
            correctAnswer = nil
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                self.showcorrectAnswer()
            }
        }
    }
}
