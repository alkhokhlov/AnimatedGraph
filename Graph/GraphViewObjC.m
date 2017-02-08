//
//  GraphViewObjC.m
//  Graph
//
//  Created by Alexandr on 25.01.17.
//  Copyright © 2017 Alexandr. All rights reserved.
//

#import "GraphViewObjC.h"

@interface GraphViewObjC ()

@property (nonatomic, assign) BOOL start;

@end

@implementation GraphViewObjC

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.start = YES;
    
    self.dotsLayer = [NSMutableArray new];
    
    self.graphLayer = [GraphLayerObjC new];
    self.gradient = [CAGradientLayer new];
    self.graphLineLayer = [CAShapeLayer new];
    self.linesLayer = [CAShapeLayer new];
    
    [self.layer addSublayer:self.graphLayer];
    
    self.gradient.mask = self.graphLayer;
    self.gradient.colors = @[(id)[self.startColor CGColor], (id)[self.endColor CGColor]];
    [self.layer addSublayer:self.gradient];
    
    self.graphLineLayer.strokeColor = [[UIColor whiteColor] CGColor];
    self.graphLineLayer.fillColor = [[UIColor clearColor] CGColor];
    self.graphLineLayer.lineWidth = 2.0f;
    [self.layer addSublayer:self.graphLineLayer];
    
    [self.layer addSublayer:self.linesLayer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.graphLayer fillPropertiesWithParentsBounds:self.bounds withPoints:self.graphPoints];
    
    if (self.start) {
        for (int i = 0; i < self.graphLayer.graphPoints.count; i++) {
            CAShapeLayer *circleLayer = [CAShapeLayer new];
            [self.layer addSublayer:circleLayer];
            [self.dotsLayer addObject:circleLayer];
        }
        self.start = NO;
    }
    
    self.gradient.frame = self.bounds;
    self.gradient.startPoint = CGPointMake(0.5f, self.graphLayer.highestYPoint / self.bounds.size.height);
    self.gradient.endPoint = CGPointMake(0.5f, 1.0f);
    
    self.graphLineLayer.path = [self.graphLayer.graphPath CGPath];
    
    [self lines];
}

- (void)lines {
    UIBezierPath *linePath = [UIBezierPath new];
    
    //top line
    [linePath moveToPoint:CGPointMake(self.graphLayer.margin,
                                      self.graphLayer.topBorder)];
    [linePath addLineToPoint:CGPointMake(self.graphLayer.width - self.graphLayer.margin,
                                         self.graphLayer.topBorder)];
    
    //center line
    [linePath moveToPoint:CGPointMake(self.graphLayer.margin,
                                      self.graphLayer.graphHeight/2 + self.graphLayer.topBorder)];
    [linePath addLineToPoint:CGPointMake(self.graphLayer.width - self.graphLayer.margin,
                                         self.graphLayer.graphHeight/2 + self.graphLayer.topBorder)];
    
    //bottom line
    [linePath moveToPoint:CGPointMake(self.graphLayer.margin,
                                      self.graphLayer.height - self.graphLayer.bottomBorder)];
    [linePath addLineToPoint:CGPointMake(self.graphLayer.width - self.graphLayer.margin,
                                         self.graphLayer.height - self.graphLayer.bottomBorder)];
    
    self.linesLayer.path = [linePath CGPath];
    self.linesLayer.strokeColor = [[[UIColor whiteColor] colorWithAlphaComponent:0.3f] CGColor];
    [self.linesLayer setLineWidth:1.0f];
    
    [self dots];
}

- (void)dots {
    for (int i = 0; i < self.graphLayer.graphPoints.count; i++) {
        CGPoint point = CGPointMake([self.graphLayer columnXPointWithColumn:i],
                                    [self.graphLayer columnYPointWithGraphPoint:[self.graphLayer.graphPoints[i] integerValue]]);
        point.x -= 5.0f/2.0f;
        point.y -= 5.0f/2.0f;
        
        UIBezierPath *circle = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(point.x, point.y, 5.0f, 5.0f)];
        CAShapeLayer *circleLayer = self.dotsLayer[i];
        circleLayer.path = [circle CGPath];
        circleLayer.fillColor = [[UIColor whiteColor] CGColor];
    }
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    NSArray *colors = (@[(id)[self.startColor CGColor], (id)[self.endColor CGColor]]);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat colorLocation[2] = {0.0, 1.0};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, colorLocation);
    CGPoint startPoint = CGPointZero;
    CGPoint endPoint = CGPointMake(0, self.bounds.size.height);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
}

- (void)animateWithPoints:(NSArray *)points {
    CGFloat previousHighestY = self.graphLayer.highestYPoint;
    CGPathRef previousLine = [self.graphLayer.graphPath CGPath];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    animation.fromValue = (__bridge id _Nullable)([[self.graphLayer rectangleWithPoints:self.graphLayer.graphPoints] CGPath]);
    animation.toValue = (__bridge id _Nullable)([[self.graphLayer rectangleWithPoints:points] CGPath]);
    animation.duration = 0.4f;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    [self.graphLayer addAnimation:animation forKey:animation.keyPath];
    
    CGFloat currentHighestY = self.graphLayer.highestYPoint;
    CGPathRef currentLine = [self.graphLayer.graphPath CGPath];
    
    animation = [CABasicAnimation animationWithKeyPath:@"startPoint"];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(0.5f, previousHighestY / self.bounds.size.height)];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(0.5f, currentHighestY / self.bounds.size.height)];
    animation.duration = 0.4f;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    [self.gradient addAnimation:animation forKey:animation.keyPath];
    
    animation = [CABasicAnimation animationWithKeyPath:@"path"];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    animation.fromValue = (__bridge id _Nullable)(previousLine);
    animation.toValue = (__bridge id _Nullable)(currentLine);
    animation.duration = 0.4f;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    [self.graphLineLayer addAnimation:animation forKey:animation.keyPath];
    
    int i = 0;
    for (CAShapeLayer *dot in self.dotsLayer) {
        CGPoint point = CGPointMake([self.graphLayer columnXPointWithColumn:i],
                                    [self.graphLayer columnYPointWithGraphPoint:[self.graphLayer.graphPoints[i] integerValue]]);
        point.x -= 5.0/2.0;
        point.y -= 5.0/2.0;
        
        UIBezierPath *circle = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(point.x, point.y, 5.0f, 5.0f)];
        
        animation = [CABasicAnimation animationWithKeyPath:@"path"];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        animation.fromValue = (__bridge id _Nullable)(dot.path) ;
        animation.toValue = (__bridge id _Nullable)([circle CGPath]);
        animation.duration = 0.4f;
        animation.fillMode = kCAFillModeForwards;
        animation.removedOnCompletion = NO;
        [dot addAnimation:animation forKey:animation.keyPath];
        
        i++;
        
        dot.path = [circle CGPath];
    }
}


@end
