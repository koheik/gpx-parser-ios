//
//  VCCParser.m
//  Debriefing
//
//  Created by Kohei Kajimoto on 2017/04/26.
//  Copyright © 2017 koheik.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "VCCParser.h"

@interface VCCParser () {
    VCCTrackpoint *_previousTrackpoint;
}
- (void)parse:(NSData *)data completion:(void(^)(BOOL success, VCC *vcc))completionHandler;
- (void)generatePaths;
@end

@implementation VCCParser
@synthesize vcc=_vcc;
@synthesize currentString=_currentString;
@synthesize track=_track;
@synthesize trackpoint=_trackpoint;
@synthesize callback=_callback;

#pragma mark Initialization

+ (void)parse:(NSData *)data completion:(void(^)(BOOL success, VCC *vcc))completionHandler {
    [[self new] parse:data completion:completionHandler];
}

#pragma mark - XML Parser

- (id)init {
    if (self = [super init]) {
        self.dateFormat = [NSISO8601DateFormatter new];
    }
    return self;
}


#pragma mark - Parsing

- (void)parse:(NSData *)data completion:(void(^)(BOOL success, VCC *vcc))completionHandler {
    self.callback = completionHandler;
    
    NSXMLParser *_parser = [[NSXMLParser alloc] initWithData:data];
    [_parser setDelegate:self];
    [_parser setShouldProcessNamespaces:NO];
    [_parser setShouldReportNamespacePrefixes:NO];
    [_parser setShouldResolveExternalEntities:NO];
    [_parser parse];
}

#pragma mark - XML Parser

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if(!_currentString) self.currentString = [[NSMutableString alloc] init];
    
    [_currentString appendString:string];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    dispatch_async(dispatch_get_main_queue(), ^{
        _callback(NO, nil);
    });
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validError {
    dispatch_async(dispatch_get_main_queue(), ^{
        _callback(NO, nil);
    });
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
    self.vcc = [VCC new];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    [self generatePaths];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _callback(YES, _vcc);
    });
}


- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict
{
    // CapturedTrack
    if ([elementName isEqualToString:@"CapturedTrack"]) {
        if (!self.track) self.track = [VCCTrack new];
        self.track.name = [attributeDict objectForKey:@"name"];
    }
    
    if ([elementName isEqualToString:@"Trackpoints"]) {
    }
    
    
    // Track point
    if ([elementName isEqualToString:@"Trackpoint"] && self.track) {
        if (!self.trackpoint) {
            self.trackpoint = [VCCTrackpoint new];
            self.trackpoint.epoch = [[attributeDict objectForKey:@"dateTime"] integerValue];
            self.trackpoint.heading = [[attributeDict objectForKey:@"heading"] doubleValue];
            self.trackpoint.latitude = [[attributeDict objectForKey:@"latitude"] doubleValue];
            self.trackpoint.longitude = [[attributeDict objectForKey:@"longitude"] doubleValue];
            self.trackpoint.speed = [[attributeDict objectForKey:@"speed"] doubleValue];
            
            NSString* input = [attributeDict objectForKey:@"dateTime"];
            NSDate* output = [self.dateFormat dateFromString:input];
            self.trackpoint.epoch = [output timeIntervalSince1970];
        }
    }
    
    
    // DeviceInfo
    if ([elementName isEqualToString:@"DeviceInfo"]) {
        self.currentString = [NSMutableString string];
    }
}

- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
{
    // End track
    if([elementName isEqualToString:@"CapturedTrack"] && self.track) {
        [self.vcc.tracks addObject:self.track];
        self.track = nil;
        return;
    }
    
    // End track point
    if([elementName isEqualToString:@"Trackpoint"] && self.trackpoint && self.track) {
        [self.track.trackpoints addObject:self.trackpoint];
        self.trackpoint = nil;
        return;
    }
    
    
    // End waypoint
    if([elementName isEqualToString:@"DeviceInfo"]) {
        if (self.track) {
            self.track.deviceinfo = self.currentString;
        }
        self.currentString = nil;
        return;
    }
}

#pragma mark - Conversion

- (void)generatePaths {
    CLLocationCoordinate2D _topLeftCoord;
    CLLocationCoordinate2D _bottomRightCoord;
    
    BOOL _hasRegion = NO;
    
    // Fill the tracks
    for (VCCTrack *track in _vcc.tracks) {
        CLLocationCoordinate2D *_coordinates = malloc(sizeof(CLLocationCoordinate2D) *track.trackpoints.count);
        for(int i = 0; i < track.trackpoints.count; i++) {
            VCCTrackpoint *fix = [track.trackpoints objectAtIndex:i];
            CLLocationCoordinate2D _coordinate = [fix coordinate];
            _coordinates[i] = _coordinate;
            
            // Set map bounds
            if (!_hasRegion) {
                _topLeftCoord = _coordinate;
                _bottomRightCoord = _coordinate;
                _hasRegion = YES;
            } else {
                _topLeftCoord.longitude = fmin(_topLeftCoord.longitude, _coordinate.longitude);
                _topLeftCoord.latitude = fmax(_topLeftCoord.latitude, _coordinate.latitude);
                
                _bottomRightCoord.longitude = fmax(_bottomRightCoord.longitude, _coordinate.longitude);
                _bottomRightCoord.latitude = fmin(_bottomRightCoord.latitude, _coordinate.latitude);
            }
            if (_previousTrackpoint) {
                static double RAD_PER_DEG = M_PI / 180.0;
                double Rkm = 6371;
                double dlon = _coordinate.longitude - _previousTrackpoint.coordinate.longitude;
                double dlat = _coordinate.latitude - _previousTrackpoint.coordinate.latitude;
                double dlonRad = dlon * RAD_PER_DEG;
                double dlatRad = dlat * RAD_PER_DEG;
                double lat1Rad = _previousTrackpoint.coordinate.latitude * RAD_PER_DEG;
                double lat2Rad = _coordinate.latitude * RAD_PER_DEG;
                double a = pow((sin(dlatRad / 2)), 2.0) + cos(lat1Rad) * cos(lat2Rad) * pow(sin(dlonRad / 2), 2.0);
                double c = 2 * atan2(sqrt(a), sqrt(1 - a));
                double distance = Rkm * c;
                if (isnan(distance)) distance = 0;
                _vcc.distance += distance;
            } else {
                _vcc.distance = 0;
            }
            _previousTrackpoint = fix;
        }
        track.path = [MKPolyline polylineWithCoordinates:_coordinates count:track.trackpoints.count];
        track.shadowPath = [MKPolyline polylineWithCoordinates:_coordinates count:track.trackpoints.count];
        free(_coordinates);
    }
}
@end
