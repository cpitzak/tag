//
//  TagDetailViewController.m
//  Tag
//
//  Created by Pitzak, Clint J on 9/16/14.
//  Copyright (c) 2014 Pitzak, Clint J. All rights reserved.
// http://www.techotopia.com/index.php/Using_MKDirections_to_get_iOS_7_Map_Directions_and_Routes
//

#import "TagDetailViewController.h"
#import "TagAnnotation.h"
#import "AssetsLibrary/AssetsLibrary.h"
#define CC_RADIANS_TO_DEGREES(__ANGLE__) ((__ANGLE__) / (float)M_PI * 180.0f)
#define radianConst M_PI/180.0

#define RadiansToDegrees(radians)(radians * 180.0/M_PI)
#define DegreesToRadians(degrees)(degrees * M_PI / 180.0)

@interface TagDetailViewController () {
    CLLocationManager *locationManager;
    BOOL firstMapUpdate;
    NSUserDefaults *userDefaults;
    
//    CMDeviceMotionHandler motionHandler;
//    CMMotionManager     *motionManager;
//    NSOperationQueue    *opQ;
//    
//    // Graphics
//    NSTimer             *updateTimer;
//    
//    float               oldHeading;
//    float               updatedHeading;
//    float               newYaw;
//    float               oldYaw;
//    float               offsetG;
//    float               updateCompass;
//    float               newCompassTarget;
//    float               currentYaw;
//    float               currentHeading;
//    float               compassDiff;
//    float               northOffest;
    
    float GeoAngle;
    
    MKAnnotationView *userLocationView;
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
        self.mapView.userLocation.title = @"SMS Your Location";
    });
    firstMapUpdate = YES;
//    if (!self.isCalibrated) {
//        [self calibrate];
//        self.isCalibrated = YES;
//    }
//    if (CLLocationCoordinate2DIsValid(self.tagCoordinate) && CLLocationCoordinate2DIsValid(self.mapView.userLocation.location.coordinate)) {
//        NSLog(@"Coordinate valid");
//        [self updateMapWindow];
//    } else {
//        NSLog(@"Coordinate invalid");
//    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.showsUserLocation = YES;
    self.mapView.delegate = self;
    
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    //clear NSUserDefaults
//    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
//    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    
    NSDictionary *tagLocation = [userDefaults objectForKey:@"tagCoordinate"];
    if (tagLocation) {
        [self loadTagFromDisk:tagLocation];
    } else {
        self.tagCoordinate = kCLLocationCoordinate2DInvalid;
    }
    
    
//    [self.mapView removeAnnotations:self.mapView.annotations];
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
//    [dateFormatter setDateFormat:@"hh:mm a"];
//    NSString *tagTitle = [@"Tagged at: "
//                                 stringByAppendingString:[dateFormatter stringFromDate:self.tagDate]];
//    TagAnnotation *tagAnnotation = [[TagAnnotation alloc]initWithTitle:tagTitle coordinate:self.tagCoordinate];
//    [self.mapView addAnnotation:tagAnnotation];
    
