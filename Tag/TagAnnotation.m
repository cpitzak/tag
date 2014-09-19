//
//  TagAnnotation.m
//  Tag
//
//  Created by titanium on 9/18/14.
//  Copyright (c) 2014 Pitzak, Clint J. All rights reserved.
//

#import "TagAnnotation.h"

@implementation TagAnnotation

-(id)initWithTitle:(NSString *)newTitle coordinate:(CLLocationCoordinate2D)coordinate
{
    self = [super init];
    if (self) {
        _title = newTitle;
        _coordinate = coordinate;
    }
    return self;
}

-(MKAnnotationView *)annotationView
{
    MKAnnotationView *annotationView = [[MKAnnotationView alloc]initWithAnnotation:self
                                                                   reuseIdentifier:@"TagAnnotation"];
    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;
    annotationView.image = [UIImage imageNamed:@"tag.png"];
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    return annotationView;
}

@end
