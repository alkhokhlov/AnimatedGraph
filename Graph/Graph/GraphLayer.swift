//
//  GraphLayer.swift
//  Graph
//
//  Created by Alexandr on 24.01.17.
//  Copyright © 2017 Alexandr. All rights reserved.
//

import UIKit

final class GraphLayer: CAShapeLayer {
    
    var graphPoints: [Double] = []
    var graphPath: UIBezierPath!
    var graphHeight: CGFloat!
    var graphWidth: CGFloat!
    var highestYPoint: CGFloat!
    var isAnimatingMinValues = false
    var previousPath: UIBezierPath!
    var padding: UIEdgeInsets = UIEdgeInsets(top: 24.0, left: 0.0, bottom: 40.0, right: 44.0)
    
    func fillProperties(points: [Double]) {
        graphPoints = points
        
        path = rectangle(withPoints: graphPoints).cgPath
        fillColor = UIColor.white.cgColor
    }
    
    func rectangle(withPoints points: [Double]) -> UIBezierPath {
        graphPoints = points
        
        graphHeight = bounds.height - padding.top - padding.bottom
        graphWidth = bounds.width - padding.right - padding.left
        
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
            y: bounds.height))
        clippingPath.addLine(to: CGPoint(
            x: columnXPoint(column: 0),
            y: bounds.height))
        clippingPath.close()
        
        previousPath = clippingPath
        
        return previousPath
    }
    
    func columnYPoint(graphPoint: Double) -> CGFloat {
        var y = CGFloat((graphPoint - graphPoints.min()!) / (graphPoints.max()! - graphPoints.min()!))
        y = graphHeight + padding.top - (isAnimatingMinValues ? 0.0 : y) * graphHeight
        return y
    }
    
    func columnXPoint(column: Int) -> CGFloat {
        let spacer = (bounds.width - (padding.left + padding.right)) / CGFloat((graphPoints.count - 1))
        var x = CGFloat(column) * spacer
        x += padding.left
        return x
    }
    
}