//    oldHeading          = 0;
//    offsetG             = 0;
//    newCompassTarget    = 0;
    
    // Set up location manager
    locationManager=[[CLLocationManager alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    [locationManager startUpdatingHeading];
    
    // We listen to events from the locationManager
    locationManager.delegate=self;
    
//    // Set up motionManager
//    motionManager = [[CMMotionManager alloc]  init];
//    motionManager.deviceMotionUpdateInterval = 1.0/60.0;
//    opQ = [NSOperationQueue currentQueue];
//    
//    if(motionManager.isDeviceMotionAvailable) {
//        
//        // Listen to events from the motionManager
//        motionHandler = ^ (CMDeviceMotion *motion, NSError *error) {
//            CMAttitude *currentAttitude = motion.attitude;
//            float yawValue = currentAttitude.yaw; // Use the yaw value
//            
//            // Yaw values are in radians (-180 - 180), here we convert to degrees
//            float yawDegrees = CC_RADIANS_TO_DEGREES(yawValue);
//            currentYaw = yawDegrees;
//            
//            // We add new compass value together with new yaw value
//            yawDegrees = newCompassTarget + (yawDegrees - offsetG);
//            
//            // Degrees should always be positive
//            if(yawDegrees < 0) {
//                yawDegrees = yawDegrees + 360;
//            }
//            
//            self.compassDiffLabel.text = [NSString stringWithFormat:@"Gyro: %f",yawDegrees]; // Debug
//            
//            float gyroDegrees = (yawDegrees*radianConst);
//            
//            // If there is a new compass value the gyro graphic animates to this position
//            if(updateCompass) {
//                [UIView beginAnimations:nil context:NULL];
//                [UIView setAnimationDuration:0.25];
//                [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//                [self.rotateImg setTransform:CGAffineTransformMakeRotation(gyroDegrees)];
//                [UIView commitAnimations];
//                updateCompass = 0;
//                
//            } else {
//                self.rotateImg.transform = CGAffineTransformMakeRotation(gyroDegrees);
//            }
//        };
//        
//        
//    } else {
//        NSLog(@"No Device Motion on device.");
//    }
//    
//    // Start listening to motionManager events
//    [motionManager startDeviceMotionUpdatesToQueue:opQ withHandler:motionHandler];
//    
//    // Start interval to run every other second
//    updateTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(updater:) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

// decides on direction to point at
//northOffset becomes my reference to where I want the gyroscope to always origin from.

//- (void)updater:(NSTimer *)timer
//{
//    // If the compass hasn't moved in a while we can calibrate the gyro
//    if(updatedHeading == oldHeading) {
////        NSLog(@"Update gyro");
////        // Populate newCompassTarget with new compass value and the offset we set in calibrate
////        newCompassTarget = (0 - updatedHeading) + northOffest;
////        self.compassFaultLabel.text = [NSString stringWithFormat:@"fault: %f",newCompassTarget]; // Debug
////        offsetG = currentYaw;
////        updateCompass = 1;
//    } else {
//        updateCompass = 0;
//    }
//    
//    oldHeading = updatedHeading;
//}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    // Update variable updateHeading to be used in updater method
//    updatedHeading = newHeading.magneticHeading;
//    float headingFloat = 0 - newHeading.magneticHeading;
//    
//    // Update rotation of graphic compassImg
//    self.compassImg.transform = CGAffineTransformMakeRotation((headingFloat + northOffest)*radianConst);
//    
//    // Update rotation of graphic trueNorth
//    self.arrowImage.transform = CGAffineTransformMakeRotation(headingFloat*radianConst);
    
    // user direction
    CLLocationDirection direction = newHeading.magneticHeading;
    
//    for (id subview in userLocationView.subviews) {
//        if ([subview isKindOfClass:[UIImageView class]]) {
//            UIImageView *imageView = (UIImageView *)subview;
//            if (imageView.tag == 100) {
//                imageView.userInteractionEnabled = NO;
//                CGAffineTransform transform = CGAffineTransformMakeRotation(DegreesToRadians(direction));
//                imageView.transform = transform;
//                break;
//            }
//        }
//    }
    CGAffineTransform transform = CGAffineTransformMakeRotation(DegreesToRadians(direction));
    userLocationView.transform = transform;
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

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    firstMapUpdate = YES;
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        userLocationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"userLocationIdentifier"];
        
        //use a custom image for the user annotation
//        UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"userArrow.png"]];
//        imageView.userInteractionEnabled = NO;
//        imageView.tag = 100;
        userLocationView.image = [UIImage imageNamed:@"userArrow.png"];
//        [userLocationView addSubview:imageView];
        
        userLocationView.canShowCallout = YES;
        
        return userLocationView;
        
    } else if ([annotation isKindOfClass:[TagAnnotation class]]) {
        TagAnnotation *tagAnnotation = (TagAnnotation *)annotation;
        MKAnnotationView *tagAnnotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"TagAnnotation"];
        
        if (tagAnnotationView == nil) {
            tagAnnotationView = tagAnnotation.annotationView;
        } else {
            tagAnnotationView.annotation = annotation;
            //http://bakyelli.wordpress.com/2013/10/13/creating-custom-map-annotations-using-mkannotation-protocol/
        }
