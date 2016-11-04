//
//  HXBBezierPathGraphView.h
//  HXBManagerSalesGraphDemo
//
//  Created by 牛严 on 2016/11/3.
//  Copyright © 2016年 牛严. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NYBezierPathGraphView : UIView

- (void)setValueArray:(NSArray *)valueArray xAxisTitle:(NSString *)xAxisTitle yAxisTitle:(NSString *)yAxisTitle;

@end



@interface GraphPointView : UIView

@property (nonatomic, copy) NSString *content;

@end
