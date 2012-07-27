//
//  DegreesAppDelegate.m
//  Degrees
//
//  Created by Chloe Stars on 1/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DegreesAppDelegate.h"
#import <CoreGeoLocation/CoreGeoLocation.h>
#import "NSStatusItem+BCStatusItem.h"
#import "BCStatusItemView.h"

#define kGoogleAPIKey @"ABQIAAAAwN4-xNR2K-t2zETmpx22rBRX9LR2cV8fRy0ov3NtvYG8B6ZLlRQf48TesA827dDXzE8S5hQzpQBGmw"

@implementation DegreesAppDelegate

//@synthesize window;
@synthesize currentGeoRequest;
@synthesize preferencesController;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // setup defaults
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"firstRun"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstRun"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"autoLocation"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"briefChanges"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ambientNoise"];
        // bring alert to front
        [NSApp activateIgnoringOtherApps:YES];
        // confirm if user wants to have it run on login
        NSAlert *confirmAutostart = [[[NSAlert alloc] init] autorelease];
        [confirmAutostart addButtonWithTitle:@"Yes"];
        [confirmAutostart addButtonWithTitle:@"No"];
        [confirmAutostart setMessageText:@"Would you like to have Degrees run when you startup or login to your Mac?"];
        [confirmAutostart setInformativeText:@"This is recommended."];
        [confirmAutostart beginSheetModalForWindow:nil modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
    }
    // The window hasn't loaded yet so let the default be nil
    // this is default but I want to make sure it is always nil
    attachedWindow = nil;
	// set previous condition to -1 on launch
	previousCondition = -1;
	// setup growl
	//[GrowlApplicationBridge setGrowlDelegate:self];
	// hide window. we don't need it
	//[window orderOut:nil];
    // Load the initial location
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"autoLocation"]) {
    CGLGeoDataProviderGoogle *googleDataProvider = [[CGLGeoDataProviderGoogle alloc] init];
    [googleDataProvider setApiKey:kGoogleAPIKey];
    [[CGLGeoManager sharedManager] setDataProvider:googleDataProvider];
    [googleDataProvider	release];
    [[CGLGeoManager sharedManager] setDelegate:self];
    }
	// Turn on CoreLocation
    locationManager = [[CLLocationManager alloc] init];
	[locationManager setDelegate:self];
	//[locationManager setPurpose:@"Your location is needed to give you the current weather"];
    [locationManager startUpdatingLocation];
	// Insert code here to initialize your application 
	/*statusItem = [[[NSStatusBar systemStatusBar]
					statusItemWithLength:NSVariableStatusItemLength] retain];*/
    statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:40] retain];
    [statusItem setupView];
	//[statusItem setMenu:menu];
	[statusItem setHighlightMode:YES];
	//[statusItem setToolTip:@"Musica"];
	[statusItem setTitle:@" 73˚"];
    [statusItem setViewDelegate:self];
	//[statusItem setAction:@selector(mouseDown)];
	//[statusItem setImage:[NSImage imageNamed:@"trayIcon.png"]];
	//[statusItem setAlternateImage:[NSImage imageNamed:@"pressedTrayIcon.png"]];
    
    // check for internet needs more real world testing
    if (![self connectedToNetwork]) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Warning" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Please check your internet connection."];
        [alert beginSheetModalForWindow:nil modalDelegate:nil didEndSelector:nil contextInfo:nil];
    }
    
    // allow preferences to tap into instant update
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateLocation) 
                                                 name:@"updateWeather"
                                               object:nil];
}

- (void)alertDidEnd:(NSPanel*) inSheet returnCode:(int)returnCode contextInfo:(NSWindow *) aWindow
{
    // set degrees to start on login
    if(returnCode == NSAlertFirstButtonReturn) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"autoStart"];
        LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
		[launchController setLaunchAtLogin:YES];
		[launchController release];
    }
}

