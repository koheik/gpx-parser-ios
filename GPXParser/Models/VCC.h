//
//  VCC.h
//  Debriefing
//
//  Created by Kohei Kajimoto on 2017/04/26.
//  Copyright © 2017 koheik.com. All rights reserved.
//

#ifndef VCC_h
#define VCC_h

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface VCC : NSObject
@property (nonatomic, strong) NSMutableArray *tracks;
@property (nonatomic, assign) MKCoordinateRegion region;
@property (nonatomic, assign) double distance;
@end

#endif /* VCC_h */
