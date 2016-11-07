//
//  ViewController.m
//  HXBManagerSalesGraphDemo
//
//  Created by 牛严 on 2016/11/3.
//  Copyright © 2016年 牛严. All rights reserved.
//

#import "ViewController.h"
#import "NYBezierPathGraphView.h"

#define SCREEN_WIDTH ([[UIScreen mainScreen]bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen]bounds].size.height)
#define rgb(r,g,b) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0f]

@interface ViewController ()

@property (nonatomic, strong) NYBezierPathGraphView *salesGraphView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = rgb(247, 247, 247);
    [self.view addSubview:self.salesGraphView];
    
    NSArray *arr1 = @[@"14",@"42",@"15",@"35",@"22",@"30"];
    [self.salesGraphView setValueArray:arr1 xAxisTitle:@"月份" yAxisTitle:@"销售额(万元)"];
}
 

- (NYBezierPathGraphView *)salesGraphView
{
    if (!_salesGraphView) {
        _salesGraphView = [[NYBezierPathGraphView alloc]initWithFrame:CGRectMake(0, 100,SCREEN_WIDTH,250)];
        
    }
    return _salesGraphView;
}

@end
