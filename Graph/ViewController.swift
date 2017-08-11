//
//  ViewController.swift
//  Graph
//
//  Created by Alexandr on 23.01.17.
//  Copyright © 2017 Alexandr. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var graphView: GraphView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        graphView = GraphView(frame: CGRect(x: 0.0, y: 100.0, width: 300.0, height: 250.0))
        view.addSubview(graphView)
        
        graphView.clipsToBounds = true
        graphView.layer.cornerRadius = 8.0
        
        graphView.startColor = UIColor(red: 32.0/255.0, green: 40.0/255.0, blue: 66.0/255.0, alpha: 1.0)
        graphView.endColor = UIColor(red: 32.0/255.0, green: 40.0/255.0, blue: 66.0/255.0, alpha: 1.0)
        graphView.startGraphColor = UIColor(red: 53.0/255.0, green: 63.0/255.0, blue: 96.0/255.0, alpha: 1.0)
        graphView.endGraphColor = graphView.endColor
        graphView.fontColor = UIColor.white
        graphView.lineWidth = 1.0
        graphView.isEnabledDots = false
        graphView.isEnabledLines = false
        graphView.labelsAlignment = .right
        graphView.labelsTextColor = UIColor.white
        graphView.linesWidth = 0.5
        
        var points: [Double] = []
        for i in 1...10 {
            points.append(Double(i))
        }

        graphView.configure(withPoints: points, columnNames: nil, title: "Awesome graph")
    }

    @IBAction func changeTap(_ sender: Any) {
        var points = [Double]()
        for _ in 1...10 {
            let point = Double(arc4random()).truncatingRemainder(dividingBy: 10)
            points.append(point)
        }

        graphView.animate(withPoints: points, columnNames: nil)
    }

}

