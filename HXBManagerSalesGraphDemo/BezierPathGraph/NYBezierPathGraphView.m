//
//  HXBBezierPathGraphView.m
//  HXBManagerSalesGraphDemo
//
//  Created by 牛严 on 2016/11/3.
//  Copyright © 2016年 牛严. All rights reserved.
//

#import "NYBezierPathGraphView.h"
#import "UIBezierPath+DrawPointsBezier.h"

#define rgb(r,g,b) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0f]

static const NSInteger xAxisOriginY = 212;


@interface NYBezierPathGraphView ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) UIBezierPath *curvePath;

@property (nonatomic, strong) UIView *panView;
@property (nonatomic, strong) UIView *panLine;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;

@property (nonatomic, copy) NSString *xAxisTitle;   /// x轴数据title
@property (nonatomic, copy) NSString *yAxisTitle;   /// y轴数据title

@property (nonatomic, copy) NSArray *valueArray;

@property (nonatomic, strong) NSMutableArray *pointYArray;           ///数据Y坐标数组
@property (nonatomic, strong) NSMutableArray *xAxisPointXArray;      ///横坐标上数字的坐标数组，从左到右，也是数据的X坐标数组
@property (nonatomic, strong) NSMutableArray *yAxisPointYArray;      ///纵坐标上数字的坐标数组，从下到上
@property (nonatomic, strong) NSMutableArray *xAxisValueArray;       ///横坐标上的数字数组
@property (nonatomic, strong) NSMutableArray *yAxisValueArray;       ///纵坐标上的数字数组
@property (nonatomic, strong) NSMutableArray *pointViewArray;


@end

@implementation NYBezierPathGraphView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.bgImageView];
    }
    return self;
}

#pragma mark 设置初始化参数
- (void)setValueArray:(NSArray *)valueArray xAxisTitle:(NSString *)xAxisTitle yAxisTitle:(NSString *)yAxisTitle
{
    self.valueArray = valueArray;
    self.xAxisTitle = xAxisTitle;
    self.yAxisTitle = yAxisTitle;
    [self getXAxisArrayFromCurrentDate];
    [self getYAxisArray];
    [self drawBezierLineGraph];
    [self addPointViews];
    [self addCoordinateView];
}

#pragma mark 私有方法
///根据当前日期计算横坐标数组
- (void)getXAxisArrayFromCurrentDate
{
    CGFloat stepX = (self.frame.size.width - 105)/5;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
    NSInteger currentMonth = dateComponents.month;
    NSInteger baseX = self.frame.size.width - 38;
    self.xAxisValueArray = [NSMutableArray array];
    self.xAxisPointXArray = [NSMutableArray array];
    for (NSInteger i = self.valueArray.count - 1; i >= 0 ; i--) {
        if (currentMonth - i <= 0) {
            [self.xAxisValueArray addObject:@(currentMonth - i + 12)];
        }else{
            [self.xAxisValueArray addObject:@(currentMonth - i)];
        }
        [self.xAxisPointXArray addObject:@(baseX - i * stepX)];
    }
}

///根据数据内容计算纵坐标上的数字
- (void)getYAxisArray
{
    self.yAxisValueArray = [NSMutableArray array];
    self.yAxisPointYArray = [NSMutableArray array];
    
    CGFloat max = ceil([[self.valueArray valueForKeyPath:@"@max.floatValue"] floatValue]);
    CGFloat min = floor([[self.valueArray valueForKeyPath:@"@min.floatValue"] floatValue]);
    NSInteger step = 0;
    if (max - min <= 7) {
        max = min + 7;
    }else{
        NSInteger space = max - min;
        NSInteger remainder = space % 7;
        max += 7 - remainder;
    }
    step = (max - min) / 7;
    NSInteger yAxisStepY = 23;
    
    CGFloat baseY = 180;
    self.pointYArray = [NSMutableArray array];
    for (int i = 0; i < self.valueArray.count; i ++) {
        CGFloat valueY = baseY - ([self.valueArray[i] floatValue] - min)/step * yAxisStepY;               /// Y坐标上数字的Y坐标
        [self.pointYArray addObject:@(valueY)];
    }
    for (int i = 0; i < 7; i ++) {
        [self.yAxisValueArray addObject:@((NSInteger)step * i + min)];
        [self.yAxisPointYArray addObject:@(baseY - i * 23)];
    }
}

