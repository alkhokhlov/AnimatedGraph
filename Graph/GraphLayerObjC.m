//
//  GraphLayerObjC.m
//  Graph
//
//  Created by Alexandr on 25.01.17.
//  Copyright © 2017 Alexandr. All rights reserved.
//

#import "GraphLayerObjC.h"

@interface GraphLayerObjC ()

@property (nonatomic, assign) CGRect parentsBounds;

@end

@implementation GraphLayerObjC

- (void)fillPropertiesWithParentsBounds:(CGRect)parentsBounds withPoints:(NSArray *)points {
    self.margin = 20.0f;
    self.topBorder = 60.0f;
    self.bottomBorder = 50.0f;
    
    self.parentsBounds = parentsBounds;
    self.width = parentsBounds.size.width;
    self.height = parentsBounds.size.height;
    self.graphPoints = points;
    
    self.path = [[self rectangleWithPoints:self.graphPoints] CGPath];
    self.fillColor = [[UIColor whiteColor] CGColor];
}

- (UIBezierPath *)rectangleWithPoints:(NSArray *)points {
    self.graphPoints = points;
    
    self.graphHeight = self.height - self.topBorder - self.bottomBorder;
    
    self.graphPath = [UIBezierPath new];
    
    [self.graphPath moveToPoint:CGPointMake([self columnXPointWithColumn:0],
                                            [self columnYPointWithGraphPoint:[points[0] integerValue]])];
    for (int i = 0; i < points.count; i++) {
        CGPoint nextPoint = CGPointMake([self columnXPointWithColumn:i],
                                        [self columnYPointWithGraphPoint:[points[i] integerValue]]);
        [self.graphPath addLineToPoint:nextPoint];
    }
    
    self.highestYPoint = [self columnYPointWithGraphPoint:[[points valueForKeyPath:@"@max.intValue"] integerValue]];
    
    UIBezierPath *clippingPath = [self.graphPath copy];
    [clippingPath addLineToPoint:CGPointMake([self columnXPointWithColumn:points.count - 1],
                                            self.height)];
    [clippingPath addLineToPoint:CGPointMake([self columnXPointWithColumn:0],
                                             self.height)];
    [clippingPath closePath];
    
    return clippingPath;
}

- (CGFloat)columnYPointWithGraphPoint:(NSInteger)graphPoint {
    NSInteger maxValue = [[self.graphPoints valueForKeyPath:@"@max.intValue"] integerValue];
    CGFloat y = (CGFloat)graphPoint/maxValue*self.graphHeight;
    y = self.graphHeight + self.topBorder - y;
    return y;
}

- (CGFloat)columnXPointWithColumn:(NSInteger)column {
    CGFloat spacer = (self.width - self.margin * 2 - 4) / (self.graphPoints.count - 1);
    CGFloat x = column * spacer;
    x += self.margin + 2;
    return x;
}

@end
