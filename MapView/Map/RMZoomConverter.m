//
//  RMZoomConverter.m
//  LayeredMap
//
//  Created by Tomáš Kohout on 03.03.13.
//
//

#import "RMZoomConverter.h"
#import "RMTile.h"
#import <CoreLocation/CoreLocation.h>
#import "FMDatabase.h"

@implementation RMZoomConverter
RMTile baseTile;
int zoomSteps;

CGFloat DegreesToRadians(CGFloat degrees)
{
    return degrees * M_PI / 180;
};

CGFloat RadiansToDegrees(CGFloat radians)
{
    return radians * 180 / M_PI;
};

typedef struct{
    __unsafe_unretained NSDecimalNumber * x;
    __unsafe_unretained NSDecimalNumber * y;
    int zoom;
}RMTileDec;


-(id)initWithBaseTile:(RMTile)aBaseTile zoomSteps: (int) aZoomSteps{
    self = [super init];
    
    if (self){
        baseTile.x = aBaseTile.x;
        baseTile.y = aBaseTile.y;
        baseTile.zoom  = aBaseTile.zoom;
        
        zoomSteps = aZoomSteps;
    }
    return self;
}

-(int)maxZoom{
    return 21 - zoomSteps;
}

- (int)minZoom{
    return zoomSteps;
}

#pragma mark Tile conversion

//Loosing precision when zooming down!!!
- (RMTile) convertTile: (RMTile) tile toZoom: (int) zoom{
    RMTile newTile;
    
    double multiplier =  (double)pow(2, tile.zoom - zoom);
    
    newTile.x = tile.x / multiplier;
    newTile.y = tile.y / multiplier;
    newTile.zoom = zoom;
    
    return newTile;
}

- (RMTile) reverseConvertTile: (RMTile) tile{
    RMTile converted;
    
    RMTile baseTileToTileZoom = [self convertTile:baseTile toZoom: tile.zoom];
    
    RMTile baseTileToSmallerZoom = [self convertTile:baseTile toZoom: tile.zoom - zoomSteps];
    
    converted.x = baseTileToSmallerZoom.x + (tile.x - baseTileToTileZoom.x);
    converted.y = baseTileToSmallerZoom.y + (tile.y - baseTileToTileZoom.y);
    converted.zoom = tile.zoom - zoomSteps;
    
    return converted;
}

- (RMTile) convertTile: (RMTile) tile{
    RMTile converted;

    RMTile baseTileToTileZoom = [self convertTile:baseTile toZoom: tile.zoom];
    
    RMTile baseTileToBiggerZoom = [self convertTile:baseTile toZoom: tile.zoom + zoomSteps];
    
    converted.x = baseTileToBiggerZoom.x + (tile.x - baseTileToTileZoom.x);
    converted.y = baseTileToBiggerZoom.y + (tile.y - baseTileToTileZoom.y);
    converted.zoom = tile.zoom + zoomSteps;
    
    return converted;
}

#pragma mark Coordinate conversion

- (RMTileDec) coordinateToTile: (CLLocationCoordinate2D) coord zoom: (double) zoom{
    double long n = pow(2, zoom);
    
    NSDecimalNumber * xtileDec = [[NSDecimalNumber alloc ] initWithDouble: ((coord.longitude + 180.0f) / 360.0f) * n];
    
    NSDecimalNumber * ytileDec = [[NSDecimalNumber alloc ] initWithDouble: (1 - (log(tan(DegreesToRadians(coord.latitude)) + (1/cos(DegreesToRadians(coord.latitude)))) / M_PI)) / 2 * n];
    

    RMTileDec tile;
    
    tile.x = xtileDec;
    tile.y = ytileDec;
    tile.zoom = zoom;
    
    return tile;
}



- (CLLocationCoordinate2D) tileToCoordinate: (RMTileDec) tile{
    
    long long n = pow(2, tile.zoom);
    
    double lon_deg = ([tile.x doubleValue] / n) * 360.0 - 180.0;
    
    
    
    double lat_rad = atan(sinh( M_PI * (1 - 2 * [tile.y doubleValue] / n)));
    double lat_deg = RadiansToDegrees(lat_rad);
    
    CLLocationCoordinate2D coord;
    
    coord.latitude = lat_deg;
    coord.longitude = lon_deg;
    
    return coord;
}

- (CLLocationCoordinate2D) convertCoordinate: (CLLocationCoordinate2D) coord{
    CLLocationCoordinate2D newCoord;
    
    RMTileDec coordTile = [self coordinateToTile:coord zoom:baseTile.zoom];
    
    NSDecimalNumber * baseTileDecX = [[NSDecimalNumber alloc] initWithDouble: baseTile.x ];
    NSDecimalNumber * baseTileDecY = [[NSDecimalNumber alloc] initWithDouble: baseTile.y ];
    
    NSDecimalNumber * multiplier = [[NSDecimalNumber alloc] initWithInt:(int)pow(2, zoomSteps)];
    
    NSDecimalNumber * xDiff = [self abs:[[baseTileDecX decimalNumberBySubtracting: coordTile.x] decimalNumberByMultiplyingBy:multiplier] ] ;
    NSDecimalNumber * yDiff = [self abs:[[baseTileDecY decimalNumberBySubtracting: coordTile.y] decimalNumberByMultiplyingBy:multiplier]];
    
    
    RMTileDec newCoordTile;
    
    newCoordTile.x = [baseTileDecX decimalNumberByAdding:xDiff];
    newCoordTile.y = [baseTileDecY decimalNumberByAdding:yDiff];
    newCoordTile.zoom = coordTile.zoom;
    
    
    newCoord = [self tileToCoordinate: newCoordTile];
    
    return newCoord;
    
}

- (NSDecimalNumber *)abs:(NSDecimalNumber *)num {
    if ([num compare:[NSDecimalNumber zero]] == NSOrderedAscending) {
        // Number is negative. Multiply by -1
        NSDecimalNumber * negativeOne = [NSDecimalNumber decimalNumberWithMantissa:1
                                                                          exponent:0
                                                                        isNegative:YES];
        return [num decimalNumberByMultiplyingBy:negativeOne];
    } else {
        return num;
    }
}

- (void) convertTileSource: (NSString *) filePath {
    
    
    FMDatabase *db = [FMDatabase databaseWithPath:filePath];
    if (![db open]) {
        return;
    }
    
    
    
    FMResultSet *s = [db executeQuery:@"SELECT * FROM tiles"];
    
    NSString * allQueries = @"";
    
    
    while ([s next]) {
        
        RMTile tile;
        tile.x = [s intForColumn:@"col"];
        tile.y = [s intForColumn:@"row"];
        tile.zoom = [s intForColumn:@"zoom"];
        
        
        RMTile convertedTile;
        convertedTile = [self reverseConvertTile:tile];
        
        
        uint64_t key = RMTileKey(convertedTile);
        
        NSString * query = [NSString stringWithFormat:@"UPDATE tiles SET tilekey= '%llu', col= '%i', row= '%i', zoom= '%i'  WHERE tilekey = '%llu';", key, convertedTile.x, convertedTile.y, convertedTile.zoom, [s longLongIntForColumn:@"tilekey"]];
        
        
        
        allQueries = [allQueries stringByAppendingString:query];
        
        /*[db beginTransaction];
         BOOL updateResult = [db executeUpdate: query];
         [db commit];*/
        
        
        
        
    }
    
    NSLog(@"%@", allQueries);
    
    
    return;
}
@end
