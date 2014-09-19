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

@interface TagDetailViewController : UIViewController <MKMapViewDelegate, MFMessageComposeViewControllerDelegate, CLLocationManagerDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *walkTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *onlineLabel;
- (IBAction)smsButton:(UIButton *)sender;

@property (strong, nonatomic) NSDate *tagDate;
@property (nonatomic) CLLocationCoordinate2D tagCoordinate;
//@property (nonatomic) BOOL isCalibrated;

@end