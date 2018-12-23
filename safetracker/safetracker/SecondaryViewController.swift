//
//  SecondaryViewController.swift
//  safetracker
//
//  Created by Rohit Dsouza on 20/12/18.
//  Copyright © 2018 Rohit Dsouza. All rights reserved.
//

import Foundation
import UIKit
import Charts

struct Response: Codable {
    let statusCode: Int
    let body: String
}

struct Body {
    var SafetyLevel: String!
    var CrimeReport: String!
}

struct CrimeReport {
    var misd: Int!
    var fel: Int!
    var viol: Int!
}

class SecondaryViewController: UIViewController {
    
    @IBOutlet weak var dispCords: UILabel!
    
    @IBOutlet weak var crimeChart: PieChartView!
    
    var data:Cords!
    var safety: String!
    var safeValue: String!
    var misd: Int!
    var misdVal: Int!
    var fel: Int!
    var felVal: Int!
    var viol: Int!
    var violVal: Int!
    var totalCrime: Int!
    var totalCrime2: Int!
    var misdPerc: Double!
    var violPerc: Double!
    var felPerc: Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var crimes: [String]!
        var avgdist: [Double] = []
        
        guard let safeValue = safety else{
            print("Invalid Response")
            return
        }
        guard let misdVal = misd else{
            print("Invalid Response")
            return
        }
        guard let felVal = fel else{
            print("Invalid Response")
            return
        }
        guard let violVal = viol else{
            print("Invalid Response")
            return
        }
        
        totalCrime = misdVal + felVal + violVal
        
        guard let totalCrime2 = totalCrime else {
            print("Invalid")
            return
        }
        
        print(totalCrime2)
        
        print(misdVal)
        print(totalCrime2)
        
        let misdPerc = Double(Double(misdVal) / Double(totalCrime2) * 100)
        let felPerc = Double(Double(felVal) / Double(totalCrime2) * 100)
        let violPerc = Double(Double(violVal) / Double(totalCrime2) * 100)
        
        print(misdPerc)
        print(felPerc)
        print(violPerc)
        
        if safeValue == "Safe" {
            dispCords.textColor = UIColor.green
        }
        if safeValue == "Unsafe" {
            dispCords.textColor = UIColor.red
        }
        dispCords.text = "\(safeValue)"
        crimes = [ "Felony","Misdemeanor", "Violation"]
        avgdist = [ felPerc, misdPerc, violPerc]
        
        createChart(dataPoints: crimes, values: avgdist)
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
        
        if(segue.identifier == "showCrimeDist"){
            
            let destinationViewController = segue.destination as? VisualViewController
            
            present(destinationViewController!, animated: true, completion: nil)
        }
    }
    
    @IBAction func showCrimeChart(_ sender: Any) {
        
        self.performSegue(withIdentifier: "showCrimeDist", sender: self)
        
    }
    
    func createChart(dataPoints: [String], values: [Double]){
        
        // 2. generate chart data entries
        
        var entries = [PieChartDataEntry]()
        for (index, value) in values.enumerated() {
            let entry = PieChartDataEntry()
            entry.y = value
            entry.label = dataPoints[index]
            entries.append( entry)
        }
        
        let set = PieChartDataSet( values: entries, label: "Pie Chart")
        var colors: [UIColor] = []
        
        //for _ in 0..<values.count {
            //let red = Double(UIColor.red)
            //let orange = Double(UIColor.orange)
            //let yellow = Double(UIColor.yellow)
            //let color = UIColor(red: UIColor.red, orange: UIColor.orange , yellow: UIColor.yellow, alpha: 1)
            //colors.append(color)
        //}
        set.colors = [UIColor.red, UIColor.orange, UIColor.blue]
        let data = PieChartData(dataSet: set)
        crimeChart.data = data
        crimeChart.noDataText = "No data available"
        // user interaction
        crimeChart.isUserInteractionEnabled = true
        
        //let d = Description()
        //d.text = "iOSCharts.io"
        //chart.chartDescription = d
        crimeChart.centerText = "Crimes"
        crimeChart.holeRadiusPercent = 0.2
        crimeChart.transparentCircleColor = UIColor.clear
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
