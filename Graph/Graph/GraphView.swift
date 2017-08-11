//
//  Graph2View.swift
//  Graph
//
//  Created by Alexandr on 24.01.17.
//  Copyright © 2017 Alexandr. All rights reserved.
//

import UIKit

protocol GraphViewUsageProtocol {
    
    /// At first you need to configure graph with launch data.
    ///
    /// - Parameters:
    ///   - points: Launch array of points
    ///   - columnNames: Bottom located column names.
    ///   - title: Title of graph
    func configure(withPoints points: [Double], columnNames: [String]?, title: String?)

    /// Use this method to animate graph with other points and column names.
    /// - Parameters:
    ///   - points: Array of points
    ///   - columnNames: Array of column names
    func animate(withPoints points: [Double], columnNames: [String]?)
}

class GraphView: UIView, GraphViewUsageProtocol {
    
    enum LabelsAlignment {
        case left
        case right
    }
    
    var startColor: UIColor = UIColor.red
    var endColor: UIColor = UIColor.green
    var startGraphColor: UIColor = UIColor.red
    var endGraphColor: UIColor = UIColor.green
    var fontColor: UIColor = UIColor.white
    var lineWidth: CGFloat = 2.0
    var isEnabledDots = true
    var isEnabledLines = true
    var labelsAlignment: LabelsAlignment = .left
    var labelsTextColor: UIColor = UIColor.white
    var linesColor: UIColor = UIColor.white
    var linesWidth: CGFloat = 1.0
    var graphPadding: UIEdgeInsets {
        get {
            return graphLayer.padding
        }
        set {
            graphLayer.padding = newValue
        }
    }
    
    var graphPoints: [Double] = []
    var graphColumnNames: [String]?
    var title = ""
    
    private var graphLayer = GraphLayer()
    private var gradient = CAGradientLayer()
    private var graphLineLayer = CAShapeLayer()
    private var linesLayer = CAShapeLayer()
    private var dotsLayer = [CAShapeLayer]()
    private var bottomLabels = [UILabel]()
    
    // MARK: - Life Cycle
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        
        graphLayer.frame.size = frame.size
        layer.addSublayer(graphLayer)
        
        gradient.mask = graphLayer
        layer.addSublayer(gradient)
        
        layer.addSublayer(graphLineLayer)
        layer.addSublayer(linesLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init?(coder aDecoder: NSCoder) is not required")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        removeLabels()
        
        graphLayer.fillProperties(points: graphPoints)
        
        gradient.frame = bounds
        gradient.startPoint = CGPoint(x: 0.5, y: graphLayer.highestYPoint / bounds.size.height)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        
        graphLineLayer.path = graphLayer.graphPath.cgPath
        
        titleLabel()
        
        if isEnabledLines {
            lines()
        }
        
        labels()
        
        if isEnabledDots {
            dots()
        }
    }
    
    // MARK: - Public
    
