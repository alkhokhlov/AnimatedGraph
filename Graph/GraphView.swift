//
//  Graph2View.swift
//  Graph
//
//  Created by Alexandr on 24.01.17.
//  Copyright © 2017 Alexandr. All rights reserved.
//

import UIKit

@IBDesignable class GraphView: UIView {
    
    @IBInspectable var startColor: UIColor = UIColor.red
    @IBInspectable var endColor: UIColor = UIColor.green
    
    var graphLayer = GraphLayer()
    var graphPoints: [Int]!
    var gradient = CAGradientLayer()
    var graphLineLayer = CAShapeLayer()
    var linesLayer = CAShapeLayer()
    var dotsLayer = [CAShapeLayer]()
    var start = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.addSublayer(graphLayer)
        
        gradient.mask = graphLayer
        gradient.colors = [startColor.cgColor, endColor.cgColor]
        layer.addSublayer(gradient)
        
        graphLineLayer.strokeColor = UIColor.white.cgColor
        graphLineLayer.fillColor = UIColor.clear.cgColor
        graphLineLayer.lineWidth = 2.0
        layer.addSublayer(graphLineLayer)
        
        layer.addSublayer(linesLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        graphLayer.fillProperties(parentsBounds: bounds, points: graphPoints)
        
        if start {
            for _ in 0..<graphLayer.graphPoints.count {
                let circleLayer = CAShapeLayer()
                layer.addSublayer(circleLayer)
                dotsLayer.append(circleLayer)
            }
            start = false
        }
        
        gradient.frame = bounds
        gradient.startPoint = CGPoint(x: 0.5, y: graphLayer.highestYPoint / bounds.size.height)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        
        graphLineLayer.path = graphLayer.graphPath.cgPath
        
        lines()
    }
    
    func lines() {
        let linePath = UIBezierPath()
        
        //top line
        linePath.move(to: CGPoint(x: graphLayer.margin, y: graphLayer.topBorder))
        linePath.addLine(to: CGPoint(x: graphLayer.width - graphLayer.margin,
                                     y: graphLayer.topBorder))
        
        //center line
        linePath.move(to: CGPoint(x: graphLayer.margin,
                                  y: graphLayer.graphHeight/2 + graphLayer.topBorder))
        linePath.addLine(to: CGPoint(x: graphLayer.width - graphLayer.margin,
                                     y: graphLayer.graphHeight/2 + graphLayer.topBorder))
        
        //bottom line
        linePath.move(to: CGPoint(x: graphLayer.margin,
                                  y: graphLayer.height - graphLayer.bottomBorder))
        linePath.addLine(to: CGPoint(x: graphLayer.width - graphLayer.margin,
                                     y: graphLayer.height - graphLayer.bottomBorder))
        
        linesLayer.path = linePath.cgPath
        linesLayer.strokeColor = UIColor(white: 1.0, alpha: 0.3).cgColor
        linesLayer.lineWidth = 1.0
        
        dots()
    }
    
    func dots() {
        for i in 0..<graphLayer.graphPoints.count {
            var point = CGPoint(x: graphLayer.columnXPoint(column: i),
                                y: graphLayer.columnYPoint(graphPoint: graphLayer.graphPoints[i]))
            point.x -= 5.0/2
            point.y -= 5.0/2
            
            let circle = UIBezierPath(ovalIn: CGRect(origin: point,
                                                     size: CGSize(width: 5.0, height: 5.0)))
            let circleLayer = dotsLayer[i]
            circleLayer.path = circle.cgPath
            circleLayer.fillColor = UIColor.white.cgColor
        }
    }

    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let colors = [startColor.cgColor, endColor.cgColor]  as CFArray
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let colorLocation:[CGFloat] = [0.0, 1.0]
        
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: colorLocation)
        
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x: 0, y: bounds.size.height)
        
        context!.drawLinearGradient(gradient!,
                                    start: startPoint,
                                    end: endPoint,
                                    options: CGGradientDrawingOptions(rawValue: 0))
    }
    
    func animate(withPoints points: [Int]) {
        let previousHighestY = graphLayer.highestYPoint
        let previousLine = graphLayer.graphPath.cgPath
        
        var animation = CABasicAnimation(keyPath: "path")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.fromValue = graphLayer.rectangle(withPoints: graphLayer.graphPoints).cgPath
        animation.toValue = graphLayer.rectangle(withPoints: points).cgPath
        animation.duration = 0.4
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        graphLayer.add(animation, forKey: "path")
        
        let currentHighestY = graphLayer.highestYPoint
        let currentLine = graphLayer.graphPath.cgPath
        
        animation = CABasicAnimation(keyPath: "startPoint")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.fromValue = CGPoint(x: 0.5, y: previousHighestY! / bounds.size.height)
        animation.toValue = CGPoint(x: 0.5, y: currentHighestY! / bounds.size.height)
        animation.duration = 0.4
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        gradient.add(animation, forKey: "startPoint")
        
        animation = CABasicAnimation(keyPath: "path")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.fromValue = previousLine
        animation.toValue = currentLine
        animation.duration = 0.4
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        graphLineLayer.add(animation, forKey: "path")
        
        var i = 0
        for dot in dotsLayer {
            var point = CGPoint(x: graphLayer.columnXPoint(column: i),
                                y: graphLayer.columnYPoint(graphPoint: graphLayer.graphPoints[i]))
            point.x -= 5.0/2
            point.y -= 5.0/2
            
            let circle = UIBezierPath(ovalIn: CGRect(origin: point,
                                                     size: CGSize(width: 5.0, height: 5.0)))
            
            animation = CABasicAnimation(keyPath: "path")
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            animation.fromValue = dot.path
            animation.toValue = circle.cgPath
            animation.duration = 0.4
            animation.fillMode = kCAFillModeForwards
            animation.isRemovedOnCompletion = false
            dot.add(animation, forKey: "path")
            
            i += 1
            
            dot.path = circle.cgPath
        }
    }

}
