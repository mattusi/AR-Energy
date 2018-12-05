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

class primaryContentContainerView: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    var arObjectURL: URL!
    var arObject: ARReferenceObject!
    var powerNode: SCNNode!
    var wattNode: SCNNode!
    var power: String?
    let rotationSpeed: Double = 0
    let bubbleDepth: Float = 0.01
    
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
    
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let arObjectData = UserDefaults.standard.object(forKey: "arObject") as? Data {
            let arObject = NSKeyedUnarchiver.unarchiveObject(with: arObjectData) as! ARReferenceObject
            
            let configuration = ARWorldTrackingConfiguration()
            
            configuration.detectionObjects = [arObject]
            
            self.sceneView.session.run(configuration)
       
        } else {
            
            let configuration = ARWorldTrackingConfiguration()
            
            configuration.planeDetection = .horizontal
            
            self.sceneView.session.run(configuration, options: .resetTracking)
            
            showAlert(title: "Nenhum modelo salvo", message: "Por favor importe um modelo para continuar", actions: [UIAlertAction(title: "OK", style: .default, handler: nil)])
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sceneView.session.pause()
    }

    //Roda a cada update de frame
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        //se o node não estiver vazio atualiza a sua geometria com o novo texto
        if powerNode != nil {
            if let textGeometry = powerNode.geometry as? SCNText {
                textGeometry.string = String(format:"Power: %3.2f W", dataReceivedUtilNow.last?.power ?? 0)
            }
        }
        if wattNode != nil {
            if let textGeometry = wattNode.geometry as? SCNText {
                textGeometry.string = String(format:"Corrente: %3.2f A", dataReceivedUtilNow.last?.corrente ?? 0)
            }
        }
        
        
    }
    
    //roda quando um objeto eh detectado
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARObjectAnchor {
            //Cria um novo node
            powerNode = createNewBubbleParentNode(String(format:"Power: %3.2f W", dataReceivedUtilNow.last?.power ?? 0))
            //Define uma posicao para o node
            let powerNodeNewPosition = SCNVector3Make(node.position.x, node.position.y + 0.15, node.position.z)
            powerNode.position = powerNodeNewPosition
            //Adiciona o node como um filho do objeto real
            node.addChildNode(powerNode)
            //cria um novo node
            wattNode = createNewBubbleParentNode(String(format:"Corrente: %3.2f A", dataReceivedUtilNow.last?.corrente ?? 0))
            let wattNodeNewPosition = SCNVector3Make(powerNodeNewPosition.x,powerNodeNewPosition.y + 0.05, powerNodeNewPosition.z)
            wattNode.position = wattNodeNewPosition
            node.addChildNode(wattNode)
            
            

        }
    }
    
    //Cria um texto 3D a partir de uma string
    func createNewBubbleParentNode(_ text: String) -> SCNNode {
        //text
        let bubble = SCNText(string: text, extrusionDepth: CGFloat(bubbleDepth))
        bubble.name = "bubbleText"
        var font = UIFont(name: "Helvetica", size: 0.15)
        font = font?.withTraits(traits: .traitBold)
        bubble.font = font
        bubble.alignmentMode = CATextLayerAlignmentMode.center.rawValue
        bubble.firstMaterial?.diffuse.contents = #colorLiteral(red: 0, green: 0.4074177742, blue: 0.1870582104, alpha: 1)
        bubble.firstMaterial?.specular.contents = UIColor.black
        bubble.firstMaterial?.isDoubleSided = true
        bubble.chamferRadius = CGFloat(bubbleDepth)
        
        //text node
        let (minBound, maxBound) = bubble.boundingBox
        let bubbleNode = SCNNode(geometry: bubble)
        bubbleNode.pivot = SCNMatrix4MakeTranslation((maxBound.x - minBound.x)/2, minBound.y, bubbleDepth/2)
        
        
        bubbleNode.scale = SCNVector3Make(0.3, 0.3, 0.3)
        
        return bubbleNode
    }
    
    //Recebe a URL do objeto escaneado e reinicia o tracking do ARKit, tambem salva o objeto no UserDefaults
    func readURL(_ url: URL) {
        do {
            arObject = try ARReferenceObject(archiveURL: url)
            let title = "Scan \"\(url.lastPathComponent)\" received"
            
            let okay = UIAlertAction(title: "Sim", style: .default, handler: nil)
            
            self.showAlert(title: title,message: "Quer importar esse modelo ?", actions: [okay])
            
            
            let configuration = ARWorldTrackingConfiguration()
            configuration.detectionObjects = [arObject]
            self.sceneView.session.run(configuration)
            
            let encodedData = NSKeyedArchiver.archivedData(withRootObject: arObject)
            
            UserDefaults.standard.set(encodedData, forKey: "arObject")
            
        } catch {
            let okay = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            self.showAlert(title: "File invalid", message: "Loading the scanned object file failed.",
                           actions: [okay])
            
        }
    }
    //Cria e mostra um alerta para o usuario
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

    extension UIFont {
        // Based on: https://stackoverflow.com/questions/4713236/how-do-i-set-bold-and-italic-on-uilabel-of-iphone-ipad
        func withTraits(traits:UIFontDescriptor.SymbolicTraits...) -> UIFont {
            let descriptor = self.fontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits(traits))
            return UIFont(descriptor: descriptor!, size: 0)
        }
}
