//
//  TagDetailViewController.m
//  Tag
//
//  Created by Pitzak, Clint J on 9/16/14.
//  Copyright (c) 2014 Pitzak, Clint J. All rights reserved.
// http://www.techotopia.com/index.php/Using_MKDirections_to_get_iOS_7_Map_Directions_and_Routes
//

#import "TagDetailViewController.h"
#define CC_RADIANS_TO_DEGREES(__ANGLE__) ((__ANGLE__) / (float)M_PI * 180.0f)
#define radianConst M_PI/180.0

#define RadiansToDegrees(radians)(radians * 180.0/M_PI)
#define DegreesToRadians(degrees)(degrees * M_PI / 180.0)

@interface TagDetailViewController () {
    CLLocationManager *locationManager;
    BOOL firstMapUpdate;
    
    CMDeviceMotionHandler motionHandler;
    CMMotionManager     *motionManager;
    NSOperationQueue    *opQ;
    
    // Graphics
    UILabel             *compassDif;
    UILabel             *compassFault;
    
    NSTimer             *updateTimer;
    
    float               oldHeading;
    float               updatedHeading;
    float               newYaw;
    float               oldYaw;
    float               offsetG;
    float               updateCompass;
    float               newCompassTarget;
    float               currentYaw;
    float               currentHeading;
    float               compassDiff;
    float               northOffest;
    
    float GeoAngle;
}

@end

