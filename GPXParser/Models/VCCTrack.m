//
//  VCCTrack.m
//  Debriefing
//
//  Created by Kohei Kajimoto on 2017/04/26.
//  Copyright © 2017 koheik.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VCCTrack.h"

@implementation VCCTrack
@synthesize name=_name;
@synthesize deviceinfo=_deviceinfo;
@synthesize trackpoints=_trackpoints;
@synthesize region=_region;

#pragma mark - Initialization

- (id)init {
    if (self = [super init]) {
        self.trackpoints = [NSMutableArray array];
    }
    return self;
}

#pragma mark - String

- (NSString *)description {
    return [NSString stringWithFormat:@"<Track (trackpoints %lu)>", _trackpoints.count];
}

@end
