//
//  ViewController.swift
//  safetracker
//
//  Created by Rohit Dsouza on 11/12/18.
//  Copyright © 2018 Rohit Dsouza. All rights reserved.
//

import UIKit
import CoreLocation

class Ring: UIView
{
    override func draw(_ rect: CGRect)
    {
        drawRingFittingInsideView()
    }
    
    internal func drawRingFittingInsideView()->()
    {
        let halfSize:CGFloat = min( bounds.size.width/2, bounds.size.height/2)
        let desiredLineWidth:CGFloat = 1    // your desired value
        
        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x:halfSize,y:halfSize),
            radius: CGFloat( halfSize - (desiredLineWidth/2) ),
            startAngle: CGFloat(0),
            endAngle:CGFloat(Double.pi * 2),
            clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = desiredLineWidth
        
        layer.addSublayer(shapeLayer)
    }
}

struct Cords{
    var lat:Double!
    var long:Double!
}

var numbers: String?

var final: String!

var respFinal: String!

var misd: Int!

var misd2: Int!

var fel: Int!

var fel2: Int!

var viol: Int!

var viol2: Int!

var data = Cords()

class ViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == "showResult"){
            let destinationViewController = segue.destination as? SecondaryViewController
            destinationViewController?.safety = final
            destinationViewController?.misd = misd2
            destinationViewController?.viol = viol2
            destinationViewController?.fel = fel2
            present(destinationViewController!, animated: true, completion: nil)
        }
    }
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
        // Do any additional setup after loading the view, typically from a nib.
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.distanceFilter = kCLDistanceFilterNone
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    func safetyStatus(lat: Double, long: Double, completion: @escaping() -> ()) {
        var dict = Dictionary<String, Any>()
        
        print("Function Called")
        
        dict["messages"] = [
            "type" : "request",
            "unstructured": [
                "lat":"\(lat)",
                "long":"\(long)",
                "timestamp" : "10/10/2018"
            ]
        ]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
        
        if let JSONString = String(data: jsonData!, encoding: String.Encoding.utf8) {
            print(JSONString)
        }
        
        
        let url = URL(string: "https://glbm4o82yi.execute-api.us-east-1.amazonaws.com/dev1/safetyalerts")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            print("Sending Response")
            
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            
            print("Response Received")
            
            let decoder = JSONDecoder()
            if let response = try? decoder.decode(Response.self, from: data) {
                let jsonString = response.body
                let jsonData = jsonString.data(using: .utf8)!
                let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves)
                if let personsDictionary = dict as? [String: Any] {
                    print(personsDictionary)
                    if let numbers = personsDictionary["SafetyLevel"] as? String {
                        final = numbers
                    }
                    print(type(of: personsDictionary["CrimeReport"]))
                    if let crimes = personsDictionary["CrimeReport"] as? [String: Any] {
                        if let misd = crimes["MISDEMEANOR"] as? Int {
                            misd2 = misd
                        }
                        if let fel = crimes["FELONY"] as? Int {
                            fel2 = fel
                        }
                        if let viol = crimes["VIOLATION"] as? Int {
                            viol2 = viol
                        }
                        completion()
                    }
                }
            }
        }
        task.resume()
    }
    
    //@IBOutlet weak var activityMonitor: UIActivityIndicatorView!
    
    @IBAction func findLocation(_ sender: Any) {
        
        //activityMonitor.startAnimating()
        activityIndicator.startAnimating()
        activityIndicator.backgroundColor = UIColor.gray
        
        data.lat = locationManager.location!.coordinate.latitude
        data.long = locationManager.location!.coordinate.longitude
        
        guard let lat: Double = data.lat else {
            print("Invalid Lat")
            return
        }
        
        guard let long: Double = data.long else {
            print("Invalid Long")
            return
        }
        
        self.safetyStatus(lat: lat, long: long){
            //self.activityMonitor.stopAnimating()
            //DispatchQueue.main.async {
            guard let respFinal = final else {
                print("No Data")
                return
            }
            self.activityIndicator.stopAnimating()
            self.performSegue(withIdentifier: "showResult", sender: self)
            //}
        }
    }
}
