//
//  CBNavigationController.m
//  CBNavigationDemo
//
//  Created by z on 14-4-4.
//  Copyright (c) 2014年 z. All rights reserved.
//

#import "CBNavigationController.h"

#define BEHIND_ORIGIN_SCALE (0.9f)
#define BEHIND_SHADOW_ALPHA (0.6f)

@interface UIView (UIViewAdditions)

@property(nonatomic) CGFloat left;
@property(nonatomic) CGFloat right;
@property(nonatomic) CGFloat top;
@property(nonatomic) CGFloat bottom;
@property(nonatomic) CGFloat width;
@property(nonatomic) CGFloat height;

@end

@implementation UIView (UIViewAdditions)
- (CGFloat)left
{
    return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)right
{
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)right
{
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)top
{
    return self.frame.origin.y;
}

- (void)setTop:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)bottom
{
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)bottom
{
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)height
{
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

@end

@implementation UIImage (UIImageAdditions)

+(UIImage *)imageWithView:(UIView *)view
{
    CGSize size = view.bounds.size;
    
    if (UIGraphicsBeginImageContextWithOptions != NULL) {
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    } else {
        UIGraphicsBeginImageContext(size);
    }
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end

@interface CBNavigationController () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIView *behindView;
@property (nonatomic, strong) UIImageView *behindImageView;
@property (nonatomic, strong) NSMutableArray *behindImages;
@property (nonatomic, strong) UIView *shadowView;
@end

@implementation CBNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.behindImages = [NSMutableArray array];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    panGesture.delegate = self;
    [self.view addGestureRecognizer:panGesture];
    
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)resetBehind:(UIImage *)image
{
    if (self.view.superview == nil) {
        return;
    }
    
    if (self.behindView == nil) {
        self.behindView = [[UIView alloc] initWithFrame:self.view.bounds];
        [self.view.superview insertSubview:self.behindView belowSubview:self.view];
    }
    
    if (self.behindImageView == nil) {
        self.behindImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        self.shadowView = [[UIView alloc] initWithFrame:self.view.bounds];
        self.shadowView.backgroundColor = [UIColor blackColor];
        [self.behindView addSubview:self.behindImageView];
        [self.behindView addSubview:self.shadowView];
    }
    
    self.behindImageView.image = image;
    self.behindView.hidden = YES;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
//    NSLog(@"pushViewController");
    UIImage *image = [UIImage imageWithView:self.view];
    [self.behindImages addObject:image];
    [super pushViewController:viewController animated:animated];
    [self resetBehind:image];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
//    NSLog(@"popViewControllerAnimated");
    UIViewController *result = [super popViewControllerAnimated:animated];
    [self.behindImages removeLastObject];
    [self resetBehind:[self.behindImages lastObject]];
    return result;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
//    NSLog(@"popToRootViewControllerAnimated");
    [self.behindImages removeAllObjects];
    NSArray *result = [super popToRootViewControllerAnimated:animated];
    UIImage *image = [UIImage imageWithView:self.view];
    [self.behindImages addObject:image];
    [self resetBehind:[self.behindImages lastObject]];
    return result;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint translation = [gestureRecognizer translationInView:self.view];
    
    if (self.viewControllers.count > 1 && translation.x >= 0 && fabs(translation.x) / fabs(translation.y) >= 1) {
        return YES;
    }
    return NO;
}

- (void)pan:(UIPanGestureRecognizer *)pan
{
    UIGestureRecognizerState state = pan.state;
    UIView *view = self.topViewController.view;
    
    switch (state) {
        case UIGestureRecognizerStateBegan:
        {
            self.behindView.hidden = NO;
            self.behindImageView.transform = CGAffineTransformMakeScale(BEHIND_ORIGIN_SCALE, BEHIND_ORIGIN_SCALE);
            self.shadowView.alpha = BEHIND_SHADOW_ALPHA;
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            CGFloat originCenterX = self.view.width / 2;
            CGPoint pos = [pan translationInView:self.view];
            
            CGPoint center = self.view.center;
            center.x += pos.x;
            center.x = center.x > originCenterX ? center.x : originCenterX;
            self.view.center = center;
            [pan setTranslation:CGPointZero inView:self.view];
            
            CGFloat offset = self.view.left / self.view.width;
            CGFloat scaleOffset = offset * (1.f - BEHIND_ORIGIN_SCALE) + BEHIND_ORIGIN_SCALE;
            CGFloat alphaOffset = (1.f - offset) * BEHIND_SHADOW_ALPHA;
            
            self.behindImageView.transform = CGAffineTransformMakeScale(scaleOffset, scaleOffset);
            self.shadowView.alpha = alphaOffset;
            
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            CGPoint velocity = [pan velocityInView:self.view];
            BOOL toBack = velocity.x > 500.f;
            toBack = toBack || self.view.left > (self.view.width / 5 * 2);
            
            CGFloat scale = BEHIND_ORIGIN_SCALE;
            CGFloat alpha = BEHIND_SHADOW_ALPHA;
            CGFloat toX = 0.f;
            if (toBack) {
                scale = 1.f;
                alpha = 0.f;
                toX = view.width;
            }
            
            [UIView animateWithDuration:0.3 animations:^{
                self.behindImageView.transform = CGAffineTransformMakeScale(scale, scale);
                self.shadowView.alpha = alpha;
                self.view.left = toX;
            } completion:^(BOOL finished) {
                self.behindView.hidden = YES;
                self.view.left = 0.f;
                if (toBack) {
                    [self popViewControllerAnimated:NO];
                }
            }];
            break;
        }
        default:
            break;
    }
}

@end