//Snip, you know we're in the implementation...
- (BOOL)connectedToNetwork
{
	// Create zero addy
	struct sockaddr_in zeroAddress;
	bzero(&zeroAddress, sizeof(zeroAddress));
	zeroAddress.sin_len = sizeof(zeroAddress);
	zeroAddress.sin_family = AF_INET;
    
	// Recover reachability flags
	SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
	SCNetworkReachabilityFlags flags;
    
	BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
	CFRelease(defaultRouteReachability);
    
	if (!didRetrieveFlags)
	{
		return NO;
	}
    
	BOOL isReachable = flags & kSCNetworkFlagsReachable;
	BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
	return (isReachable && !needsConnection) ? YES : NO;
}

#pragma mark -
#pragma mark Growl Registration

- (NSDictionary*) registrationDictionaryForGrowl {
	NSString* path = [[NSBundle mainBundle] pathForResource: @"Growl Registration Ticket" ofType: @"growlRegDict"];
	NSDictionary* dictionary = [NSDictionary dictionaryWithContentsOfFile: path];
	return dictionary;
}

#pragma mark -
#pragma mark CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
    // Ignore updates where nothing we care about changed
    /*if (newLocation.coordinate.longitude == oldLocation.coordinate.longitude &&
        newLocation.coordinate.latitude == oldLocation.coordinate.latitude &&
        newLocation.horizontalAccuracy == oldLocation.horizontalAccuracy)
    {
        return;
    }*/
    // instance variables for updating weather. put into arguments
    longitude = newLocation.coordinate.longitude;
    latitude = newLocation.coordinate.latitude;

	// Begin reverse geocoding if allowed
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"autoLocation"]) {
        CGLGeoRequest *geoRequest = [[CGLGeoManager sharedManager] determineGeographicalNameForLocation:newLocation];
        self.currentGeoRequest = geoRequest;
    }
    // update here
    [self updateWeather];
	// make sure we don't have the timer running multiple times
	//[weatherTimer invalidate];
    // 90 for minute 900 for 15 minutes
	[NSTimer scheduledTimerWithTimeInterval:900 target: self selector: @selector(updateLocation) userInfo: nil repeats: NO];
    // Might need to enable this in Lion. Behavior is to continually update so figure something out.
    [locationManager stopUpdatingLocation];
}

/*- (void) updateGeolocation {
    CGLGeoRequest *geoRequest = [[CGLGeoManager sharedManager] determineGeographicalNameForLocation:newLocation];
	self.currentGeoRequest = geoRequest;
}*/

- (void)geoManager:(CGLGeoManager *)inGeoManager determinedLocation:(CGLGeoLocation *)inLocation forRequest:(CGLGeoRequest *)inRequest {
	localZipCode = [[inLocation zip] copy];
	[locationText setStringValue:[[NSString alloc] initWithFormat:@"%@, %@", [inLocation city], [inLocation state]]];
    NSLog(@"country:%@", [inLocation country]);
	/*[self updateWeather];
	// make sure we don't have the timer running multiple times
	[weatherTimer invalidate];
    // 90 for minue 900 for 15 minutes
	weatherTimer = [NSTimer scheduledTimerWithTimeInterval:900 target: self selector: @selector(updateWeather) userInfo: nil repeats: YES];*/
}

- (void)updateLocation {
    // Only load auto location information if we didn't disable this method
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"autoLocation"]) {
        CGLGeoDataProviderGoogle *googleDataProvider = [[CGLGeoDataProviderGoogle alloc] init];
        [googleDataProvider setApiKey:kGoogleAPIKey];
        [[CGLGeoManager sharedManager] setDataProvider:googleDataProvider];
        [googleDataProvider	release];
        [[CGLGeoManager sharedManager] setDelegate:self];
    }
    // Turn on CoreLocation
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    //[locationManager setPurpose:@"Your location is needed to give you the current weather"];
    [locationManager startUpdatingLocation];
}

