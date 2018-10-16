//
//  ARViewController.swift
//  MedidorEnergia
//
//  Created by Matheus Santos on 01/10/18.
//  Copyright © 2018 Matheus Santos. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

class ARViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    var arObjectURL: URL!
    var arObject: ARReferenceObject!
    var labelNode: SKLabelNode!
    var power: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //delegate
        sceneView.delegate = self
        //statistics
        //sceneView.showsStatistics = true
        //sceneView.debugOptions = [.showFeaturePoints, .showWorldOrigin]
        // create a new scene
        let scene = SCNScene()
        
        sceneView.scene = scene
        
        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: {_ in
            self.updateData()
        })
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = .horizontal
            self.sceneView.session.run(configuration, options: .resetTracking)
     
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sceneView.session.pause()
    }

    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARObjectAnchor {
            let videoNode = SKVideoNode(fileNamed: "freeVideo.mp4")
            videoNode.play()
            
            
            labelNode = SKLabelNode(text: power ?? "Not Yet")
            
            labelNode.fontSize = 100
            
            
            
            let videoSkScene = SKScene(size: CGSize(width: 1280, height: 720))
            videoSkScene.addChild(labelNode)
            
            labelNode.position = CGPoint(x: videoSkScene.size.width/2, y: videoSkScene.size.height - 130)
            videoNode.size = videoSkScene.size
            
            let tvPlane = SCNPlane(width: 0.20, height: 0.15)
            tvPlane.firstMaterial?.diffuse.contents = videoSkScene
            tvPlane.firstMaterial?.isDoubleSided = true
            
            let tvPlaneNode = SCNNode(geometry: tvPlane)
            
            
            tvPlaneNode.eulerAngles = SCNVector3(Double.pi, 0, 0)
            
            node.addChildNode(tvPlaneNode)
            
            tvPlaneNode.position = SCNVector3Make(node.position.x, node.position.y + Float(tvPlane.height/2) + 0.05, node.position.z + 0.05)
            

        }
    }
    
    
    
    func updateData() {
        let request = NSURLRequest(url: NSURL(string: "https://phpmedidorenergia.azurewebsites.net")! as URL)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if error != nil {
                print("something went wrong")
                
            }
            
            var responseString = ""
            
            if let dataTreated = data {
                
                responseString = NSString(data: dataTreated, encoding: String.Encoding.utf8.rawValue)! as String
            } else {
                responseString = " Something went wrong / aseaseas / Erro "
            }
            
            
            
            let separatedThings = responseString.components(separatedBy: "/")
            
            var correnteTratada = ""
            if separatedThings[1].count > 6 {
                correnteTratada = String(separatedThings[1].dropLast(5))
            } else {
                correnteTratada = separatedThings[1]
            }
            
            let dataNow = EspData(power: String(separatedThings[2].dropLast(5)) + " W",
                                  corrente: correnteTratada + " A" ,
                                  ID: separatedThings[0])
            
            
            DispatchQueue.main.async {
                self.power = dataNow.power
            }
            
        }
        task.resume()
    }
    

    
    
    func readURL(_ url: URL) {
        do {
            arObject = try ARReferenceObject(archiveURL: url)
            let title = "Scan \"\(url.lastPathComponent)\" received"
            
            let okay = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            self.showAlert(title: title,message: "is this ok?", actions: [okay])
            
            
            let configuration = ARWorldTrackingConfiguration()
            configuration.detectionObjects = [arObject]
            self.sceneView.session.run(configuration)
            
        } catch {
            let okay = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            self.showAlert(title: "File invalid", message: "Loading the scanned object file failed.",
                           actions: [okay])
            
        }
    }
    
    func showAlert(title: String, message: String, actions: [UIAlertAction]) {
        let showAlertBlock = {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            actions.forEach { alertController.addAction($0) }
            DispatchQueue.main.async {
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
        if presentedViewController != nil {
            dismiss(animated: true) {
                showAlertBlock()
            }
        } else {
            showAlertBlock()
        }
    }
}

