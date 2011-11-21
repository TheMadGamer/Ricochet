//
//  GopherAppDelegate.m
//  Gopher
//

//  Copyright 3dDogStudios 2010. All rights reserved.
//

#import "GopherAppDelegate.h"

#import <Heyzap/Heyzap.h>
#if USE_OF
#import "OpenFeint.h"
#endif

#import "GopherGameController.h"

// singleton app delegate
static GopherAppDelegate *g_appDelegate;

@implementation GopherAppDelegate

@synthesize window;
@synthesize gopherGameController;


// singleton app delegate
+ (GopherAppDelegate *) appDelegate
{
	return g_appDelegate;
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {

	g_appDelegate = self;
	
	application.statusBarHidden = YES;
	
	[[UIApplication sharedApplication ] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];
	
	// create the goph game controller
	GopherGameController *gameController = 
	[[GopherGameController alloc] initWithNibName:@"GopherGameController" bundle:[NSBundle mainBundle]];
	
	self.gopherGameController = gameController;
	[gameController release];
	
	
	[window addSubview:[gopherGameController view]];
	
	gopherGameController.view.frame = window.frame;
	
	// keep from dimming screen
	[application setIdleTimerDisabled:YES];
	
    [HeyzapSDK startHeyzapWithAppId: @"477851597"];
    
}


- (void)applicationWillResignActive:(UIApplication *)application {
	
	[gopherGameController appPaused];
#if USE_OF	
	[OpenFeint applicationWillResignActive];
#endif
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
	[gopherGameController appResumed];
#if USE_OF
	[OpenFeint applicationDidBecomeActive];
#endif
}

- (void)dealloc {
#if USE_OF
	[OpenFeint shutdown];
#endif
	[window release];
	
	[gopherGameController release];
	
	[super dealloc];
}

@end
