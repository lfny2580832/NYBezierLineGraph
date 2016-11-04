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

@interface ViewController ()

@property (nonatomic, strong) NYBezierPathGraphView *salesGraphView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
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
