//
//  VCCTrackpoint.m
//  Debriefing
//
//  Created by Kohei Kajimoto on 2017/04/26.
//  Copyright © 2017 koheik.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VCCTrackpoint.h"

@implementation VCCTrackpoint
@synthesize epoch=_epoch;
@synthesize heading=_heading;
@synthesize latitude=_latitude;
@synthesize longitude=_longitude;
@synthesize speed=_speed;

#pragma mark - Coordinate

- (CLLocationCoordinate2D)coordinate {
    return CLLocationCoordinate2DMake(_latitude, _longitude);
}

#pragma mark - String

- (NSString *)description {
    return [NSString stringWithFormat:@"<Fix (%f %f)>", _latitude, _longitude];
}

@end
