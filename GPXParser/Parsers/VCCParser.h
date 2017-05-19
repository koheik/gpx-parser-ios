//
//  VCCParser.h
//  Debriefing
//
//  Created by Kohei Kajimoto on 2017/04/26.
//  Copyright © 2017 koheik.com. All rights reserved.
//

#ifndef VCCParser_h
#define VCCParser_h

#import <Foundation/Foundation.h>

#import "VCC.h"
#import "VCCTrack.h"
#import "VCCTrackpoint.h"

@interface VCCParser : NSObject <NSXMLParserDelegate>
@property (nonatomic, strong) VCC *vcc;
@property (nonatomic, strong) NSISO8601DateFormatter *dateFormat;
@property (nonatomic, strong) NSMutableString *currentString;
@property (nonatomic, strong) VCCTrack *track;
@property (nonatomic, strong) VCCTrackpoint *trackpoint;
@property (nonatomic, copy) void (^callback)(BOOL success, VCC *vcc);

+ (void)parse:(NSData *)data completion:(void(^)(BOOL success, VCC *vcc))completionHandler;

@end
#endif /* VCCParser_h */
