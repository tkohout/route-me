//
//  TestMapSource.m
//  MapTestbedFlipMaps
//
//  Created by Tomáš Kohout on 23.01.13.
//
//

#import "GoogleMapSource.h"
#import "RMTile.h"

#import "RMZoomConverter.h"

@implementation GoogleMapSource

RMZoomConverter * converter;




- initWithZoomConverter: (RMZoomConverter *) aConverter{
    self = [super init];
    if (self){
        
        converter = aConverter;
        
        self.maxZoom = converter.maxZoom;
        self.minZoom = converter.minZoom;
        
    }
    
    return self;
}


- (NSURL *)URLForTile:(RMTile)tile{
    
    NSLog(@"Bef: x: %i y: %i z: %i", tile.x, tile.y,tile.zoom);
    tile = [converter convertTile: tile];
    NSLog(@"Aft: x: %i y: %i z: %i", tile.x, tile.y,tile.zoom);
    
    NSURL* url = [NSURL URLWithString: [NSString stringWithFormat:@"http://mt0.google.com/vt/lyrs=m@127&x=%d&y=%d&z=%d", tile.x, tile.y, tile.zoom ]];
    return url;
    
}

-(NSString*) uniqueTilecacheKey
{
    return @"Google maps";
}

-(NSString *)shortName
{
    return @"Google maps";
}
-(NSString *)longDescription
{
    return @"Google maps";
}
-(NSString *)shortAttribution
{
    return @"Google maps";
}
-(NSString *)longAttribution
{
    return @"Google maps";
}


@end
