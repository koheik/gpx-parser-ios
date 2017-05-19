//
//  VCCTrack.h
//  Debriefing
//
//  Created by Kohei Kajimoto on 2017/04/26.
//  Copyright © 2017 koheik.com. All rights reserved.
//

#ifndef VCCTrack_h
#define VCCTrack_h

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface VCCTrack : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *deviceinfo;
@property (nonatomic, strong) NSMutableArray *trackpoints;

@property (nonatomic, strong) MKPolyline *path;
@property (nonatomic, strong) MKPolyline *shadowPath;
@property (nonatomic, assign) MKCoordinateRegion region;
@end

#endif /* VCCTrack_h */
