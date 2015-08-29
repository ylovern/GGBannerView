//
//  ViewController.m
//  GGBannerViewDemo
//
//  Created by GuinsooMBP on 15/8/29.
//  Copyright (c) 2015年 gaonan. All rights reserved.
//

#import "ViewController.h"
#import "GGBannerView.h"
@interface ViewController ()<GGBannerViewDelegate>
@property (weak, nonatomic) IBOutlet GGBannerView *bannerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.bannerView.delegate = self;
    NSArray *imageArray = @[@"http://7xk68o.com1.z0.glb.clouddn.com/1.jpg",
                            @"http://7xk68o.com1.z0.glb.clouddn.com/2.jpg",
                            @"http://7xk68o.com1.z0.glb.clouddn.com/3.jpg",
                            @"http://7xk68o.com1.z0.glb.clouddn.com/4.jpg",
                            @"http://7xk68o.com1.z0.glb.clouddn.com/5.jpg",
                            ];
    [self.bannerView configBanner:imageArray];
    
    
    
    GGBannerView *bannerView2 = [[GGBannerView alloc]initWithFrame:CGRectMake(20, 400, 300, 100)];
    [self.view addSubview:bannerView2];
    bannerView2.delegate = self;
    [bannerView2 configBanner:imageArray];
    
    // Do any additional setup after loading the view, typically from a nib.
}
-(void)bannerView:(GGBannerView *)bannerView didSelectAtIndex:(NSUInteger)index{
    if (bannerView == self.bannerView) {
        NSLog(@"选中-- bannerView1 - %@",@(index));
    }else{
        NSLog(@"选中-- bannerView2 - %@",@(index));
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