- (void)updateWeather {
    // when this is true don't let the unit switcher work
    isLoadingData = YES;
    NSLog(@"Updating weather...");
    // set up a timer here that is periodic in checking for weather updates
    // create a nstimer in the header because if we move from house to house we will get updated and the nstimer will need to be reassigned
    //yahooData = [[YahooWeatherData alloc] init];
    //[yahooData fetchDataWithZip:localZipCode isCelsius:[[NSUserDefaults standardUserDefaults] boolForKey:@"isCelsius"]];
    weatherData = [[Weather alloc] init];
    // we autoload the weather with the provided cooridinates
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"autoLocation"]) {
        [weatherData fetchDataWithLatidude:latitude withLongitude:longitude isCelsius:[[NSUserDefaults standardUserDefaults] boolForKey:@"isCelsius"]];
    }
    // for manual location just send the text from the preferences
    // we might want to fetch the location back from the weather service just to let the user know this is what they picked
    // ie no ambiguity matches
    else {
        [weatherData fetchDataWithName:[[NSUserDefaults standardUserDefaults] objectForKey:@"manualLocation"] isCelsius:[[NSUserDefaults standardUserDefaults] boolForKey:@"isCelsius"]];
        [locationText setStringValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"manualLocation"]];
        NSLog(@"manualLocation:%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"manualLocation"]);
    }
    
    // Classic Style - Best used with Lion
    //NSDockTile *tile = [[NSApplication sharedApplication] dockTile];
    //[tile setBadgeLabel:[[NSString alloc]initWithFormat:@"%d˚", [weatherData getTemperature]]];
    
    
    // strings need adjusting to center
    NSString *degrees;
    if ([weatherData getTemperature] < 100) {
        // 73˚
        if ([weatherData getTemperature] > 10) {
            degrees = [[NSString alloc] initWithFormat:@" %d˚", [weatherData getTemperature]];
        }
        // 8˚
        else {
            degrees = [[NSString alloc] initWithFormat:@"  %d˚", [weatherData getTemperature]];
        }
    }
    // 102˚
    else {
        degrees = [[NSString alloc] initWithFormat:@"%d˚", [weatherData getTemperature]];
    }
    //update MAAttachedWindow with current weather conditions
    [weatherText setStringValue:[weatherData getConditions]];
    //update menubar
    [statusItem setTitle:degrees];
    //prepare sounds
    NSSound *rainSound = nil;
    NSSound *stormSound = nil;
    // only allow the sound to be set if desired
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ambientNoise"]) {
        rainSound = [NSSound soundNamed:@"Rain"];
        stormSound = [NSSound soundNamed:@"Thunder"];
    }
    //check if we should play weather sound
    if (previousCondition != [weatherData getCode] || previousCondition == -1) {
        NSLog(@"weather condition changed or first time to: %ld", [weatherData getCode]);
        switch ([weatherData getCode]) {
                // begin rain codes
            case 359:
            case 356:
            case 353:
            case 314:
            case 311:
            case 308:
            case 305:
            case 302:
            case 299:
            case 296:
            case 293:
            case 284:
            case 281:
            case 266:
            case 263:
            case 185:
            case 176:
                [rainSound play];
                [conditionImageView setImage:[NSImage imageNamed:@"rain"]];
                break;
                // begin storm codes
            case 395:
            case 392:
            case 389:
            case 386:
            case 200:
                [stormSound play];
                [conditionImageView setImage:[NSImage imageNamed:@"lightening"]];
                break;
                // clear
            case 113:
                // if night show moon else show sun
                ([self isNight]) ? [conditionImageView setImage:[NSImage imageNamed:@"moon"]] : [conditionImageView setImage:[NSImage imageNamed:@"sun"]];
                break;
                // cloudy
            case 122:
            case 119:
                [conditionImageView setImage:[NSImage imageNamed:@"cloudy"]];
                break;
                // partly cloudy NEED TO ADJUST TIMES FOR NIGHT WITH MOON FOR NIGHT
            case 116:
                [conditionImageView setImage:[NSImage imageNamed:@"partlycloudy"]];
                break;
                // snow
            case 371:
            case 368:
            case 338:
            case 335:
            case 332:
            case 329:
            case 326:
            case 323:
            case 230:
            case 179:
                [conditionImageView setImage:[NSImage imageNamed:@"snow"]];
                break;
                // hail
            case 337:
            case 374:
            case 365:
            case 350:
            case 320:
            case 317:
            case 182:
                [conditionImageView setImage:[NSImage imageNamed:@"hail"]];
                break;
                // snow flurries
            case 227:
                [conditionImageView setImage:[NSImage imageNamed:@"flurries"]];
                break;
                // foggy
            case 260:
            case 248:
            case 143:
                [conditionImageView setImage:[NSImage imageNamed:@"fog"]];
                break;
                // haze
                //case 21:
                //	[conditionImageView setImage:[NSImage imageNamed:@"haze"]];
                //	break;
                // mixed rain and snow
                //case 5:
                //	[conditionImageView setImage:[NSImage imageNamed:@"rain&snow"]];
                //	break;
            default:
                break;
        }
        // Best used with Lion
        //[NSApp setApplicationIconImage: [conditionImageView image]];
        // emit growl
        // don't show growl notification if this is the first time opening
        if (previousCondition != -1) {
            // optional graphic
            // [[[conditionImageView image] TIFFRepresentation] retain]
            //[GrowlApplicationBridge notifyWithTitle: @"Weather Conditions"
            //							description: [yahooData getConditions]
            //					   notificationName: @"Degrees"
            //							   iconData: nil
            //							   priority: 0
            //							   isSticky: NO
            //						   clickContext: nil];
            // only show briefly if the user hasn't requested not to
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"briefChanges"]) {
                [self showBriefly];
            }
        }
        //[self showBriefly];
    }
    previousCondition = [weatherData getCode];
    // done loading data so inform the rest of program it's ok to begin loading again
    // this prevents concurrent loading in the same thread
    isLoadingData=NO;
}