    func animate(withPoints points: [Double], columnNames: [String]?) {
        if let columnNames = columnNames {
            assert(points.count == columnNames.count, "'points' and 'columns' count must be the same")
            
            graphColumnNames = columnNames
            var i = 0
            for label in bottomLabels {
                label.text = columnNames[i]
                i += 1
            }
        }
        
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
    
    func configure(withPoints points: [Double], columnNames: [String]?, title: String?) {
        if let columnNames = columnNames {
            assert(points.count == columnNames.count, "'points' and 'columns' count must be the same")
            graphColumnNames = columnNames
        }
        
        graphPoints = points
        gradient.colors = [startGraphColor.cgColor, endGraphColor.cgColor]
        graphLineLayer.strokeColor = fontColor.cgColor
        graphLineLayer.fillColor = UIColor.clear.cgColor
        graphLineLayer.lineWidth = lineWidth
        
        if isEnabledDots {
            for _ in 0..<graphPoints.count {
                let circleLayer = CAShapeLayer()
                layer.addSublayer(circleLayer)
                dotsLayer.append(circleLayer)
            }
        }

        if let title = title {
            self.title = title
        }
    }
    
    // MARK: - Private
    
    private func removeLabels() {
        for subview in subviews {
            if subview is UILabel {
                subview.removeFromSuperview()
            }
        }
    }
    
    private func titleLabel() {
        let margin: CGFloat = 8
        let labelHeight: CGFloat = 25
        let labelSize: CGFloat = 16
        
        let label = UILabel(frame: CGRect(x: margin,
                                          y: margin,
                                          width: frame.size.width - margin,
                                          height: labelHeight))
        label.text = title
        label.font = UIFont.boldSystemFont(ofSize: labelSize)
        label.textColor = fontColor
        label.textAlignment = .center
        addSubview(label)
    }
    
    private func lines() {
        let linePath = UIBezierPath()
        
        //top line
        linePath.move(to: CGPoint(x: graphLayer.padding.left,
                                  y: graphLayer.padding.top))
        linePath.addLine(to: CGPoint(x: graphLayer.bounds.width - graphLayer.padding.right,
                                     y: graphLayer.padding.top))
        
        
        
        //center line
        linePath.move(to: CGPoint(x: graphLayer.padding.left,
                                  y: graphLayer.graphHeight/2 + graphLayer.padding.top))
        linePath.addLine(to: CGPoint(x: graphLayer.bounds.width - graphLayer.padding.right,
                                     y: graphLayer.graphHeight/2 + graphLayer.padding.top))
        
        
        
        //bottom line
        linePath.move(to: CGPoint(x: graphLayer.padding.left,
                                  y: graphLayer.bounds.height - graphLayer.padding.bottom))
        linePath.addLine(to: CGPoint(x: graphLayer.bounds.width - graphLayer.padding.right,
                                     y: graphLayer.bounds.height - graphLayer.padding.bottom))
        
        linesLayer.path = linePath.cgPath
        linesLayer.strokeColor = linesColor.withAlphaComponent(0.3).cgColor
        linesLayer.lineWidth = linesWidth
    }
    
    private func labels() {
        let labelHeight: CGFloat = 12.0
        let labelSize: CGFloat = 11.0
        
        //top line label
        var label = UILabel(frame: CGRect(x: labelsAlignment == .left ? 0 : bounds.width - graphLayer.padding.right,
                                          y: graphLayer.padding.top - labelHeight/2,
                                          width: labelsAlignment == .left ? graphLayer.padding.left : graphLayer.padding.right,
                                          height: labelHeight))
        label.text = String(describing: graphPoints.max()!)
        label.font = label.font.withSize(labelSize)
        label.textColor = labelsTextColor
        label.textAlignment = .center
        addSubview(label)
        
        //center line label
        label = UILabel(frame: CGRect(x: labelsAlignment == .left ? 0 : bounds.width - graphLayer.padding.right,
                                      y: graphLayer.graphHeight/2 + graphLayer.padding.top - labelHeight/2,
                                      width: labelsAlignment == .left ? graphLayer.padding.left : graphLayer.padding.right,
                                      height: labelHeight))
        label.text = String(describing: graphPoints.max()!/2)
        label.font = label.font.withSize(labelSize)
        label.textColor = labelsTextColor
        label.textAlignment = .center
        addSubview(label)
        
        //bottom line label
        label = UILabel(frame: CGRect(x: labelsAlignment == .left ? 0 : bounds.width - graphLayer.padding.right,
                                      y: graphLayer.bounds.height - graphLayer.padding.bottom - labelHeight/2,
                                      width: labelsAlignment == .left ? graphLayer.padding.left : graphLayer.padding.right,
                                      height: labelHeight))
        label.text = String(describing: graphPoints.min()!)
        label.font = label.font.withSize(labelSize)
        label.textColor = labelsTextColor
        label.textAlignment = .center
        addSubview(label)
        
        //bottom labels
        if let graphColumnNames = graphColumnNames {
            bottomLabels = [UILabel]()
            
            let pointY = graphLayer.bounds.height - graphLayer.padding.bottom/2
            for i in 0..<graphLayer.graphPoints.count {
                let pointX = graphLayer.columnXPoint(column: i)
                
                label = UILabel(frame: CGRect(x: pointX - graphLayer.padding.left/2,
                                              y: pointY - labelHeight/2,
                                              width: labelsAlignment == .left ? graphLayer.padding.left : graphLayer.padding.right,
                                              height: labelHeight))
                label.text = String(describing: graphColumnNames[i])
                label.font = label.font.withSize(labelSize)
                label.textColor = fontColor
                label.textAlignment = .center
                addSubview(label)
                
                bottomLabels.append(label)
            }
        }
    }
    
    private func dots() {
        for i in 0..<graphLayer.graphPoints.count {
            var point = CGPoint(x: graphLayer.columnXPoint(column: i),
                                y: graphLayer.columnYPoint(graphPoint: graphLayer.graphPoints[i]))
            point.x -= 5.0/2
            point.y -= 5.0/2
            
            let circle = UIBezierPath(ovalIn: CGRect(origin: point,
                                                     size: CGSize(width: 5.0, height: 5.0)))
            let circleLayer = dotsLayer[i]
            circleLayer.path = circle.cgPath
            circleLayer.fillColor = fontColor.cgColor
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

}
