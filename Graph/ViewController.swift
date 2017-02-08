//
//  ViewController.swift
//  Graph
//
//  Created by Alexandr on 23.01.17.
//  Copyright © 2017 Alexandr. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var graphView: GraphView!

    override func viewDidLoad() {
        super.viewDidLoad()

        graphView.clipsToBounds = true
        graphView.layer.cornerRadius = 8.0
        
        let points: [Double] = [1, 2, 3, 4, 5, 6, 7, 8, 9]
        let columnNames = ["One", "Two", "Thr", "Fou", "Fiv", "Six", "Sev", "Eig", "Nin"]

        graphView.configure(withPoints: points, columnNames: columnNames, title: "Awesome graph")
    }

    @IBAction func changeTap(_ sender: Any) {
        var points = [Double]()
        for _ in 0..<9 {
            let point = Double(arc4random()).truncatingRemainder(dividingBy: 10)
            points.append(point)
        }
        
        graphView.animate(withPoints: points)
    }

}

