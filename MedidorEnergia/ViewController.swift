//
//  ViewController.swift
//  MedidorEnergia
//
//  Created by Matheus Santos on 22/09/18.
//  Copyright © 2018 Matheus Santos. All rights reserved.
//

import UIKit



class ViewController: UIViewController, UITableViewDataSource {
    
    

    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var consumoTableView: UITableView!
    @IBOutlet weak var consumoAtualLbl: UILabel!
    @IBOutlet weak var correnteAtualLbl: UILabel!
    

    var dataReceivedUtilNow = [EspData]()
    
    var timer2 = Timer()
    var time = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        consumoTableView.dataSource = self
        
        updateData()
        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: {_ in
            self.updateData()
        })
        
        timer2 = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerRunning), userInfo: nil, repeats: true)
        
        
        
        
    }
    
    @objc func timerRunning() {
        if time >= 30 {
            time = 0
            DispatchQueue.main.async {
                self.progressBar.progress = 0
            }
        } else {
            DispatchQueue.main.async {
                self.progressBar.progress = 1
            }
            
            time += 1
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataReceivedUtilNow.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"dadosCell") as! DadosTableViewCell
        
        let latestData = dataReceivedUtilNow[indexPath.row]
        
        
        cell.correnteLabel.text = latestData.corrente
        cell.idLabel.text = latestData.ID
        cell.powerLabel.text = latestData.power
        
        
        return cell
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
                responseString = " Something went wrong / aseaseas / ashasheuaErro "
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
            if !(dataNow.ID == self.dataReceivedUtilNow.last?.ID) {
               self.dataReceivedUtilNow.append(dataNow)
            } else {
                print("ja recebi")
            }
            
            DispatchQueue.main.async {
                self.consumoAtualLbl.text = dataNow.power
                self.correnteAtualLbl.text = dataNow.corrente
                
                self.consumoTableView.reloadData()
                
            }
            
        }
        task.resume()
    }
    
}

