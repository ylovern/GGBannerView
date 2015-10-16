//
//  GGBannerView.h
//  GGBannerViewDemo
//
//  Created by GuinsooMBP on 15/8/29.
//  Copyright (c) 2015年 gaonan. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GGBannerView;
typedef NS_ENUM(NSInteger, GGBannerViewScrollDirection) {
    GGBannerViewScrollDirectionVertical,
    GGBannerViewScrollDirectionHorizontal
};

@protocol GGBannerViewDelegate <NSObject>
@required
/**
 *  加载图片的代理，由自己指定加载方式。便于统一网络图片管理
 *
 */
- (void)imageView:(UIImageView *)imageView loadImageForUrl:(NSString *)url;
/**
 *  banner的点击回调
 */
- (void)bannerView:(GGBannerView *)bannerView didSelectAtIndex:(NSUInteger)index;
@end

@interface GGBannerView : UIView
@property (nonatomic, weak) id<GGBannerViewDelegate> delegate;
/**
 *  自动换页时间间隔，0s 不滚动
 */
@property (nonatomic, assign) NSTimeInterval interval; // default is 0s
/**
 *  滚动方向
 */
@property (nonatomic, assign) GGBannerViewScrollDirection scrollDirection; // default is GGBannerViewScrollDirectionHorizontal

- (void)configBanner:(NSArray *)imageArray;
@end
