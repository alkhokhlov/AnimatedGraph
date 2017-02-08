//
//  GraphLayerObjC.h
//  Graph
//
//  Created by Alexandr on 25.01.17.
//  Copyright © 2017 Alexandr. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface GraphLayerObjC : CAShapeLayer

@property (nonatomic, strong) NSArray *graphPoints;
@property (nonatomic, strong) UIBezierPath *graphPath;
@property (nonatomic, assign) CGFloat margin, topBorder, bottomBorder, graphHeight, highestYPoint, width, height;

- (void)fillPropertiesWithParentsBounds:(CGRect)parentsBounds withPoints:(NSArray *)points;
- (UIBezierPath *)rectangleWithPoints:(NSArray *)points;
- (CGFloat)columnYPointWithGraphPoint:(NSInteger)graphPoint;
- (CGFloat)columnXPointWithColumn:(NSInteger)column;

@end
