//
//  ICProgressPanel.m
//  iCook
//
//  Created by Edward Chiang on 12/12/17.
//  Copyright (c) 2012年 Polydice, Inc. All rights reserved.
//

#import "ICProgressPanel.h"

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
    self.doneButton.hidden = YES;
  }
  
  if (self.isLoading && self.frame.origin.y < 0) {
    [self show];
  }
}

- (void)cancelUpload:(id)sender {
  if (_delegate && [_delegate respondsToSelector:@selector(progressPanelDidCancelLoad:)]) {
    [_delegate progressPanelDidCancelLoad:self];
  }
}

- (void)finishUpload:(id)sender {
  if (_delegate && [_delegate respondsToSelector:@selector(progressPanelDidFinishLoad:)]) {
    [_delegate progressPanelDidFinishLoad:self];
  }
}

- (void)showPanelInView:(UIView *)view {

  [self.cancelButton addTarget:self action:@selector(cancelUpload:) forControlEvents:UIControlEventTouchUpInside];
  self.cancelButton.hidden = NO;
  
  [self.cancelButton setImage:[UIImage imageNamed:@"upload-delete"] forState:UIControlStateNormal];
  [self.cancelButton sizeToFit];
  self.cancelButton.center = CGPointMake(panelWidth - 18, panelHeight / 2);
  [self addSubview:self.cancelButton];
  
  [self.doneButton setImage:[UIImage imageNamed:@"upload-finished"] forState:UIControlStateNormal];
  [self.doneButton addTarget:self action:@selector(finishUpload:) forControlEvents:UIControlEventTouchUpInside];
  self.doneButton.hidden = YES;
  [self.doneButton sizeToFit];
  self.doneButton.center = CGPointMake(panelWidth - 18, panelHeight / 2);
  [self addSubview:self.doneButton];
  
  UIEdgeInsets recipeBackgroundImageViewInsets = UIEdgeInsetsMake(8, 8, 8, 8);
  UIImageView *iconShadowView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"upload-photoBg"] resizableImageWithCapInsets:recipeBackgroundImageViewInsets]];
  [iconShadowView sizeToFit];
  iconShadowView.center = CGPointMake(24, panelHeight / 2);
  
  
  self.thumbImageView.frame = CGRectMake((iconShadowView.frame.size.width - 24) / 2, (iconShadowView.frame.size.width - 24) / 2, 24, 24);
  
  [iconShadowView addSubview:self.thumbImageView];
  [self addSubview:iconShadowView];

  [view addSubview:self];
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
