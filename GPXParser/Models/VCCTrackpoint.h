//
//  VCCTrackpoint.h
//  Debriefing
//
//  Created by Kohei Kajimoto on 2017/04/26.
//  Copyright © 2017 koheik.com. All rights reserved.
//

#ifndef Header_h
#define Header_h

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface VCCTrackpoint : NSObject
@property (nonatomic, assign) double epoch;
@property (nonatomic, assign) double heading;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (nonatomic, assign) double speed;

- (CLLocationCoordinate2D)coordinate;
@end

#endif /* Header_h */
