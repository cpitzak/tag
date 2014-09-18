//
//  CameraViewController.h
//  Tag
//
//  Created by Pitzak, Clint J on 9/17/14.
//  Copyright (c) 2014 Pitzak, Clint J. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface CameraViewController : UIViewController<UIImagePickerControllerDelegate,
UINavigationControllerDelegate>

@property (nonatomic) BOOL newMedia;
@property (strong, nonatomic) IBOutlet UIImageView *cameraImageView;
- (IBAction)cameraButton:(UIButton *)sender;
- (IBAction)cameraRollButton:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;

@end
