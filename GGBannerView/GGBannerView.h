//
//  GGBannerView.h
//  GGBannerViewDemo
//
//  Created by GuinsooMBP on 15/8/29.
//  Copyright (c) 2015年 gaonan. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GGBannerView;
@protocol GGBannerViewDelegate <NSObject>
- (void)bannerView:(GGBannerView *)bannerView didSelectAtIndex:(NSUInteger)index;
@end
@interface GGBannerView : UIView
@property (nonatomic, weak) id<GGBannerViewDelegate> delegate;
- (void)configBanner:(NSArray *)imageArray;
@end
