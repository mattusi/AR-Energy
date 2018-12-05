//
//  ViewController.swift
//  MedidorEnergia
//
//  Created by Matheus Santos on 22/09/18.
//  Copyright © 2018 Matheus Santos. All rights reserved.
//

import UIKit
import simd
import Charts
import Pulley


var dataReceivedUtilNow = [EspData]()


class drawerContentContainerView: UIViewController, UITableViewDataSource {
    
    


    
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var consumoTableView: UITableView!
    @IBOutlet weak var consumoAtualLbl: UILabel!
    @IBOutlet weak var correnteAtualLbl: UILabel!
    

    
    var lineChartEntry  = [ChartDataEntry]()

 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
       
        if #available(iOS 10.0, *)
        {
            let feedbackGenerator = UISelectionFeedbackGenerator()
            self.pulleyViewController?.feedbackGenerator = feedbackGenerator
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        consumoTableView.dataSource = self
        
        updateData()
        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: {_ in
            self.updateData()
        })
        
        
        let l = lineChartView.legend
        l.form = .line
        l.font = UIFont(name: "HelveticaNeue-Light", size: 11)!
        l.textColor = .black
        l.horizontalAlignment = .left
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.drawInside = false
        
        let xAxis = lineChartView.xAxis
        xAxis.labelFont = .systemFont(ofSize: 11)
        xAxis.labelTextColor = .white
        xAxis.drawAxisLineEnabled = false
        
        let leftAxis = lineChartView.leftAxis
        leftAxis.labelTextColor = .black
        leftAxis.axisMaximum = 400
        leftAxis.axisMinimum = 120
        leftAxis.drawGridLinesEnabled = true
        leftAxis.granularityEnabled = true
        
        let rightAxis = lineChartView.rightAxis
        rightAxis.axisMaximum = 300
        rightAxis.axisMinimum = 80
        rightAxis.granularityEnabled = false
        rightAxis.drawLabelsEnabled = false
        
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.rightAxis.drawGridLinesEnabled = false
        lineChartView.xAxis.drawLabelsEnabled = false

        
    }
    
    
    
    func updateGraph() {
      
        let value =  ChartDataEntry(x: Double(dataReceivedUtilNow.count), y: Double(dataReceivedUtilNow.last?.power ?? 0))
        
        lineChartEntry.append(value) // here we add it to the data set
        if lineChartEntry.count > 5 {
            lineChartEntry.removeFirst()
        }
        
        let line1 = LineChartDataSet(values: lineChartEntry, label: "W")
        line1.colors = [#colorLiteral(red: 0, green: 0.4074177742, blue: 0.1870582104, alpha: 1)] //Sets the colour to blue
        line1.setCircleColor(#colorLiteral(red: 0, green: 0.4074177742, blue: 0.1870582104, alpha: 1))
        line1.drawCircleHoleEnabled = false
        line1.drawValuesEnabled = false
        let data = LineChartData() //This is the object that will be added to the chart
        data.addDataSet(line1) //Adds the line to the dataSet
        
        
        lineChartView.data = data //finally - it adds the chart data to the chart and causes an update
        
        lineChartView.chartDescription?.text = "Historico do consumo de energia" // Here we set the description for the graph
        
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataReceivedUtilNow.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"dadosCell") as! DadosTableViewCell
        
        let latestData = dataReceivedUtilNow[indexPath.row]
        
        
        cell.correnteLabel.text = "Corrente: \(latestData.corrente) A"
        cell.idLabel.text = "ID: \(latestData.ID)"
        cell.powerLabel.text = "Power: \(latestData.power) W"
        
        
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
            
            let dataNow = EspData(
                power:Double(separatedThings[2]) ?? 0.0,
                corrente: Double(separatedThings[1]) ?? 0.0  ,
                ID: Int(separatedThings[0]) ?? 0)
           if !(dataNow.ID == dataReceivedUtilNow.last?.ID) {
                dataReceivedUtilNow.append(dataNow)
                DispatchQueue.main.async {
                    self.updateGraph()
                }
            } else {
               print("ja recebi")
           }
            
            DispatchQueue.main.async {
                self.consumoAtualLbl.text = String(format:"Power: %3.2f W", dataNow.power)

                self.correnteAtualLbl.text = String(format: "Corrente: %3.2f A", dataNow.corrente)
                self.consumoTableView.reloadData()
            }
            
           
            
            
        }
        task.resume()
    }
    
}

