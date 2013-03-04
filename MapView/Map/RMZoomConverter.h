//
//  RMZoomConverter.h
//  LayeredMap
//
//  Created by Tomáš Kohout on 03.03.13.
//
//

#import <Foundation/Foundation.h>
#import "RMTile.h"
#import <CoreLocation/CoreLocation.h>

@interface RMZoomConverter : NSObject
-initWithBaseTile: (RMTile) baseTile zoomSteps: (int) aZoomSteps;
- (RMTile) convertTile: (RMTile) tile;
- (RMTile) reverseConvertTile: (RMTile) tile;

- (CLLocationCoordinate2D) convertCoordinate: (CLLocationCoordinate2D) coord;

- (void) convertTileSource: (NSString *) filePath;


@property (nonatomic, readonly) int maxZoom;
@property (nonatomic, readonly) int minZoom;

@end