@implementation TagDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mapView.userLocation.title = @"You are Here";
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setDateFormat:@"hh:mm a"];
        self.mapView.userLocation.subtitle = [@"Tagged at: "
                                              stringByAppendingString:
                                              [dateFormatter stringFromDate:self.tagDate]];
    });
    firstMapUpdate = YES;
    if (!self.isCalibrated) {
        [self calibrate];
        self.isCalibrated = YES;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.mapView removeAnnotations:self.mapView.annotations];
    self.mapView.showsUserLocation = YES;
    self.mapView.delegate = self;
    self.youLatLonButton.font = [UIFont systemFontOfSize:14];
    self.tagLatLonButton.font = [UIFont systemFontOfSize:14];
    
    oldHeading          = 0;
    offsetG             = 0;
    newCompassTarget    = 0;
    
    // Set up location manager
    locationManager=[[CLLocationManager alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    [locationManager startUpdatingHeading];
    
    // We listen to events from the locationManager
    locationManager.delegate=self;
    
    // Set up motionManager
    motionManager = [[CMMotionManager alloc]  init];
    motionManager.deviceMotionUpdateInterval = 1.0/60.0;
    opQ = [NSOperationQueue currentQueue];
    
    if(motionManager.isDeviceMotionAvailable) {
        
        // Listen to events from the motionManager
        motionHandler = ^ (CMDeviceMotion *motion, NSError *error) {
            CMAttitude *currentAttitude = motion.attitude;
            float yawValue = currentAttitude.yaw; // Use the yaw value
            
            // Yaw values are in radians (-180 - 180), here we convert to degrees
            float yawDegrees = CC_RADIANS_TO_DEGREES(yawValue);
            currentYaw = yawDegrees;
            
            // We add new compass value together with new yaw value
            yawDegrees = newCompassTarget + (yawDegrees - offsetG);
            
            // Degrees should always be positive
            if(yawDegrees < 0) {
                yawDegrees = yawDegrees + 360;
            }
            
            compassDif.text = [NSString stringWithFormat:@"Gyro: %f",yawDegrees]; // Debug
            
            float gyroDegrees = (yawDegrees*radianConst);
            
            // If there is a new compass value the gyro graphic animates to this position
            if(updateCompass) {
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.25];
                [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                [self.rotateImg setTransform:CGAffineTransformMakeRotation(gyroDegrees)];
                [UIView commitAnimations];
                updateCompass = 0;
                
            } else {
                self.rotateImg.transform = CGAffineTransformMakeRotation(gyroDegrees);
            }
        };
        
        
    } else {
        NSLog(@"No Device Motion on device.");
    }
    
    // Start listening to motionManager events
    [motionManager startDeviceMotionUpdatesToQueue:opQ withHandler:motionHandler];
    
    // Start interval to run every other second
    updateTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(updater:) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

// decides on direction to point at
//northOffset becomes my reference to where I want the gyroscope to always origin from.

- (void)updater:(NSTimer *)timer
{
    // If the compass hasn't moved in a while we can calibrate the gyro
    if(updatedHeading == oldHeading) {
        NSLog(@"Update gyro");
        // Populate newCompassTarget with new compass value and the offset we set in calibrate
        newCompassTarget = (0 - updatedHeading) + northOffest;
        compassFault.text = [NSString stringWithFormat:@"newCompassTarget: %f",newCompassTarget]; // Debug
        offsetG = currentYaw;
        updateCompass = 1;
    } else {
        updateCompass = 0;
    }
    
    oldHeading = updatedHeading;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    // Update variable updateHeading to be used in updater method
    updatedHeading = newHeading.magneticHeading;
    float headingFloat = 0 - newHeading.magneticHeading;
    
    // Update rotation of graphic compassImg
    self.compassImg.transform = CGAffineTransformMakeRotation((headingFloat + northOffest)*radianConst);
    
    // Update rotation of graphic trueNorth
    self.arrowImage.transform = CGAffineTransformMakeRotation(headingFloat*radianConst);
}

//-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
//{
//    GeoAngle = [self setLatLonForDistanceAndAngle:newLocation];
//}
//
//-(float)setLatLonForDistanceAndAngle:(CLLocation *)userlocation
//{
//    float lat1 = DegreesToRadians(userlocation.coordinate.latitude);
//    float lon1 = DegreesToRadians(userlocation.coordinate.longitude);
//    
//    float lat2 = DegreesToRadians(self.tagCoordinate.latitude);
//    float lon2 = DegreesToRadians(self.tagCoordinate.longitude);
//    
//    float dLon = lon2 - lon1;
//    
//    float y = sin(dLon) * cos(lat2);
//    float x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
//    float radiansBearing = atan2(y, x);
//    if(radiansBearing < 0.0)
//    {
//        radiansBearing += 2*M_PI;
//    }
//    
//    return radiansBearing;
//}
//
//- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
//{
//    float direction = -newHeading.trueHeading;
//    
//    self.arrowImage.transform=CGAffineTransformMakeRotation((direction* M_PI / 180)+ GeoAngle);
//}


-(void)showRoute:(MKDirectionsResponse *)response
{
    for (MKRoute *route in response.routes) {
        [self.mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.strokeColor = [UIColor blueColor];
    renderer.lineWidth = 5.0;
    return renderer;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
//    self.mapView.centerCoordinate = userLocation.location.coordinate;
    
    [self updateDirections];
    
    // position map window
    if (firstMapUpdate) {
        self.mapView.centerCoordinate = userLocation.location.coordinate;
        [self updateMapWindow];
        firstMapUpdate = NO;
    }
    
}

-(void)updateMapWindow
{
    CLLocationDegrees srcLatitude = self.mapView.userLocation.location.coordinate.latitude;
    CLLocationDegrees srcLongitude = self.mapView.userLocation.location.coordinate.longitude;
    CLLocation *pointALocation = [[CLLocation alloc] initWithLatitude:srcLatitude longitude:srcLongitude];
    CLLocation *pointBLocation = [[CLLocation alloc] initWithLatitude:self.tagCoordinate.latitude longitude:self.tagCoordinate.longitude];
    CLLocationDistance d = [pointALocation distanceFromLocation:pointBLocation];
    MKCoordinateRegion r = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.location.coordinate, 2*d, 2*d);
    [self.mapView setRegion:r animated:NO];
}

- (void)updateDirections
{
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    CLLocationDegrees srcLatitude = self.mapView.userLocation.location.coordinate.latitude;
    CLLocationDegrees srcLongitude = self.mapView.userLocation.location.coordinate.longitude;
    MKPlacemark *source = [[MKPlacemark alloc]initWithCoordinate:CLLocationCoordinate2DMake(srcLatitude, srcLongitude)
                                               addressDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"", nil] ];
    
    MKMapItem *srcMapItem = [[MKMapItem alloc]initWithPlacemark:source];
    [srcMapItem setName:@""];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.youLatLonButton setTitle:[NSString stringWithFormat:@"%f, %f", srcLatitude, srcLongitude] forState:UIControlStateNormal];
        [self.tagLatLonButton setTitle:[NSString stringWithFormat:@"%f, %f", self.tagCoordinate.latitude, self.tagCoordinate.longitude]
                              forState:UIControlStateNormal];
    });
    
    
    MKPlacemark *destination = [[MKPlacemark alloc]initWithCoordinate:CLLocationCoordinate2DMake(self.tagCoordinate.latitude, self.tagCoordinate.longitude)
                                                    addressDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"", nil] ];
    
    MKMapItem *distMapItem = [[MKMapItem alloc]initWithPlacemark:destination];
    [distMapItem setName:@""];
    
    request.source = srcMapItem;
    request.destination = distMapItem;
    request.requestsAlternateRoutes = NO;
    [request setTransportType:MKDirectionsTransportTypeWalking];
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    
    [directions calculateDirectionsWithCompletionHandler:
     ^(MKDirectionsResponse *response, NSError *error) {
         if (error) {
//             UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"An Error Occurred"
//                                                                             message:[NSString stringWithFormat:@"%@", error]
//                                                                            delegate:nil
//                                                                   cancelButtonTitle:@"OK"
//                                                                   otherButtonTitles:nil];
//             [errorAlert show];
             dispatch_async(dispatch_get_main_queue(), ^{
                 self.onlineLabel.textColor = [UIColor redColor];
                 self.onlineLabel.text = @"offline";
             });
         } else {
             dispatch_async(dispatch_get_main_queue(), ^{
                 self.onlineLabel.textColor = [UIColor colorWithRed:0.0f/255.0f green:128.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
                 self.onlineLabel.text = @"online";
                 MKRoute *routeDetails = response.routes.lastObject;
                 self.walkTimeLabel.text = [@"Walk Time: " stringByAppendingString:[self stringFromTimeInterval:[routeDetails expectedTravelTime]]];
                 [self.mapView addOverlay:routeDetails.polyline];
                 self.distanceLabel.text = [NSString stringWithFormat:@"Distance: %0.1f Miles", routeDetails.distance/1609.344];
                 [self showRoute:response];
             });
         }
     }];
}

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
}