//        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
//        [dateFormatter setDateFormat:@"hh:mm a"];
//        tagAnnotationView.subtitle = [@"Tagged at: "
//                                     stringByAppendingString:[dateFormatter stringFromDate:self.tagDate]];
        return tagAnnotationView;
    } else {
        return nil;
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
    if (CLLocationCoordinate2DIsValid(self.tagCoordinate) && CLLocationCoordinate2DIsValid(self.mapView.userLocation.location.coordinate)) {
        CLLocationDegrees srcLatitude = self.mapView.userLocation.location.coordinate.latitude;
        CLLocationDegrees srcLongitude = self.mapView.userLocation.location.coordinate.longitude;
        CLLocation *pointALocation = [[CLLocation alloc] initWithLatitude:srcLatitude longitude:srcLongitude];
        CLLocation *pointBLocation = [[CLLocation alloc] initWithLatitude:self.tagCoordinate.latitude longitude:self.tagCoordinate.longitude];
        CLLocationDistance d = [pointALocation distanceFromLocation:pointBLocation];
        MKCoordinateRegion r = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.location.coordinate, 2*d, 2*d);
        [self.mapView setRegion:r animated:NO];
    }
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
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.youLatLonButton setTitle:[NSString stringWithFormat:@"%f, %f", srcLatitude, srcLongitude] forState:UIControlStateNormal];
//        [self.tagLatLonButton setTitle:[NSString stringWithFormat:@"%f, %f", self.tagCoordinate.latitude, self.tagCoordinate.longitude]
//                              forState:UIControlStateNormal];
//    });
    
    
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
                 self.walkTimeLabel.text = [self stringFromTimeInterval:[routeDetails expectedTravelTime]];
                 [self.mapView addOverlay:routeDetails.polyline];
                 self.distanceLabel.text = [NSString stringWithFormat:@"%0.1f Miles", routeDetails.distance/1609.344];
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

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    if ([view.annotation isKindOfClass:[TagAnnotation class]]) {
        NSString *message = [NSString stringWithFormat:@"My Destination is: http://maps.google.com/?q=%f,%f",
                             self.tagCoordinate.latitude,
                             self.tagCoordinate.longitude];
        [self sendSMS:message];
    }
}

//- (IBAction)tagLatLonButton:(UIButton *)sender
//{
//    [self sendSMS:self.tagCoordinate withMessage:@"My Destination is: "];
//}
//
//- (IBAction)youLatLonButton:(UIButton *)sender
//{
//    [self sendSMS:self.mapView.userLocation.location.coordinate withMessage:@"My Current Location is: "];
//}
//- (void)calibrate
//{
//    northOffest = updatedHeading - 0;
//}
//- (IBAction)calibrateButton:(UIButton *)sender {
//    [self calibrate];
//}
- (IBAction)smsButton:(UIButton *)sender {
    NSString *tagUrl = [NSString stringWithFormat:@"http://maps.google.com/?q=%f,%f", self.tagCoordinate.latitude, self.tagCoordinate.longitude];
    NSString *userLocationUrl = [NSString stringWithFormat:@"http://maps.google.com/?q=%f,%f", self.mapView.userLocation.location.coordinate.latitude,
                        self.mapView.userLocation.location.coordinate.longitude];
    NSString *message = [NSString stringWithFormat: @"My current location is %@ and the location that I'm going to is %@", userLocationUrl, tagUrl];
    [self sendSMS:message];
}

-(void)sendSMS:(NSString *)message
{
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device cannot send text messages" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:nil];
    [messageController setBody:message];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}

#pragma mark - Navigation