- (BOOL)isNight {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:[NSDate date]];
    NSInteger currentHour = [components hour];
    NSInteger currentMinute = [components minute];
    NSInteger currentSecond = [components second];
    
    if (currentHour < 7 || (currentHour > 19 || currentHour == 19 && (currentMinute > 0 || currentSecond > 0))) {
        return YES;
    }
    else {
        return NO;
    }
}

- (void)mouseDown {
    [statusItem toggleHighlight];
    [self showDegrees];
}

- (void)showDegrees {
    NSPoint pt = NSMakePoint(NSMidX([statusItem frame]), NSMinY([statusItem frame]));
    [self toggleAttachedWindowAtPoint:pt];
}

- (void)toggleAttachedWindowAtPoint:(NSPoint)pt
{
    /*Class cls = NSClassFromString (@"NSPopover");
    if (cls) {
        // 10.7 or greater
        NSPopover *popOver = [[[NSPopover alloc] init] autorelease];
        NSViewController *v = [[[NSViewController alloc] init] autorelease];
        v.view = detailedView;
        [popOver setContentViewController:v];
        NSView *view = [[NSView alloc] init];
        [statusItem setView:view];
        [popOver showRelativeToRect:[[statusItem view] bounds] ofView:[statusItem view] preferredEdge:NSMaxYEdge];
    }*/
    // Why is  true here? Examine....
    if (TRUE) {
        // Attach/detach window.
        if (!attachedWindow) {
            attachedWindow = [[MAAttachedWindow alloc] initWithView:detailedView 
                                                    attachedToPoint:pt 
                                                           inWindow:nil 
                                                             onSide:MAPositionBottom 
                                                         atDistance:5.0];
            [attachedWindow setLevel:kCGFloatingWindowLevel];
            [weatherText setTextColor:[attachedWindow borderColor]];
            [locationText setTextColor:[attachedWindow borderColor]];
            [attachedWindow setAlphaValue:0];
            [attachedWindow fadeInWithDuration:0.15];
            [attachedWindow makeKeyAndOrderFront:self];
            // bring Degrees to focus
            if (!showingBriefly) [NSApp activateIgnoringOtherApps:YES];
            // begin monitoring focus
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc removeObserver:self name:NSWindowDidResignKeyNotification object:nil];
            // we get recursive right here
            // we refer to a function that refers to this one
            [nc addObserver:self
                   selector:@selector(loseFocus)
                       name:NSWindowDidResignKeyNotification
                     object:attachedWindow];
        } else {
            // better way to do this would be to add a plug in a selector so fade out has time to finish
            // i hate making code that complicated though. too much recursive crap makes my head spin
            [attachedWindow fadeOutWithDuration:0.15];
            // wait for fade out before proceeding to hide Degrees
            // do not remove from view prematurely... give ample time
            [NSTimer scheduledTimerWithTimeInterval:0.30 
                                             target:self 
                                           selector:@selector(finishFadeOut) 
                                           userInfo:nil 
                                            repeats:NO];
            // Lion behavior differs on ordering Out and 
            /*if (NSClassFromString (@"NSPopover")) {
                [attachedWindow orderOut:nil];
            }
            [attachedWindow release];
            attachedWindow = nil;*/
        }
    }
}

