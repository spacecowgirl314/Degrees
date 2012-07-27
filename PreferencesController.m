//
//  PreferencesController.m
//  Degrees
//
//  Created by Chloe Stars on 3/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PreferencesController.h"


@implementation PreferencesController
@synthesize aboutController;

- (id)init
{
    self = [super initWithWindowNibName:@"Preferences"];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(IBAction)toggleLoginItem:(id)sender {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"autoStart"]) {
		LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
		[launchController setLaunchAtLogin:YES];
		[launchController release];
	} else {
		LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
		[launchController setLaunchAtLogin:NO];
		[launchController release];
	}
}

- (IBAction)toggleAutodetect:(id)sender {
    // keep field not enabled
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"autoLocation"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateWeather" object:self];
        [manualLocation setEnabled:NO];
	} else {
        // reenable the field
        [manualLocation setEnabled:YES];
        // reload the previous location that we had right away and set the field
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"manualLocation"]!=nil) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateWeather" object:self];
            [manualLocation setStringValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"manualLocation"]];
        }
	}
}

- (IBAction)openAbout:(id)sender {
    // lazy load the PreferencesController
	if (!self.aboutController) {
		AboutController *aC = [[AboutController alloc] init];
		self.aboutController =  aC;
		[aC release];
	}
    
    // open preferences
	[self.aboutController showWindow:self];
}

- (IBAction)segmentAction:(id)sender
{
    // The segmented control was clicked, handle it here 
    NSSegmentedControl *segmentedControl = (NSSegmentedControl *)sender;
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	[standardUserDefaults setBool:(BOOL)segmentedControl.selectedSegment forKey:@"isCelsius"];
	[standardUserDefaults synchronize];
    // and update the weather
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateWeather" object:self];
}

- (void)controlTextDidEndEditing:(NSNotification *)obj {
    //NSBeep();
    [[NSUserDefaults standardUserDefaults] setObject:[manualLocation stringValue] forKey:@"manualLocation"];
    NSLog(@"save me: %@", [manualLocation stringValue]);
    // and update the weather
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateWeather" object:self];
}

- (IBAction)quit:(id)sender {
    [NSApp terminate:nil];
}

- (void)dealloc
{
    [super dealloc];
}

- (void)windowDidLoad
{
    //[unitControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    unitControl.selectedSegment = (int)[[NSUserDefaults standardUserDefaults] boolForKey:@"isCelsius"];
    // enable the field if we disabled autodetection
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"autoLocation"]) {
        [manualLocation setEnabled:NO];
	} else {
        // reenable the field
        [manualLocation setEnabled:YES];
        [manualLocation setStringValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"manualLocation"]];
	}
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