//-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
//{
//    if ([identifier isEqualToString:@"pushTab"])
//    {
//        //don't put logic here
//        //put code here only if you need to pass data
//        //to the next screen
//        return YES;
//    }
//    return NO;
//}
//
//// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if([segue.identifier isEqualToString:@"cameraSegue"]){
//        
//        TagDetailViewController *tagDetailViewController = (TagDetailViewController *)segue.destinationViewController;
//        tagDetailViewController.tagCoordinate = tagCoordinate;
//        tagDetailViewController.tagDate = tagDate;
//        //        tagDetailViewController.isCalibrated = NO;
//    }
//}

- (IBAction)cameraButton:(UIButton *)sender {
    NSString *imageURLString = [userDefaults objectForKey:@"imageURL"];
    if (imageURLString) {
        [self performSegueWithIdentifier:@"cameraSegue" sender:sender];
    }else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
        imagePicker.allowsEditing = NO;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
    
}

- (IBAction)resetButton:(UIButton *)sender {
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView removeAnnotations:self.mapView.annotations];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [userDefaults removeObjectForKey:@"imageURL"];
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        
//        if (self.newMedia) {
            //            UIImageWriteToSavedPhotosAlbum(image,
            //                                           self,
            //                                           @selector(image:finishedSavingWithError:contextInfo:),
            //                                           nil);
            //            UIImage *viewImage = image;  // --- mine was made from drawing context
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            // Request to save the image to camera roll
            [library writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)[image imageOrientation]
                                  completionBlock:^(NSURL *assetURL, NSError *error){
                                      if (error) {
                                          NSLog(@"error");
                                      } else {
                                          NSLog(@"url %@", assetURL);
                                          [userDefaults setObject:[assetURL absoluteString] forKey:@"imageURL"];
                                          [userDefaults synchronize];
                                      }
                                  }];
//        }
    }
    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        // Code here to support video if enabled
    }
}

-(void)loadTagFromDisk:(NSDictionary *)tagLocation
{
    // current lat, lon
    self.tagCoordinate = CLLocationCoordinate2DMake([[tagLocation objectForKey:@"lat"]doubleValue],
                                                    [[tagLocation objectForKey:@"lon"]doubleValue]);
    // current time
    self.tagDate = [userDefaults objectForKey:@"tagDate"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateFormat:@"hh:mm a"];
    NSString *tagTitle = [@"Tagged at: "
                          stringByAppendingString:[dateFormatter stringFromDate:self.tagDate]];
    TagAnnotation *tagAnnotation = [[TagAnnotation alloc]initWithTitle:tagTitle coordinate:self.tagCoordinate];
    [self.mapView addAnnotation:tagAnnotation];
    
    firstMapUpdate = YES;
//    [self updateMapWindow];
}

-(void)updateTagOnMap
{
    // current lat, lon
    self.tagCoordinate = locationManager.location.coordinate;
    // current time
    self.tagDate = [[NSDate alloc]init];
    [userDefaults setObject:self.tagDate forKey:@"tagDate"];
    [userDefaults removeObjectForKey:@"imageURL"];
    
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView removeAnnotations:self.mapView.annotations];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateFormat:@"hh:mm a"];
    NSString *tagTitle = [@"Tagged at: "
                          stringByAppendingString:[dateFormatter stringFromDate:self.tagDate]];
    TagAnnotation *tagAnnotation = [[TagAnnotation alloc]initWithTitle:tagTitle coordinate:self.tagCoordinate];
    [self.mapView addAnnotation:tagAnnotation];
    
    // store tag coordinate
    NSNumber *lat = [NSNumber numberWithDouble:self.tagCoordinate.latitude];
    NSNumber *lon = [NSNumber numberWithDouble:self.tagCoordinate.longitude];
    [userDefaults setObject:@{@"lat":lat,@"lon":lon} forKey:@"tagCoordinate"];
    [userDefaults synchronize];
    
    firstMapUpdate = YES;
    [self updateMapWindow];
}

- (IBAction)tagButton:(UIButton *)sender {
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    if([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
        [self updateTagOnMap];
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

@end
