//
//  TestMapSource.h
//  MapTestbedFlipMaps
//
//  Created by Tomáš Kohout on 23.01.13.
//
//

#import <Foundation/Foundation.h>
#import "RMAbstractWebMapSource.h"
#import "RMZoomConverter.h"

@interface GoogleMapSource: RMAbstractWebMapSource
- initWithZoomConverter: (RMZoomConverter *) converter;
@end
