//
//  UIBezierPath+DrawPointsBezier.h
//  HXBManagerSalesGraphDemo
//
//  Created by 牛严 on 2016/11/4.
//  Copyright © 2016年 牛严. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBezierPath (DrawPointsBezier)

@property (nonatomic) CGFloat contractionFactor;

- (void)addBezierThroughPoints:(NSArray *)pointArray;

@end
