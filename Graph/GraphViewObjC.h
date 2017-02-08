//
//  GraphViewObjC.h
//  Graph
//
//  Created by Alexandr on 25.01.17.
//  Copyright © 2017 Alexandr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphLayerObjC.h"
IB_DESIGNABLE
@interface GraphViewObjC : UIView

@property (nonatomic, strong) IBInspectable UIColor *startColor, *endColor;
@property (nonatomic, strong) GraphLayerObjC *graphLayer;
@property (nonatomic, strong) NSArray *graphPoints;
@property (nonatomic, strong) CAGradientLayer *gradient;
@property (nonatomic, strong) CAShapeLayer *graphLineLayer, *linesLayer;
@property (nonatomic, strong) NSMutableArray *dotsLayer;

- (void)animateWithPoints:(NSArray *)points;

@end