// This is loaded after fading out to finish the transition
- (void)finishFadeOut {
    // Lion behavior differs on ordering Out and 
    if (NSClassFromString (@"NSPopover")) {
        [attachedWindow orderOut:nil];
    }
    [attachedWindow release];
    attachedWindow = nil;
}

- (void)loseFocus
{
    // make sure disabling this doesn't have an adverse effect
    //![[self.preferencesController window] isVisible]
    if (YES) {
        // only continue to toggle view if Degrees is present
        // ie. don't reopen it if we closed it after the brief showed itself
        if (attachedWindow != nil) {
            [statusItem setHighlight:NO];
            [self showDegrees];
        }
    }
    // reset showing briefly
    showingBriefly = NO;
}

-(IBAction)postToTwitter:(id)sender {
    NSString *status = [[NSString alloc] initWithFormat:@"%ld˚ and %@ (via Degrees)", [weatherData getTemperature], [weatherData getConditions]];
    NSString * encodedParam =  [status stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *twitterURL;
    // if Twitter Mac app is installed
    if ([[NSWorkspace sharedWorkspace]URLForApplicationWithBundleIdentifier:@"com.twitter.twitter-mac"]) {
        NSLog(@"Detected Twitter for Mac");
        twitterURL = [[NSString alloc] initWithFormat:@"twitter://post?message=%@", encodedParam];
    }
    // else post using twitter.com
    else {
        twitterURL = [[NSString alloc] initWithFormat:@"http://twitter.com/home?status=%@", encodedParam];
    }
    // post!
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:twitterURL]];
}

-(IBAction)openPreferences:(id)sender {
    // lazy load the PreferencesController
	if (!self.preferencesController) {
		PreferencesController *pC = [[PreferencesController alloc] init];
		self.preferencesController =  pC;
		[pC release];
	}
    
    // hide degrees
	[attachedWindow orderOut:self];
    [attachedWindow release];
    attachedWindow = nil;
    // double check to make sure this is not highlighted
    [statusItem setHighlight:NO];
    
    // open preferences
	[self.preferencesController showWindow:self];
}

-(void)showBriefly {
    // only show the window if it hasn't been shown already
    if (attachedWindow == nil) {
        // let know we don't want Degrees to interrupt other applications
        showingBriefly = YES;
        [statusItem setHighlight:YES];
        [self showDegrees];
        briefTimer = [NSTimer scheduledTimerWithTimeInterval:5 
                                                      target:self 
                                                    selector:@selector(loseFocus) 
                                                    userInfo:nil 
                                                     repeats:NO];
    }
}


@end
