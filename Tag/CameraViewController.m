//
//  CameraViewController.m
//  Tag
//
//  Created by Pitzak, Clint J on 9/17/14.
//  Copyright (c) 2014 Pitzak, Clint J. All rights reserved.
//

#import "CameraViewController.h"
#import "MBProgressHUD.h"

@interface CameraViewController () {
    NSUserDefaults *userDefaults;
}

@end

@implementation CameraViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor blackColor];
    NSString *imageURLString = [userDefaults objectForKey:@"imageURL"];
    if (imageURLString) {
        [self loadImage:imageURLString];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    userDefaults = [NSUserDefaults standardUserDefaults];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadImage:(NSString *)imageURLString
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading";
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
    {
        ALAssetRepresentation *rep = [myasset defaultRepresentation];
        CGImageRef iref = [rep fullResolutionImage];
        if (iref) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.cameraImageView.image = [UIImage imageWithCGImage:[rep fullScreenImage] scale:[rep scale] orientation:0];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        }
    };
    
    ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
    {
        NSLog(@"booya, cant get image - %@",[myerror localizedDescription]);
    };
    
    if(imageURLString && [imageURLString length]) {
        NSURL *asseturl = [NSURL URLWithString:imageURLString];
        ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
        [assetslibrary assetForURL:asseturl
                       resultBlock:resultblock
                      failureBlock:failureblock];
    }
        });
}

- (IBAction)dontUseButton:(UIBarButtonItem *)sender {
    [userDefaults removeObjectForKey:@"imageURL"];
    self.cameraImageView.image = nil;
    [self.navigationController popViewControllerAnimated:YES];
}
@end
