//
//  ViewController.swift
//  arkitstarted
//
//  Created by Peter Ho on 3/30/19.
//  Copyright © 2019 Peter Ho. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    private var imageConfiguration: ARImageTrackingConfiguration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        
        setupImageDetection()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        // let configuration = ARWorldTrackingConfiguration()
        
        if let configuration = imageConfiguration {
            sceneView.session.run(configuration)
        }
        
        // Run the view's session
        // sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func setupImageDetection() {
        imageConfiguration = ARImageTrackingConfiguration()
        guard let referenceImages = ARReferenceImage.referenceImages(
            inGroupNamed: "AR Images", bundle: nil) else {
                fatalError("Missing expected asset catalog resources.")
        }
        imageConfiguration?.trackingImages = referenceImages
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // DispatchQueue.main.async { self.instructionLabel.isHidden = true }
        if let imageAnchor = anchor as? ARImageAnchor {
            handleFoundImage(imageAnchor, node)
        }
    }
    
    func handleFoundImage(_ imageAnchor: ARImageAnchor, _ node: SCNNode) {
        let name = imageAnchor.referenceImage.name!
        print("you found a \(name) image")
        
        let size = imageAnchor.referenceImage.physicalSize
        if let videoNode = makeDinosaurVideo(size: size) {
            node.addChildNode(videoNode)
            node.opacity = 1
        }
    }
    
    func makeDinosaurVideo(size: CGSize) -> SCNNode? {
        // 1
        guard let videoURL = Bundle.main.url(forResource: "dinosaur",
                                             withExtension: "mp4") else {
                                                return nil
        }
        
        // 2
        let avPlayerItem = AVPlayerItem(url: videoURL)
        let avPlayer = AVPlayer(playerItem: avPlayerItem)
        avPlayer.play()
        
        // 3
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: nil,
            queue: nil) { notification in
                avPlayer.seek(to: .zero)
                avPlayer.play()
        }
        
        // 4
        let avMaterial = SCNMaterial()
        avMaterial.diffuse.contents = avPlayer
        
        // 5
        let videoPlane = SCNPlane(width: size.width, height: size.height)
        videoPlane.materials = [avMaterial]
        
        // 6
        let videoNode = SCNNode(geometry: videoPlane)
        videoNode.eulerAngles.x = -.pi / 2
        return videoNode
    }
}
