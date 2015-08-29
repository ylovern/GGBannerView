//
//  GGBannerView.m
//  GGBannerViewDemo
//
//  Created by GuinsooMBP on 15/8/29.
//  Copyright (c) 2015年 gaonan. All rights reserved.
//

#import "GGBannerView.h"
#import "UIImageView+WebCache.h"
@interface GGBannerView ()<UIScrollViewDelegate>
@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic, strong) UIScrollView *bannerScrollView;
@property (nonatomic, strong) UIPageControl *pageController;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger currentPage;

@end
@implementation GGBannerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubviews];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder: aDecoder];
    if (self) {
        [self initSubviews];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    for (UIView *view in self.bannerScrollView.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            UIImageView *imageView = (UIImageView *)view;
            imageView.frame = CGRectMake(imageView.tag*width, 0, width, height);
        }
    }
    self.bannerScrollView.contentSize = CGSizeMake(width*3, height);
    self.bannerScrollView.contentOffset = CGPointMake(width, 0);
    
    
}
#pragma mark - public method
-(void)configBanner:(NSArray *)imageArray{
    self.imageArray = imageArray;
    self.pageController.numberOfPages = imageArray.count;
    [self showCurrentImages];
}
#pragma mark - private method
- (void)initSubviews{
    self.currentPage = 0;
    [self addSubview:self.bannerScrollView];
    [self addSubview:self.pageController];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_bannerScrollView]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_bannerScrollView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_bannerScrollView]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_bannerScrollView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_pageController]-10-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_pageController)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_pageController]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_pageController)]];
    [self addTimer];

    
}
- (void)bannerClick:(UIGestureRecognizer *)gesture{
    if ([self.delegate respondsToSelector:@selector(bannerView:didSelectAtIndex:)]) {
        [self.delegate bannerView:self didSelectAtIndex:self.currentPage];
    }
}
- (void)addTimer{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(changePage) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}


- (void)removeTimer{
    [self.timer invalidate];
    self.timer = nil;
}
- (void)changePage{
    CGPoint offSet = CGPointMake(self.bannerScrollView.contentOffset.x+CGRectGetWidth(self.bannerScrollView.frame), 0);
    [self.bannerScrollView setContentOffset:offSet  animated:YES];
    
}
-(NSInteger)getNextPageIndexWithPageIndex:(NSInteger)currentIndex
{
    NSInteger index;
    if (currentIndex==-1) {
        index = self.imageArray.count-1;
    }else if (currentIndex==self.imageArray.count){
        index = 0;
    }else{
        index = currentIndex;
    }
    return index;
}
-(void)showCurrentImages
{
    if (!self.imageArray.count>0) {
        return;
    }
    for (UIView *view in self.bannerScrollView.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            UIImageView *imageView = (UIImageView *)view;
            NSString *imagePath = [self getImageUrlForView:imageView.tag];
            [imageView sd_setImageWithURL:[NSURL URLWithString:imagePath] placeholderImage:nil];
            
        }
    }
    
    [self.bannerScrollView setContentOffset:CGPointMake(self.bannerScrollView.frame.size.width, 0)];
}
- (NSString *)getImageUrlForView:(NSInteger)tag{
    NSInteger index = [self getNextPageIndexWithPageIndex:self.currentPage + (tag - 1)];
    return self.imageArray[index];
}
#pragma mark - scrollView delegate

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_timer invalidate];
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self addTimer];
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.pageController.currentPage = [self getNextPageIndexWithPageIndex:self.currentPage];
    
    if (scrollView.contentOffset.x>=2*CGRectGetWidth(scrollView.frame)) {
        self.currentPage = [self getNextPageIndexWithPageIndex:self.currentPage+1];
        [self showCurrentImages];
        
    }
    if (scrollView.contentOffset.x<=0)
    {
        self.currentPage = [self getNextPageIndexWithPageIndex:self.currentPage-1];
        [self showCurrentImages];
    }
    
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [scrollView setContentOffset:CGPointMake(CGRectGetWidth(self.bannerScrollView.frame), 0)];
}
#pragma mark - setter && getter
- (UIScrollView *)bannerScrollView{
    if (!_bannerScrollView) {
        _bannerScrollView = [[UIScrollView alloc] init];
        _bannerScrollView.showsHorizontalScrollIndicator = NO;
        _bannerScrollView.showsVerticalScrollIndicator = NO;
        _bannerScrollView.directionalLockEnabled = YES;
        _bannerScrollView.pagingEnabled = YES;
        _bannerScrollView.delegate = self;
        _bannerScrollView.backgroundColor = [UIColor clearColor];
        _bannerScrollView.contentOffset  = CGPointMake(0, 0);
        _bannerScrollView.translatesAutoresizingMaskIntoConstraints = NO;
        for (int i = 0; i<3; i++) {
            UIImageView *imageView = [[UIImageView alloc]init];
//            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.tag = i;
            imageView.userInteractionEnabled = YES;
            UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bannerClick:)];
            [imageView addGestureRecognizer:gesture];
            [_bannerScrollView addSubview:imageView];
        }
    }
    return _bannerScrollView;
}
- (UIPageControl *)pageController{
    if (!_pageController) {
        _pageController = [[UIPageControl alloc] init];
        _pageController.currentPage = 0;
        _pageController.numberOfPages = self.imageArray.count;
        _pageController.backgroundColor = [UIColor clearColor];
        _pageController.currentPageIndicatorTintColor = [UIColor whiteColor];
        _pageController.pageIndicatorTintColor = [UIColor lightGrayColor];
        _pageController.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return  _pageController;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
