//
//  ProgrammaticMapViewController.m
//  ProgrammaticMap
//
//  Created by Hal Mueller on 3/25/09.
//  Copyright Route-Me Contributors 2009. All rights reserved.
//

#import "ProgrammaticMapViewController.h"
#import "RMMapView.h"
#import "RMDBMapSource.h"
#import "RMTileSource.h"
#import "RMOpenStreetMapSource.h"
#import "RMAnnotation.h"
#import "RMMarker.h"
#import "FMDatabase.h"
#import "RMTile.h"
#import "GoogleMapSource.h"
#import "RMZoomConverter.h"
#import "RMShape.h"
@implementation ProgrammaticMapViewController

@synthesize mapView;




RMTile baseTile;
int zoomSteps = 5;

RMZoomConverter * zoomConverter;




- (void)viewDidLoad
{
	NSLog(@"viewDidLoad");
    [super viewDidLoad];
    
    
    
    CLLocationCoordinate2D coord;
    
    
    
    coord.latitude = 50.090555;
    coord.longitude = 14.400512;
    
    
    zoomConverter = [[RMZoomConverter alloc] initWithBaseCoord:coord minZoom:14 zoomSteps:5];
    
    CLLocationCoordinate2D convertedCoord = [zoomConverter convertCoordinate:coord];
    
    GoogleMapSource * googleSource = [[GoogleMapSource alloc] initWithZoomConverter:zoomConverter];
    
    self.mapView = [[RMMapView alloc] initWithFrame:CGRectMake(10, 20, 300, 340)
                                      andTilesource:googleSource
                                   centerCoordinate:convertedCoord
                                          zoomLevel:[zoomConverter maxZoom]
                                       maxZoomLevel:[zoomConverter maxZoom]
                                       minZoomLevel:[zoomConverter minZoom]
                                    backgroundImage:nil];
    
    [self.mapView removeAllCachedImages];
    
    
    self.mapView.delegate = self;
    
    
    [self.mapView setMinZoom:[zoomConverter minZoom]];
    
    
    UIImage *blueMarkerImage = [UIImage imageNamed:@"marker-blue.png"];
        
       
    RMAnnotation *annotation = [RMAnnotation annotationWithMapView:mapView coordinate:convertedCoord andTitle:@"Test marker"];
    
    annotation.annotationIcon = blueMarkerImage;
    annotation.anchorPoint = CGPointMake(0.5, 1.0);
    annotation.annotationType = @"marker";
    
    [mapView addAnnotation:annotation];
    
   
    [mapView setBackgroundColor:[UIColor greenColor]];
	[[self view] addSubview:mapView];
	[[self view] sendSubviewToBack:mapView];
}




- (RMMapLayer *)mapView:(RMMapView *)aMapView layerForAnnotation:(RMAnnotation *)annotation
{
    
    RMMapLayer *marker = nil;
    
    marker = [[[RMMarker alloc] initWithUIImage:annotation.annotationIcon anchorPoint:annotation.anchorPoint] autorelease];
    
    marker.canShowCallout = YES;
    
    marker.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    marker.calloutOffset = CGPointMake(0, 30);
    if (annotation.title)
        [(RMMarker *)marker changeLabelUsingText:annotation.title];
    
    if ([annotation.userInfo objectForKey:@"foregroundColor"])
        [(RMMarker *)marker setTextForegroundColor:[annotation.userInfo objectForKey:@"foregroundColor"]];
    
    return marker;
}

-(void)tapOnCalloutAccessoryControl:(UIControl *)control forAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map{

}


- (void)dealloc
{
    [mapView removeFromSuperview];
	self.mapView = nil;
	[super dealloc];
}

- (IBAction)doTheTest:(id)sender
{
	CLLocationCoordinate2D secondLocation;
	secondLocation.latitude = 54.185;
	secondLocation.longitude = 12.09;
	[self.mapView setCenterCoordinate:secondLocation];
}

@end
