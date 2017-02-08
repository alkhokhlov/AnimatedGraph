//
//  GraphLayer.swift
//  Graph
//
//  Created by Alexandr on 24.01.17.
//  Copyright © 2017 Alexandr. All rights reserved.
//

import UIKit

class GraphLayer: CAShapeLayer {
    
    var graphPoints: [Int]!
    var graphPath: UIBezierPath!
    var margin: CGFloat = 20.0
    var topBorder:CGFloat = 60.0
    var bottomBorder:CGFloat = 50.0
    var graphHeight: CGFloat!
    var highestYPoint: CGFloat!
    var width: CGFloat!
    var height: CGFloat!
    private var parentsBounds: CGRect!

    func fillProperties(parentsBounds: CGRect, points: [Int]) {
        self.parentsBounds = parentsBounds
        self.width = parentsBounds.size.width
        self.height = parentsBounds.size.height
        self.graphPoints = points
        
        path = rectangle(withPoints: graphPoints).cgPath
        fillColor = UIColor.white.cgColor
    }
    
    func rectangle(withPoints points: [Int]) -> UIBezierPath {
        graphPoints = points
        
        graphHeight = height - topBorder - bottomBorder
        
        graphPath = UIBezierPath()
        
        graphPath.move(to: CGPoint(x: columnXPoint(column: 0),
                                   y: columnYPoint(graphPoint: points[0])))
        
        for i in 1..<points.count {
            let nextPoint = CGPoint(x: columnXPoint(column: i),
                                    y: columnYPoint(graphPoint: points[i]))
            graphPath.addLine(to: nextPoint)
        }
        
        highestYPoint = columnYPoint(graphPoint: points.max()!)
        
        let clippingPath = graphPath.copy() as! UIBezierPath
        
        clippingPath.addLine(to: CGPoint(
            x: columnXPoint(column: points.count - 1),
            y:height))
        clippingPath.addLine(to: CGPoint(
            x:columnXPoint(column: 0),
            y:height))
        clippingPath.close()
        
        return clippingPath
    }
    
    func columnYPoint(graphPoint: Int) -> CGFloat {
        let maxValue = graphPoints.max()
        var y:CGFloat = CGFloat(graphPoint) / CGFloat(maxValue!) * self.graphHeight
        y = self.graphHeight + self.topBorder - y
        return y
    }
    
    func columnXPoint(column: Int) -> CGFloat {
        let spacer = (self.width - self.margin*2 - 4) / CGFloat((graphPoints.count - 1))
        var x:CGFloat = CGFloat(column) * spacer
        x += self.margin + 2
        return x
    }
    
}
