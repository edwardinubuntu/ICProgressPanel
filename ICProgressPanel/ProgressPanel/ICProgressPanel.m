//
//  ICProgressPanel.m
//  iCook
//
//  Created by Edward Chiang on 12/12/17.
//  Copyright (c) 2012年 Polydice, Inc. All rights reserved.
//

#import "ICProgressPanel.h"
#import <QuartzCore/QuartzCore.h>
#import "UIControl+BlocksKit.h"

@implementation ICProgressPanel

CGFloat panelHeight = 50;
CGFloat panelWidth = 320;

- (id)init {
  if (self = [super init]) {
    _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    _thumbImageView = [[UIImageView alloc] init];
    self.thumbImageView.backgroundColor = [UIColor grayColor];
    
    _progressImageViews = [[NSMutableArray alloc] initWithCapacity:10];
    for (int i = 0; i< 10; i++) {
      UIImageView *progressView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"upload-progressbar"] highlightedImage:[UIImage imageNamed:@"upload-progressbarGlow"]];
      [progressView sizeToFit];
      [self.progressImageViews addObject:progressView];
    }
    
    self.backgroundColor = [UIColor clearColor];    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"upload-progressbarBg"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)] ];
    backgroundImageView.frame = CGRectMake(0, 0, panelWidth, panelHeight);
    [self addSubview:backgroundImageView];
    
    CGFloat left = 57;
    NSInteger count = 0;
    for (UIImageView *progressView in self.progressImageViews) {
      progressView.center = CGPointMake(left + 24 * count, panelHeight / 2);
      [self addSubview:progressView];
      count++;
    }
    
    _waitingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.waitingView sizeToFit];
    [self addSubview: self.waitingView];
    
    [self show];
  }
  return self;
}

#pragma mark - public

- (BOOL)isLoading {
  return self.percentage > 0 && self.percentage < 1;
}

- (void)show {
  self.frame = CGRectMake(0, 0, panelWidth, panelHeight);
  CATransition *transition = [CATransition animation];
  transition.duration = 0.25;
  transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  transition.type = kCATransitionPush;
  transition.subtype = kCATransitionFromBottom;
  [self.layer addAnimation:transition forKey:nil];
}

- (void)done {

  self.cancelButton.hidden = YES;
  self.doneButton.hidden = NO;
  [self.waitingView stopAnimating];

  [self performSelector:@selector(hide) withObject:nil afterDelay:1];
}

+ (ICProgressPanel *)sharedInstance {
  static dispatch_once_t pred;
  __strong static ICProgressPanel *sharedOverlay = nil;
  
  dispatch_once(&pred, ^{
    sharedOverlay = [[ICProgressPanel alloc] init];
  });
  
  return sharedOverlay;
}

- (void)setPercentage:(CGFloat)percentage {
  _percentage = percentage;

  // The first one will start with 10.
  NSInteger currentNumber = 10;
  for (UIImageView *progressView in self.progressImageViews) {
    
    if (percentage * 100 >= currentNumber) {
      [progressView setHighlighted:YES];
    } else {
      [progressView setHighlighted:NO];
    }
    currentNumber += 10;
  }
  
  if (percentage * 100 >= 100) {
    self.waitingView.center = self.cancelButton.center;
    [self.waitingView startAnimating];
    self.cancelButton.hidden = YES;
    self.doneButton.hidden = YES;
  } else {
    [self.waitingView stopAnimating];
    self.cancelButton.hidden = NO;
  }
  
  if (self.isLoading && self.frame.origin.y < 0) {
    [self show];
  }
}

+ (ICProgressPanel *)showPanelInView:(UIView *)view didFinishLoad:(progressDidFinishLoadBlock)finishBlock cancel:(progressDidFinishLoadBlock)cancelBlock {
  
  ICProgressPanel *panel = [ICProgressPanel sharedInstance];

  [panel.cancelButton addEventHandler:^(id sender) {
    cancelBlock();
  } forControlEvents:UIControlEventTouchUpInside];
  panel.cancelButton.hidden = NO;
  
  [panel.cancelButton setImage:[UIImage imageNamed:@"upload-delete"] forState:UIControlStateNormal];
  [panel.cancelButton sizeToFit];
  panel.cancelButton.center = CGPointMake(panelWidth - 18, panelHeight / 2);
  [panel addSubview:panel.cancelButton];
  
  [panel.doneButton setImage:[UIImage imageNamed:@"upload-finished"] forState:UIControlStateNormal];
  [panel.doneButton addEventHandler:^(id sender) {
    finishBlock();
  } forControlEvents:UIControlEventTouchUpInside];
  panel.doneButton.hidden = YES;
  [panel.doneButton sizeToFit];
  panel.doneButton.center = CGPointMake(panelWidth - 18, panelHeight / 2);
  [panel addSubview:panel.doneButton];
  
  UIEdgeInsets recipeBackgroundImageViewInsets = UIEdgeInsetsMake(8, 8, 8, 8);
  UIImageView *iconShadowView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"upload-photoBg"] resizableImageWithCapInsets:recipeBackgroundImageViewInsets]];
  [iconShadowView sizeToFit];
  iconShadowView.center = CGPointMake(24, panelHeight / 2);
  
  
  panel.thumbImageView.frame = CGRectMake((iconShadowView.frame.size.width - 24) / 2, (iconShadowView.frame.size.width - 24) / 2, 24, 24);
  
  [iconShadowView addSubview:panel.thumbImageView];
  [panel addSubview:iconShadowView];

  [view addSubview:panel];
  
  return panel;
}

- (void)hide {
  [NSObject cancelPreviousPerformRequestsWithTarget:self];
  CATransition *transition = [CATransition animation];
  transition.duration = 0.25;
  transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  transition.type = kCATransitionPush;
  transition.subtype = kCATransitionFromTop;
  [self.layer addAnimation:transition forKey:nil];
  self.frame = CGRectMake(0, -panelHeight * 2, panelWidth, panelHeight);
}

@end
