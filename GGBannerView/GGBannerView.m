//
//  GGBannerView.m
//  GGBannerViewDemo
//
//  Created by GuinsooMBP on 15/8/29.
//  Copyright (c) 2015年 gaonan. All rights reserved.
//

#import "GGBannerView.h"
#import "GGBannerCollectionViewCell.h"
@interface GGBannerView ()<UIScrollViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic, strong) UICollectionView *bannerCollectionView;
@property (nonatomic, strong) UIPageControl *pageController;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, assign) CGFloat unitLength;
@property (nonatomic, assign) CGFloat offsetLength;
@property (nonatomic, assign) CGFloat contentLength;
@property (nonatomic, assign) CGFloat oldOffsetLength;

@end
@implementation GGBannerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubviews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder: aDecoder];
    if (self) {
        [self initSubviews];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.flowLayout.itemSize = self.frame.size;
}

#pragma mark - public method
- (void)configBanner:(NSArray *)imageArray {
    self.imageArray = imageArray;
    self.pageController.numberOfPages = imageArray.count;
    [self.bannerCollectionView reloadData];
}

#pragma mark - private method
- (void)initSubviews {
    [self addSubview:self.bannerCollectionView];
    [self addSubview:self.pageController];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_bannerCollectionView]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_bannerCollectionView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_bannerCollectionView]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_bannerCollectionView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_pageController]-10-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_pageController)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_pageController]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_pageController)]];
    self.scrollEnabled = YES;
    self.interval = 0.0;
    self.scrollDirection = GGBannerViewScrollDirectionHorizontal;
}

- (void)addTimer {
    if (self.interval == 0) {
        return;
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.interval target:self selector:@selector(changePage) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)removeTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)changePage {
    
    CGFloat newOffSetLength = self.offsetLength + self.unitLength;
    //在换页到最后一个的时候多加一点距离，触发回到第一个图片的事件
    if (newOffSetLength == self.contentLength - self.unitLength) {
        newOffSetLength += 1;
    }
    CGPoint offSet;
    if (self.scrollDirection == GGBannerViewScrollDirectionHorizontal) {
       offSet = CGPointMake(newOffSetLength, 0);
    }else{
        offSet = CGPointMake(0,newOffSetLength);
    }
    [self.bannerCollectionView setContentOffset:offSet  animated:YES];
    //修复在滚动动画进行中切换tabbar或push一个新的controller时导致图片显示错位问题。
    //原因：系统会在view not-on-screen时移除所有coreAnimation动画，导致动画无法完成，轮播图停留在切换中间的状态。
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //动画完成后的实际offset和应该到达的offset不一致，重置offset。
        if (self.offsetLength!=newOffSetLength && self.offsetLength!=0) {
            self.bannerCollectionView.contentOffset = offSet;
        }
    });
    
}

- (NSString *)getImageUrlForIndexPath:(NSIndexPath *)indexPath {
    if (!(self.imageArray.count > 0)) {
        return nil;
    }
    if (indexPath.row == self.imageArray.count){
        return self.imageArray.firstObject;
    } else {
        return self.imageArray[indexPath.row];
    }
}

#pragma mark - collectionView delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if(self.imageArray.count == 1) {
        return 1;
    }
    return self.imageArray.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GGBannerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"banner" forIndexPath:indexPath];
    NSString *url = [self getImageUrlForIndexPath:indexPath];
    if ([self.delegate respondsToSelector:@selector(imageView:loadImageForUrl:)]) {
        [self.delegate imageView:cell.imageView loadImageForUrl:url];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(bannerView:didSelectAtIndex:)]) {
        [self.delegate bannerView:self didSelectAtIndex:self.pageController.currentPage];
    }
}

#pragma mark - scrollView delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_timer invalidate];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    self.pageController.currentPage = self.offsetLength / self.unitLength;
    [self addTimer];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    UICollectionView *collectionView = (UICollectionView *)scrollView;
    if (self.oldOffsetLength > self.offsetLength) {
        if (self.offsetLength < 0)
        {
            [collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.imageArray.count inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        }
    }else{
        if (self.offsetLength > self.contentLength - self.unitLength) {
            [collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        }
    }
    self.pageController.currentPage = self.offsetLength / self.unitLength;
    self.oldOffsetLength = self.offsetLength;
}

#pragma mark - setter && getter
- (UICollectionView *)bannerCollectionView {
    if (!_bannerCollectionView) {
        _bannerCollectionView = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:self.flowLayout];
        _bannerCollectionView.dataSource = self;
        _bannerCollectionView.delegate = self;
        _bannerCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
        [_bannerCollectionView registerClass:[GGBannerCollectionViewCell class] forCellWithReuseIdentifier:@"banner"];
        _bannerCollectionView.pagingEnabled = YES;
        _bannerCollectionView.showsHorizontalScrollIndicator = NO;
        _bannerCollectionView.showsVerticalScrollIndicator = NO;
    }
    return _bannerCollectionView;
}

- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc]init];
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _flowLayout.minimumInteritemSpacing = 0;
        _flowLayout.minimumLineSpacing = 0;
    }
    return _flowLayout;
}

- (UIPageControl *)pageController {
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

- (void)setScrollDirection:(GGBannerViewScrollDirection)scrollDirection {
    if (_scrollDirection != scrollDirection) {
        _scrollDirection = scrollDirection;
        if (scrollDirection == GGBannerViewScrollDirectionVertical) {
            self.flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        }else{
           self.flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        }
        [self.bannerCollectionView reloadData];
    }
}

- (void)setScrollEnabled:(BOOL)scrollEnabled {
    _scrollEnabled = scrollEnabled;
    self.bannerCollectionView.scrollEnabled = _scrollEnabled;
}

- (CGFloat)unitLength {
    return self.scrollDirection == GGBannerViewScrollDirectionHorizontal ? CGRectGetWidth(self.frame) : CGRectGetHeight(self.frame);
}

- (CGFloat)offsetLength {
    return self.scrollDirection == GGBannerViewScrollDirectionHorizontal ? self.bannerCollectionView.contentOffset.x : self.bannerCollectionView.contentOffset.y;
}

- (CGFloat)contentLength {
    return self.scrollDirection == GGBannerViewScrollDirectionHorizontal ? self.bannerCollectionView.contentSize.width : self.bannerCollectionView.contentSize.height;
}
- (void)setInterval:(NSTimeInterval)interval {
    _interval = interval;
    [self removeTimer];
    if (interval != 0) {
        [self addTimer];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
