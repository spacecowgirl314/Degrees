//
//  DegreesAppDelegate.h
//  Degrees
//
//  Created by Chloe Stars on 1/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreGeoLocation/CoreGeoLocation.h>
#import <Growl/Growl.h>
#import <SystemConfiguration/SCNetworkReachability.h>
#include <netinet/in.h>
//#import "YahooWeatherData.h"
#import "MAAttachedWindow.h"
#import "PreferencesController.h"
#import "Weather.h"
#import "NSWindow+Fade.h"

@class CGLGeoRequest;

@interface DegreesAppDelegate : NSObject <NSApplicationDelegate, CLLocationManagerDelegate, CGLGeoManagerDelegate, GrowlApplicationBridgeDelegate> {
    //NSWindow *window;
	NSStatusItem *statusItem;
	CLLocationManager *locationManager;
	CGLGeoRequest *currentGeoRequest;
	//YahooWeatherData *yahooData;
    Weather *weatherData;
	NSString *localZipCode;
	NSTimer *weatherTimer;
	NSTrackingArea *myTrackingArea;
	MAAttachedWindow *attachedWindow;
	IBOutlet NSView *detailedView;
	IBOutlet NSTextField *weatherText;
	IBOutlet NSTextField *locationText;
	IBOutlet NSImageView *conditionImageView;
	NSInteger previousCondition;
    BOOL showingBriefly;
    BOOL isLoadingData;
    NSTimer *briefTimer;
    double latitude;
    double longitude;
    
    PreferencesController *preferencesController;
}

-(BOOL)connectedToNetwork;
-(BOOL)isNight;
-(void)updateLocation;
-(void)updateWeather;
-(void)showDegrees;
-(void)showBriefly;
-(void)toggleAttachedWindowAtPoint:(NSPoint)pt;
-(IBAction)postToTwitter:(id)sender;

//@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, readwrite, retain) CGLGeoRequest *currentGeoRequest;
@property (retain, nonatomic) PreferencesController *preferencesController;

@end
