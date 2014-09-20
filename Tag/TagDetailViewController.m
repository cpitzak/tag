//
//  TagDetailViewController.m
//  Tag
//
//  Created by Pitzak, Clint J on 9/16/14.
//  Copyright (c) 2014 Pitzak, Clint J. All rights reserved.
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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.showsUserLocation = YES;
    self.mapView.delegate = self;
    
    userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *tagLocation = [userDefaults objectForKey:@"tagCoordinate"];
    if (tagLocation) {
        [self loadTagFromDisk:tagLocation];
    } else {
        self.tagCoordinate = kCLLocationCoordinate2DInvalid;
    }
    
    // Set up location manager
    locationManager=[[CLLocationManager alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    [locationManager startUpdatingHeading];
    
    // We listen to events from the locationManager
    locationManager.delegate=self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    // user direction
    CLLocationDirection direction = newHeading.magneticHeading;

    CGAffineTransform transform = CGAffineTransformMakeRotation(DegreesToRadians(direction));
    userLocationView.transform = transform;
}

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
        
        userLocationView.image = [UIImage imageNamed:@"userArrow.png"];
        userLocationView.canShowCallout = YES;

        return userLocationView;
        
    } else if ([annotation isKindOfClass:[TagAnnotation class]]) {
        TagAnnotation *tagAnnotation = (TagAnnotation *)annotation;
        MKAnnotationView *tagAnnotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"TagAnnotation"];
        
        if (tagAnnotationView == nil) {
            tagAnnotationView = tagAnnotation.annotationView;
        } else {
            tagAnnotationView.annotation = annotation;
        }
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
    [self updateDirections];
    // position map window
    if (firstMapUpdate) {
        self.mapView.centerCoordinate = userLocation.location.coordinate;
        [self updateMapWindow:self.mapView.userLocation.location.coordinate
                  coordinateB:self.mapView.userLocation.location.coordinate];
        firstMapUpdate = NO;
    }
}

-(void)updateMapWindow:(CLLocationCoordinate2D)coordinateA coordinateB:(CLLocationCoordinate2D)coordinateB
{
    if (CLLocationCoordinate2DIsValid(coordinateA) && CLLocationCoordinate2DIsValid(coordinateB)) {
        CLLocation *pointALocation = [[CLLocation alloc] initWithLatitude:coordinateA.latitude longitude:coordinateA.longitude];
        CLLocation *pointBLocation = [[CLLocation alloc] initWithLatitude:coordinateB.latitude longitude:coordinateB.longitude];
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
    if (result == MessageComposeResultFailed) {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Oups, error while sendind SMS!"
                                                                  delegate:nil cancelButtonTitle:@"OK"
                                                         otherButtonTitles:nil];
            [warningAlert show];
    }
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
    [self updateMapWindow:self.mapView.userLocation.coordinate coordinateB:self.tagCoordinate];
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
