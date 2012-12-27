//
//  ICDemoViewController.m
//  ICProgressPanel
//
//  Created by Edward Chiang on 12/12/19.
//  Copyright (c) 2012年 Polydice Inc. All rights reserved.
//

#import "ICDemoViewController.h"
#import "ICProgressPanel.h"

@interface ICDemoViewController ()

#define kNOTIFICATION_UPLOADMANAGER_DID_START_LOADING @"kNOTIFICATION_UPLOADMANAGER_DID_START_LOADING"
#define kNOTIFICATION_UPLOADMANAGER_LOADING @"kNOTIFICATION_UPLOADMANAGER_LOADING"
#define kNOTIFICATION_UPLOADMANAGER_DID_FINISH_LOADING @"kNOTIFICATION_UPLOADMANAGER_DID_FINISH_LOADING"
#define kNOTIFICATION_UPLOADMANAGER_LOAD_WITH_ERROR @"kNOTIFICATION_UPLOADMANAGER_LOAD_WITH_ERROR"
#define kNOTIFICATION_PHOTOS_UPLOAD_DONE @"kNOTIFICATION_PHOTOS_UPLOAD_DONE"

@end

@implementation ICDemoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view
  
  __block ICProgressPanel *tempProgressPanel = [ICProgressPanel sharedInstance];
  
  // Add notification Setting
  [[NSNotificationCenter defaultCenter] addObserverForName:kNOTIFICATION_UPLOADMANAGER_DID_START_LOADING object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
    
    if ([note.object isKindOfClass:[UIImage class]]) {
      UIImage *uploadImage = (UIImage *)note.object;
      tempProgressPanel.thumbImageView.image = uploadImage;
      [tempProgressPanel.thumbImageView setNeedsLayout];
    }
  }];
  
  [[NSNotificationCenter defaultCenter] addObserverForName:kNOTIFICATION_UPLOADMANAGER_LOADING object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
    if ([note.object isKindOfClass:[NSNumber class]]) {
      NSNumber *progress = (NSNumber *)note.object;
      tempProgressPanel.percentage = progress.floatValue;
    }
  }];
  
  [[NSNotificationCenter defaultCenter] addObserverForName:kNOTIFICATION_UPLOADMANAGER_LOAD_WITH_ERROR object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
    [tempProgressPanel hide];
  }];
  
  [[NSNotificationCenter defaultCenter] addObserverForName:kNOTIFICATION_PHOTOS_UPLOAD_DONE object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
    [tempProgressPanel done];
  }];

  // Add panel in view
  [[ICProgressPanel sharedInstance] showPanelInView:self.view];
  [ICProgressPanel sharedInstance].delegate = self;
  // Hide for DEMO
  [[ICProgressPanel sharedInstance] hide];

  // Add event handler
  [self.showButton addTarget:self action:@selector(show:) forControlEvents:UIControlEventTouchUpInside];
  
  [self.progressSlider addTarget:self action:@selector(progressSlide:) forControlEvents:UIControlEventValueChanged];
  
  [self.hideButton addTarget:self action:@selector(hide:) forControlEvents:UIControlEventTouchUpInside];
  
  [self.finishButton addTarget:self action:@selector(finish:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - private

- (void)show:(id)sender {
  [ICProgressPanel sharedInstance].percentage = 0.00;
  [[ICProgressPanel sharedInstance] show];
  [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_UPLOADMANAGER_DID_START_LOADING object:[UIImage imageNamed:@"IMG_6682"]];
}

- (void)progressSlide:(id)sender {
  UISlider *slider = (UISlider *)sender;
  [ICProgressPanel sharedInstance].percentage = slider.value;
}

- (void)hide:(id)sender {
  [[ICProgressPanel sharedInstance] hide];
}

- (void)finish:(id)sender {
  [ICProgressPanel sharedInstance].percentage = 1;
  [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_PHOTOS_UPLOAD_DONE object:nil];
}

#pragma mark - ICProgressPanelDelegate

- (void)progressPanelDidCancelLoad:(ICProgressPanel *)panel {
  [panel hide];
}

@end
