//
//  TagViewController.m
//  Tag
//
//  Created by Pitzak, Clint J on 9/15/14.
//  Copyright (c) 2014 Pitzak, Clint J. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "TagViewController.h"
#import "TagDetailViewController.h"

@interface TagViewController () {
    NSDate *tagDate;
    CLLocationCoordinate2D tagCoordinate;
}

@end

@implementation TagViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)tagButton:(UIButton *)sender {
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    [locationManager startUpdatingLocation];
    
    if([CLLocationManager locationServicesEnabled] &&
       [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
        // current lat, lon
        tagCoordinate = locationManager.location.coordinate;
        // current time
        tagDate = [[NSDate alloc]init];
        [self performSegueWithIdentifier:@"tagDetailSegue" sender:sender];
    } else {
        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled"
                                                                        message:@"You currently have all location services for this device disabled.\
                                              If you proceed, you will be asked to confirm whether location services should be reenabled."
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
        [servicesDisabledAlert show];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"tagDetailSegue"]){
        TagDetailViewController *tagDetailViewController = (TagDetailViewController *)segue.destinationViewController;
        tagDetailViewController.tagCoordinate = tagCoordinate;
        tagDetailViewController.tagDate = tagDate;
    }
}

@end