#pragma mark - MFMailComposeViewControllerDelegate methods
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result {
//    switch (result) {
//        case MessageComposeResultCancelled: break;
            
    if (result == MessageComposeResultFailed) {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Oups, error while sendind SMS!"
                                                                  delegate:nil cancelButtonTitle:@"OK"
                                                         otherButtonTitles:nil];
            [warningAlert show];
    }
            
//        case MessageComposeResultSent: break;
        
//        default: break;
//    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)sendSMS:(CLLocationCoordinate2D)coordinate withMessage:(NSString *)message
{
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device cannot send text messages" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    //set receipients
//    NSArray *recipients = [NSArray arrayWithObjects:@"0650454323",@"0434320943",@"0560984122", nil];
    
    //set message text
//    NSString * message = @"http://maps.google.com/maps?q=lat,lng";
    
    NSString *mapUrl = [NSString stringWithFormat:@"http://maps.google.com/?q=%f,%f", coordinate.latitude, coordinate.longitude];
    NSString *messageBody = [message stringByAppendingString:mapUrl];
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:nil];
    [messageController setBody:messageBody];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}

- (IBAction)tagLatLonButton:(UIButton *)sender
{
    [self sendSMS:self.tagCoordinate withMessage:@"My Destination is: "];
}

- (IBAction)youLatLonButton:(UIButton *)sender
{
    [self sendSMS:self.mapView.userLocation.location.coordinate withMessage:@"My Current Location is: "];
}
- (void)calibrate
{
    northOffest = updatedHeading - 0;
}
- (IBAction)calibrateButton:(UIButton *)sender {
    [self calibrate];
}
@end
