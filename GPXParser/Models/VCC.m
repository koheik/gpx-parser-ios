//
//  VCC.m
//  Debriefing
//
//  Created by Kohei Kajimoto on 2017/04/26.
//  Copyright © 2017 koheik.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VCC.h"

@implementation VCC
@synthesize tracks=_tracks;
@synthesize region=_region;

#pragma mark - Initialization

- (id)init {
    if (self = [super init]) {
        self.tracks    = [NSMutableArray array];
    }
    return self;
}

#pragma mark - String

- (NSString *)description {
    return [NSString stringWithFormat:@"<VCC (tracks %lu)>", _tracks.count];
}
@end
