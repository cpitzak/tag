//
//  TagDetailViewController.h
//  Tag
//
//  Created by Pitzak, Clint J on 9/16/14.
//  Copyright (c) 2014 Pitzak, Clint J. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MessageUI/MessageUI.h>
#import <math.h>
#import <CoreMotion/CoreMotion.h> // For the gyroscope
#import <CoreLocation/CoreLocation.h> // For the compass
#import <MobileCoreServices/MobileCoreServices.h>
#import <QuartzCore/QuartzCore.h>

@interface TagDetailViewController : UIViewController <MKMapViewDelegate, MFMessageComposeViewControllerDelegate,
CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *walkTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *onlineLabel;
@property (weak, nonatomic) IBOutlet UIButton *mapTypeButton;
- (IBAction)smsButton:(UIButton *)sender;
- (IBAction)tagButton:(UIButton *)sender;
- (IBAction)cameraButton:(UIButton *)sender;
- (IBAction)resetButton:(UIButton *)sender;
- (IBAction)mapTypeButton:(UIButton *)sender;

@property (strong, nonatomic) NSDate *tagDate;
@property (nonatomic) CLLocationCoordinate2D tagCoordinate;
//@property (nonatomic) BOOL isCalibrated;

@end