//
//  PreferencesController.h
//  Degrees
//
//  Created by Chloe Stars on 3/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AboutController.h"
#import "LaunchAtLoginController.h"


@interface PreferencesController : NSWindowController {
    AboutController *aboutController;
    IBOutlet NSSegmentedControl *unitControl;
    IBOutlet NSTextField *manualLocation;
    IBOutlet NSWindow *window;
}

@property (retain, nonatomic) AboutController *aboutController;

@end
