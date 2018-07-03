//
//  SPAssistiveTouch.m
//  alert
//
//  Created by 康世朋 on 2017/9/18.
//  Copyright © 2017年 康世朋. All rights reserved.
//

#import "SPAssistiveTouch.h"

@interface SPAssistiveTouch ()

@property (nonatomic, strong) UIView *parentView;
@property (nonatomic, assign) CGRect initialFrame;
@property (nonatomic, strong) UIButton *assistivaButton;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) CGFloat transX;
@property (nonatomic, assign) CGFloat transY;

@property (nonatomic, copy) void(^clickBlock)(SPAssistiveTouch *touch);

@end

@implementation SPAssistiveTouch

+ (instancetype)showOnView:(UIView *)view x:(CGFloat)x y:(CGFloat)y width:(CGFloat)width {
    SPAssistiveTouch *ass = [[SPAssistiveTouch alloc]init];
    [ass setupUIWithView:view x:x y:y width:width];
    return ass;
}

+ (instancetype)showOnView:(UIView *)view x:(CGFloat)x y:(CGFloat)y width:(CGFloat)width click:(void (^)(SPAssistiveTouch *))block {
    SPAssistiveTouch *ass = [[SPAssistiveTouch alloc]init];
    ass.clickBlock = block;
    [ass setupUIWithView:view x:x y:y width:width];
    return ass;
}

- (void)setupUIWithView:(UIView *)view x:(CGFloat)x y:(CGFloat)y width:(CGFloat)width {
    
    self.frame = CGRectMake(x, y, width, width);
    _parentView = view;
    _initialFrame = self.frame;
    _stopScreenEdge = YES;
    _hasNavigationBar = YES;
    _hasTabBar = YES;
    _alphaForStop = 0.4;
    _autoChangeAlpha = YES;
    self.layer.cornerRadius = width/2;
    _assistivaButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _assistivaButton.frame = CGRectMake(0, 0, width, width);
    _assistivaButton.layer.cornerRadius = width/2;
    _assistivaButton.layer.masksToBounds = YES;
    _assistivaButton.backgroundColor = [UIColor blackColor];
    self.alpha = _alphaForStop;
    _assistivaButton.alpha = _alphaForStop;
    [_assistivaButton addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_assistivaButton];
    [view addSubview:self];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:panGesture];
}

- (void)pan:(UIPanGestureRecognizer *)panGesture {
    [_timer invalidate];
    self.alpha = 1;
    _assistivaButton.alpha = 1;
    _transX = [panGesture translationInView:self].x;
    _transY = [panGesture translationInView:self].y;
    panGesture.view.center = CGPointMake(panGesture.view.center.x + _transX, panGesture.view.center.y + _transY);
    [panGesture setTranslation:CGPointZero inView:self];
    
    if (panGesture.state == UIGestureRecognizerStateEnded) {
        if (_autoChangeAlpha) {
           [self addTimer];
        }else {
            [_timer invalidate];
            _timer = nil;
        }
        CGFloat self_x = self.frame.origin.x;
        CGFloat self_y = self.frame.origin.y;
        CGFloat self_w = self.frame.size.width;
        CGFloat self_H = self.frame.size.height;
        //修正坐标
        [self resetFrameX:self_x y:self_y w:self_w h:self_H];
    
        //停留在边缘
        if (_stopScreenEdge) {
            if (self_y < minY(self) + 3) {
                [self resetFrameX:self_x y:minY(self) w:self_w h:self_H];
            }else {
                if (self_x < _parentView.frame.size.width/2.0) {
                    [self resetFrameX:minX() y:self_y w:self_w h:self_H];
                }else {
                    [self resetFrameX:maxX(self) y:self_y w:self_w h:self_H];
                }
            }
            if (self_y > maxY(self) - 3) {
                if (self_x < _parentView.frame.size.width/2.0) {
                    [self resetFrameX:self_x y:maxY(self) w:self_w h:self_H];
                }else {
                    [self resetFrameX:self_x y:maxY(self) w:self_w h:self_H];
                }
            }
        }
    }
}

- (void)click:(void (^)(SPAssistiveTouch *))clickBlock {
    _clickBlock = clickBlock;
}

- (void)setBackColor:(UIColor *)backColor {
    _backColor = backColor;
    self.backgroundColor = backColor;
    _assistivaButton.backgroundColor = backColor;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = cornerRadius;
    _assistivaButton.layer.cornerRadius = cornerRadius;
}

- (void)setNormalImage:(UIImage *)normalImage {
    _normalImage = normalImage;
    [_assistivaButton setBackgroundImage:normalImage forState:UIControlStateNormal];
}

- (void)setLightImage:(UIImage *)lightImage {
    _lightImage = lightImage;
    [_assistivaButton setBackgroundImage:lightImage forState:UIControlStateHighlighted];
}

- (void)setAlphaForStop:(CGFloat)alphaForStop {
    _alphaForStop = alphaForStop;
    self.alpha = alphaForStop;
    _assistivaButton.alpha = alphaForStop;
}

- (void)setAutoChangeAlpha:(BOOL)autoChangeAlpha {
    _autoChangeAlpha = autoChangeAlpha;
    if (_autoChangeAlpha) {
        [self addTimer];
    }else {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)resetFrameX:(CGFloat)x y:(CGFloat)y w:(CGFloat)width h:(CGFloat)height {
    if (x <= minX())     x = minX();
    if (x >= maxX(self)) x = maxX(self);
    
    if (y <= minY(self)) y = minY(self);
    if (y >= maxY(self)) y = maxY(self);
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(x, y, width, height);
    }];
}

- (void)addTimer {
    [_timer invalidate];
    _timer = nil;
    _timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(changeAlpha) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop]addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)buttonClick {
    if (_autoChangeAlpha) {
        [self addTimer];
    }else {
        [_timer invalidate];
        _timer = nil;
    }
    self.alpha = 1;
    _assistivaButton.alpha = 1;
    !_clickBlock? :_clickBlock(self);
}

- (void)changeAlpha {
    [UIView animateWithDuration:0.7 animations:^{
        self.alpha = self.alphaForStop;
        self.assistivaButton.alpha = self.alphaForStop;
    }];

}

CGFloat minY(SPAssistiveTouch* obj) {
    CGFloat top = 0.0;
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    if (obj.hasNavigationBar && screenH == 812.0) {
        top = 91.0;
    }
    if (obj.hasNavigationBar && screenH != 812.0) {
        top = 67.0;
    }
    if (!obj.hasNavigationBar) {
        top = 3.0;
    }
    return top;
}

CGFloat maxY(SPAssistiveTouch* obj) {
    CGFloat bottom = 0.0;
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    if (obj.hasTabBar && screenH == 812.0) {
        bottom = 86.0;
    }
    if (obj.hasTabBar && screenH != 812.0) {
        bottom = 52.0;
    }
    if (!obj.hasTabBar) {
        bottom = 3.0;
    }
    return (obj.parentView.bounds.size.height - obj.initialFrame.size.height - bottom);
}

CGFloat minX(void) {
    return 3.0;
}

CGFloat maxX(SPAssistiveTouch* obj) {
    return (obj.parentView.bounds.size.width - obj.initialFrame.size.width - minX());
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
