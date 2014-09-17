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

@interface TagDetailViewController : UIViewController <MKMapViewDelegate, MFMessageComposeViewControllerDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *tagLatLonButton;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *walkTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *youLatLonButton;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
- (IBAction)tagLatLonButton:(UIButton *)sender;
- (IBAction)youLatLonButton:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UILabel *onlineLabel;

@property (strong, nonatomic) NSDate *tagDate;
@property (nonatomic) CLLocationCoordinate2D tagCoordinate;

@end