///添加数据点视图
- (void)addPointViews
{
    self.pointViewArray = [NSMutableArray array];
    for (int i = 0; i < self.valueArray.count; i ++)
    {
        CGPoint point = CGPointMake([self.xAxisPointXArray[i] floatValue], [self.pointYArray[i] floatValue]);
        GraphPointView *pointView = [[GraphPointView alloc]initWithFrame:CGRectMake(0, 0, 37, 52)];
        pointView.alpha = 0;
        pointView.center = CGPointMake(point.x, point.y);
        pointView.content = [NSString stringWithFormat:@"%.1f",[self.valueArray[i] floatValue]];
        [self addSubview:pointView];
        [self.pointViewArray addObject:pointView];
    }
}

///添加坐标系上的label
- (void)addCoordinateView
{
    UILabel *yTitle = [[UILabel alloc]initWithFrame:CGRectMake(25, 10, 70, 12)];
    yTitle.text = self.yAxisTitle;
    yTitle.font = [UIFont systemFontOfSize:12];
    yTitle.textColor = [UIColor whiteColor];
    [self addSubview:yTitle];
    
    UILabel *xTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 25, 11)];
    xTitle.center = CGPointMake(25 + 11, xAxisOriginY);
    xTitle.text = self.xAxisTitle;
    xTitle.font = [UIFont systemFontOfSize:11];
    xTitle.textColor = [UIColor whiteColor];
    [self addSubview:xTitle];
    
    for (int i = 0; i < self.xAxisValueArray.count; i ++) {
        NSInteger x = [self.xAxisPointXArray[i] integerValue];
        NSInteger y = xAxisOriginY;
        
        UILabel *xAxisLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 20, 11)];
        xAxisLabel.center = CGPointMake(x, y);
        xAxisLabel.textAlignment = NSTextAlignmentCenter;
        xAxisLabel.font = [UIFont systemFontOfSize:11];
        xAxisLabel.textColor = [UIColor whiteColor];
        xAxisLabel.text = [NSString stringWithFormat:@"%02ld",(long)[self.xAxisValueArray[i] integerValue]];
        [self addSubview:xAxisLabel];
    }
    for (int i = 0; i < self.yAxisValueArray.count; i ++) {
        NSInteger x = 25;
        NSInteger y = [self.yAxisPointYArray[i] floatValue];
        
        UILabel *yAxisLabel = [[UILabel alloc]initWithFrame:CGRectMake(x, y, 20, 11)];
        yAxisLabel.font = [UIFont systemFontOfSize:11];
        yAxisLabel.textColor = [UIColor whiteColor];
        yAxisLabel.text = [NSString stringWithFormat:@"%ld",(long)[self.yAxisValueArray[i] integerValue]];
        [self addSubview:yAxisLabel];
    }
}

///画线
- (void)drawBezierLineGraph
{
    NSMutableArray *pointPositionArray = [NSMutableArray array];
    for (int i = 0; i < self.valueArray.count; i ++) {
        CGPoint point = CGPointMake([self.xAxisPointXArray[i] floatValue], [self.pointYArray[i] floatValue]);
        [pointPositionArray addObject:[NSValue valueWithCGPoint:point]];
    }
    NSValue *firstPointValue = pointPositionArray.firstObject;
    self.curvePath = [[UIBezierPath alloc]init];
    [self.curvePath moveToPoint:firstPointValue.CGPointValue];
    self.curvePath.contractionFactor = 0.7;
    [self.curvePath addBezierThroughPoints:pointPositionArray];
    
    self.shapeLayer = [CAShapeLayer layer];
    self.shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
    self.shapeLayer.fillColor = nil;
    self.shapeLayer.lineWidth = 3;
    self.shapeLayer.path = self.curvePath.CGPath;
    self.shapeLayer.lineCap = kCALineCapRound;
    
    CGFloat graphMaxX = [[self.xAxisPointXArray valueForKeyPath:@"@max.floatValue"] floatValue];
    CGFloat graphMinX = [[self.xAxisPointXArray valueForKeyPath:@"@min.floatValue"] floatValue];
    CGFloat graphMaxY = [[self.pointYArray valueForKeyPath:@"@max.floatValue"] floatValue];
    CGFloat graphMinY = [[self.pointYArray valueForKeyPath:@"@min.floatValue"] floatValue];
    
    self.panView = [[UIView alloc]initWithFrame:CGRectMake(graphMinX, graphMinY, graphMaxX-graphMinX, graphMaxY-graphMinY)];
    self.panView.backgroundColor = [UIColor blackColor];
    self.panView.clipsToBounds = YES;
    self.panView.backgroundColor = [UIColor clearColor];
    [self.panView addGestureRecognizer:self.panGesture];
    [self.panView addGestureRecognizer:self.longPressGesture];
    [self.panView addSubview:self.panLine];
    [self addSubview:self.panView];

    [self.layer addSublayer:self.shapeLayer];
}

