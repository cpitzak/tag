//
//  TagAnnotation.h
//  Tag
//
//  Created by titanium on 9/18/14.
//  Copyright (c) 2014 Pitzak, Clint J. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface TagAnnotation : NSObject <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (copy, nonatomic) NSString *title;

-(id)initWithTitle:(NSString *)newTitle coordinate:(CLLocationCoordinate2D)coordinate;

@end
