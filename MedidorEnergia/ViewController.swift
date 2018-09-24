//
//  ViewController.swift
//  MedidorEnergia
//
//  Created by Matheus Santos on 22/09/18.
//  Copyright © 2018 Matheus Santos. All rights reserved.
//

import UIKit



class ViewController: UIViewController, UITableViewDataSource {
    
    

    @IBOutlet weak var consumoTableView: UITableView!
    @IBOutlet weak var consumoAtualLbl: UILabel!
    @IBOutlet weak var correnteAtualLbl: UILabel!
    

    var dataReceivedUtilNow = [EspData]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        consumoTableView.dataSource = self
        
        updateData()
        // Do any additional setup after loading the view, typically from a nib.
        Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: {_ in
            self.updateData()
        })
        
        
        
        
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
            
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print(responseString ?? "string nil")
            
            
            
            let separatedThings = responseString!.components(separatedBy: "/")
            
            var correnteTratada = ""
            if separatedThings[1].count > 7 {
                correnteTratada = String(separatedThings[1].dropLast(10))
            } else {
                correnteTratada = separatedThings[1]
            }
            
            let dataNow = EspData(power: String(separatedThings[2].dropLast(10)) + " W",
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

