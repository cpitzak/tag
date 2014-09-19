//
//  CameraViewController.h
//  Tag
//
//  Created by Pitzak, Clint J on 9/17/14.
//  Copyright (c) 2014 Pitzak, Clint J. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface CameraViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIImageView *cameraImageView;
- (IBAction)dontUseButton:(UIButton *)sender;

@end
