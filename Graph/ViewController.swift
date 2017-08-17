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
    var animateToMinValues = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        graphView = GraphView(frame: CGRect(x: 0.0, y: 100.0, width: 300.0, height: 250.0))
        view.addSubview(graphView)
        
        graphView.clipsToBounds = true
        graphView.layer.cornerRadius = 8.0
        
        graphView.backgroundColor = UIColor(red: 32.0/255.0, green: 40.0/255.0, blue: 66.0/255.0, alpha: 1.0)
        graphView.startColor = UIColor.clear
        graphView.endColor = UIColor.clear
        graphView.startGraphColor = UIColor(red: 51.0/255.0, green: 61.0/255.0, blue: 93.0/255.0, alpha: 1.0)
        graphView.endGraphColor = graphView.backgroundColor!
        graphView.fontColor = UIColor(red: 72.0/255.0, green: 85.0/255.0, blue: 137.0/255.0, alpha: 1.0)
        graphView.graphLineColor = UIColor(red: 94.0/255.0, green: 111.0/255.0, blue: 160.0/255.0, alpha: 1.0)
        graphView.lineWidth = 1.0
        graphView.isEnabledDots = false
        graphView.isEnabledLines = true
        graphView.labelsAlignment = .right
        graphView.labelsTextColor = UIColor(red: 46.0/255.0, green: 195.0/255.0, blue: 151.0/255.0, alpha: 1.0)
        graphView.linesWidth = 0.5
        graphView.maxHorizontalLines = 4
        graphView.maxVerticalLines = 12
        graphView.numberFormatter = { value in
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .currency
            if value < 1.0 {
                numberFormatter.minimumFractionDigits = 1
                numberFormatter.maximumFractionDigits = 6
            } else {
                numberFormatter.minimumFractionDigits = 0
                numberFormatter.maximumFractionDigits = 2
            }
            return numberFormatter
        }
        
        var points: [Double] = []
        for i in 0...10 {
            points.append(Double(i))
        }

        graphView.configure(withPoints: points, columnNames: nil, title: "")
    }

    @IBAction func changeTap(_ sender: Any) {
        var points = [Double]()
        for _ in 0...10 {
            let point = Double(arc4random()).truncatingRemainder(dividingBy: 10)
            points.append(point)
        }
        
        animateToMinValues = !animateToMinValues
        if animateToMinValues {
            graphView.animate(toMinValue: true)
        } else {
            graphView.animate(withPoints: points, columnNames: nil)
        }
    }

}