#pragma mark Touch Gesture
- (void)handleGestureAction:(UIGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer locationInView:self];
    CGPoint convertedPoint =  [self convertPoint:translation toView:self.panView];
    self.panLine.frame = CGRectMake(convertedPoint.x - 0.5, 0, 0.5, 182);
    self.panLine.alpha = 0.8;
    GraphPointView *visiblePoint = [self getVisiblePointView];
    visiblePoint.alpha = 1;
    
    
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        self.panLine.alpha = 0;
        [self hidePointViews];
    }
}

///根据panLine计算哪个点该显示
- (GraphPointView *)getVisiblePointView
{
    CGFloat x = self.panLine.frame.origin.x;
    CGFloat graphMaxX = [[self.xAxisPointXArray valueForKeyPath:@"@max.floatValue"] floatValue];
    CGFloat graphMinX = [[self.xAxisPointXArray valueForKeyPath:@"@min.floatValue"] floatValue];
    CGFloat gap = (graphMaxX - graphMinX)/10;
    NSInteger gapIndex = x/gap + 1;
    NSInteger pointIndex = gapIndex/2;
    return self.pointViewArray[pointIndex];
}

///隐藏所有pointView
- (void)hidePointViews
{
    for (int i = 0; i < self.pointViewArray.count; i ++) {
        GraphPointView *pointView = self.pointViewArray[i];
        pointView.alpha = 0;
    }
}

#pragma mark Get
- (UIImageView *)bgImageView
{
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        UIEdgeInsets insets = UIEdgeInsetsMake(25, 0, 25, 0);
        _bgImageView.image = [[UIImage imageNamed:@"sixmonthbg"] resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    }
    return _bgImageView;
}

- (UIView *)panLine
{
    if (!_panLine) {
        _panLine = [[UIView alloc]initWithFrame:CGRectMake(65, 22, 1, 182)];
        _panLine.backgroundColor = [UIColor whiteColor];
        _panLine.alpha = 0;
    }
    return _panLine;
}

- (UIPanGestureRecognizer *)panGesture
{
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handleGestureAction:)];
        [_panGesture setMaximumNumberOfTouches:1];
        _panGesture.delegate = self;
    }
    return _panGesture;
}

- (UILongPressGestureRecognizer *)longPressGesture
{
    if (!_longPressGesture) {
        _longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleGestureAction:)];
        _longPressGesture.minimumPressDuration = 0.1f;
    }
    return _longPressGesture;
}

@end



@interface GraphPointView ()

@property (nonatomic, strong) UIView *dotView;
@property (nonatomic, strong) UILabel *contentLabel;

@end

@implementation GraphPointView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.dotView];
        [self addSubview:self.contentLabel];
    }
    return self;
}

#pragma mark Set
- (void)setContent:(NSString *)content
{
    self.contentLabel.text = content;
}

#pragma mark Get
- (UIView *)dotView
{
    if (!_dotView) {
        _dotView = [[UIView alloc]initWithFrame:CGRectMake(0,0, 10, 10)];
        _dotView.center = self.center;
        _dotView.backgroundColor = [UIColor whiteColor];
        _dotView.layer.cornerRadius = 5.f;
    }
    return _dotView;
}

- (UILabel *)contentLabel
{
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 37, 16)];
        _contentLabel.backgroundColor = [UIColor whiteColor];
        _contentLabel.font = [UIFont systemFontOfSize:12];
        _contentLabel.textAlignment = NSTextAlignmentCenter;
        _contentLabel.layer.cornerRadius = 3.f;
        _contentLabel.layer.masksToBounds = YES;
        _contentLabel.textColor = rgb(255, 158, 61);
    }
    return _contentLabel;
}

@end
