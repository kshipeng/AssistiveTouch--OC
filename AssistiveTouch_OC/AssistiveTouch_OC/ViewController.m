//
//  ViewController.m
//  AssistiveTouch_OC
//
//  Created by 康世朋 on 2018/4/27.
//  Copyright © 2018年 康世朋. All rights reserved.
//

#import "ViewController.h"
#import "SPAssistiveTouch/SPAssistiveTouch.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    SPAssistiveTouch *touch = [SPAssistiveTouch showOnView:self.view x:3 y:100 width:60 click:^(SPAssistiveTouch *assistive) {
        NSLog(@"点击了小圆点😁");
    }];
    touch.alphaForStop = 0.6;
    //还有其他一些设置，请移步.h文件查看
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
