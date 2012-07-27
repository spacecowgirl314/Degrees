//
//  AboutController.m
//  Degrees
//
//  Created by Chloe Stars on 3/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AboutController.h"


@implementation AboutController

- (id)init
{
    self = [super initWithWindowNibName:@"About"];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
