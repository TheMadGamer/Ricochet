//
//  GopherGameController.m
//  Gopher
//
//  Created by Anthony Lobay on 5/22/10.
//  Copyright 2010 3dDogStudios. All rights reserved.
//

#import "GopherGameController.h"

#import <Heyzap/Heyzap.h>
#import "NSString+Extensions.h"
#import "NSIndexSet+Extensions.h"
#if USE_OF
#import "OpenFeint.h"
#endif
#import <StoreKit/StoreKit.h>

#import "GopherViewController.h"
#import "InstructionsViewController.h"
#import "LevelPackPurchaseVC.h"
#import "PreferencesViewController.h"

#import "AppSpecificValues.h"
#import "GameCenterManager.h"

using namespace Dog3D;

NSString *const kMyFeatureIdentifier = @"com.3dDogStudios.GopherGoBoom.LevelPack1";

@implementation GopherGameController

@synthesize levels; 
@synthesize levelPackVC;
@synthesize lastLevelName = lastLevelName_;

@synthesize gameCenterManager=gameCenterManager_;

+ (NSString *) levelPlist
{
	// for gopher go boom, Levels
	return @"RicochetLevels.plist";
}

- (NSArray *) levels
{
	if (!levels)
	{				
		NSString *path = [[NSBundle mainBundle] pathForResource:[GopherGameController levelPlist] ofType:nil];		
		levels = [[NSArray arrayWithContentsOfFile:path] retain];
		
		// get lastLevelName
		for( int i = 1; i < [levels count]; i++)
		{
			NSDictionary *dict = [levels objectAtIndex:i];
			
			if([dict valueForKey:@"group"])
			{
				break;
			}
			else
			{
				self.lastLevelName = [ dict objectForKey:@"filename"];
			}
		}	
	}
	return levels;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		mSplashFrame = 0;
		mAudioIsOn = true;
		
		mFinishedGLInit = false;
		mFirstAppearance = true;
		
    }
    return self;
}

#pragma mark In App Purchase

#ifdef IN_APP_PURCHAES
- (void) requestProductData
{
	SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers: [NSSet setWithObject: kMyFeatureIdentifier]];
	request.delegate = self;
	[request start];
}


- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{	
    NSArray *myProduct = response.products;
	NSArray *invalids = response.invalidProductIdentifiers;

	
	for(int i=0;i<[invalids count];i++)
	{
		NSLog(@"Invalid Product identifier: %@", [invalids objectAtIndex:i]);
	}
	
	
	for(int i=0;i<[myProduct count];i++)
	{
		SKProduct *product = [myProduct objectAtIndex:i];
		NSLog(@"Name: %@ - Price: %f",[product localizedTitle],[[product price] doubleValue]);
		NSLog(@"Product identifier: %@", [product productIdentifier]);
		// store this
		
	}
	
    // populate UI
    [request autorelease];	
}

// do plist unlocking
- (void) unlockLevelPack:(NSString *)packID
{
	
}
#endif


#pragma mark IBACTIONS

- (IBAction) buyMoreLevelsPressed
{
	if ([SKPaymentQueue canMakePayments])
	{
		
		[self presentModalViewController:self.levelPackVC 
								animated:YES];
	}
	else
	{
		
		// Warn the user that purchases are disabled.
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Purchases disabled"
													   message:@"You are not authorized to make purchases.  Please enable in-app purchases and try again."
													  delegate:nil
											 cancelButtonTitle:@"OK"
											 otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	
}

// user presses play button
// brings you to level select screen
-(IBAction)play
{
	// fire level select
	PreferencesViewController *controller = [[PreferencesViewController alloc] initWithNibName:@"PreferencesViewController" bundle:nil];
	
	controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	controller.delegate = self;
	
	[self presentModalViewController:controller animated:YES];
	
	[controller release];
}

-(IBAction) scoresPressed
{	
	DLog(@"Scores pressed");
	[self showScoresView];
}

-(IBAction) instructionsPressed
{
	DLog(@"Instructions pressed");
	[self showInstructionsView:@"Basics"];
}

- (IBAction) checkinWithHeyzap:(id)sender {
    [[HeyzapSDK sharedSDK] checkin];
}


#pragma mark AUDIO

-(IBAction)mutePressed
{
	mAudioIsOn = !mAudioIsOn;
	if(mAudioIsOn)
	{
		[mMuteButton setImage:[UIImage imageNamed:@"SoundOn.png"] forState:UIControlStateNormal];
		[self resumePlayback];
	}
	else
	{
		[mMuteButton setImage:[UIImage imageNamed:@"SoundOff.png"] forState:UIControlStateNormal];
		[self pausePlayback];
	}
	
}

- (void)startPlayback {
    if(!mPlayer){
        /*
         * Here we grab our path to our resource
         */
        NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
        resourcePath = [resourcePath stringByAppendingString:@"/SchemingWeasel.mp3"];
        DLog(@"Path to play: %@", resourcePath);
        NSError* err;
		
        //Initialize our player pointing to the path to our resource
        mPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:
				  [NSURL fileURLWithPath:resourcePath] error:&err];
		
        if( err ){
            //bail!
            DLog(@"Audio Failed with reason: %@", [err localizedDescription]);
        }
        else{
            //set our delegate and begin playback
            mPlayer.delegate = self;
            [mPlayer play];
        }
    }
	else {
		[mPlayer play];
	}

}

- (void) restartPlayback
{
	if(mPlayer)
	{
		mPlayer.currentTime = 0;
		[mPlayer play];
	}
	else {
		[self startPlayback];
	}
}

- (void)resumePlayback
{
	if( mPlayer)
	{
		[mPlayer play];
	}
	else {
		[self startPlayback];
	}

}

- (void)pausePlayback {
    DLog(@"Player paused at time: %f", mPlayer.currentTime);
	if( mPlayer)
	{
		[mPlayer pause];
	}
}
 
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
	
	[self restartPlayback];
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
	
}
  
- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player
{
	
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withFlags:(NSUInteger)flags
{
	
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
	
}

#pragma mark Generic Control
- (void) genericViewControllerDidFinish
{
	[self dismissModalViewControllerAnimated:NO];	
	[self animateIn];
}

#pragma mark PREF CONTROL
// finished level select
- (void)preferencesViewControllerDidFinish:(PreferencesViewController *)controller 
                         withSelectedLevel:(NSString*)levelName {
    
	[self dismissModalViewControllerAnimated:NO];
	
	if([levelName isEqualToString:@"None" ]){
		if(mSplashView == nil){
			mSplashView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 480, 320)];
			mSplashView.image = [UIImage imageNamed:@"PlayScreen.png"];
			
			[self.view addSubview:mSplashView];
			
		}
		
		// bailed out
		[self.view addSubview:mLandingView];
		
		mLandingView.frame = CGRectMake(-mLandingView.frame.size.width, 
									   mLandingView.frame.origin.y, 
									   mLandingView.frame.size.width, 
									   mLandingView.frame.size.height);
		[self animateIn];
		
	} else {
        [self setLevelPlayed:levelName played:YES];
		[self showGopherView:levelName];
	}
	
}

#pragma mark INSTRUCTIONS CONTROL

- (void) showInstructionsView:(NSString *) levelName
{
	InstructionsViewController *controller = [[InstructionsViewController alloc] initWithNibName:@"InstructionsViewController" bundle:nil];
	controller.delegate = self;
	controller.levelToLoad = levelName;
	
	controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	[self presentModalViewController:controller animated:NO];
	
	[controller release];
	
}


// finished instructions anim
- (void)instructionsViewControllerDidFinish:(InstructionsViewController *)controller withSelectedLevel:(NSString *)levelName
{
	
	[self dismissModalViewControllerAnimated:NO];
	
	if(![levelName isEqualToString:@"Basics"])
	{
		
		// now load gopher view	
		[self showGopherView:levelName];
	}	
	else 
	{
		[self animateIn];
	}

}

#pragma mark SCORES CONTROL

// TODO Ludo - add in game Center view here IF game center is available
- (void) showScoresView
{
    GKLeaderboardViewController *leaderboardController=[[GKLeaderboardViewController alloc] init];
    if (leaderboardController !=NULL)
        
    {
        leaderboardController.category=kLeaderboardHighScore;
        leaderboardController.timeScope=GKLeaderboardTimeScopeWeek;
        leaderboardController.leaderboardDelegate=self;
        [self presentModalViewController:leaderboardController animated:NO];
    }
    
    
    //do we want to keep local scores like that or only Leader board
    /*
	
	 ScoresViewController *controller = [[ScoresViewController alloc] initWithNibName:@"ScoresViewController" bundle:nil];
	 controller.delegate = self;
	 
	 controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	 [self presentModalViewController:controller animated:NO];
	 
	 [controller release];
	*/ 
}

- (void) showAlertWithTitle: (NSString*) title message: (NSString*) message
{
	UIAlertView* alert= [[[UIAlertView alloc] initWithTitle: title message: message 
                                                   delegate: NULL cancelButtonTitle: @"OK" otherButtonTitles: NULL] 
                         autorelease];
	[alert show];
	
}

- (void) showHighScoreAsync:(NSString *) message {
    
    [self showAlertWithTitle: @"Your new High Score posted to Game Center!"
                     message:nil];
}

- (void) scoreReported: (NSError*) error;
{
	if(error == NULL)
	{
		[self.gameCenterManager reloadHighScoresForCategory: kLeaderboardHighScore];

        // delay this display for 5 seconds
        [self performSelector:@selector(showHighScoreAsync:) withObject:nil afterDelay:4.0f];
	}
	else
	{
		[self showAlertWithTitle: @"Score Report Failed!"
						 message: [NSString stringWithFormat: @"Reason: %@", [error localizedDescription]]];
	}
}


-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
    [self dismissModalViewControllerAnimated:NO];
    [viewController release];
    [self animateIn];
}

#pragma mark GOPHER CONTROL

- (void) showGopherView:(NSString*) levelName
{
	if(mGopherViewController == nil)
	{
		DLog(@"I has a fail");
	}
	
	DLog(@"Level Name %@", levelName);
	
	if(![levelName isEqualToString:@"Splash"])
	{
		[self pausePlayback];
		[mPlayer release];
		mPlayer = nil;
		DLog(@"Paused playback");
	}
	
	// remove this guy
	if( (![levelName isEqualToString:@"Splash"]) &&
		 mSplashView != nil)
	{
		[mSplashView removeFromSuperview];
		[mSplashView release];
		mSplashView = nil;
	}
	
	//[backgroundView removeFromSuperview];
	// TODO - destroy splash image
	[mLandingView removeFromSuperview];
	
	mGopherViewController.delegate = self;
    mGopherViewController.gameCenterManager=self.gameCenterManager;
	[mGopherViewController setLevelName:levelName];
	
	mGopherViewController.view.frame = CGRectMake(0,0,480,320);
	
	//mGopherViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	//[self presentModalViewController:mGopherViewController animated:NO];
	self.view = mGopherViewController.view;
	[mGopherViewController initStuff];
	
	
}

- (void)gopherViewControllerDidFinish:(GopherViewController *)controller withResult:(NSString *)levelName
{
	//[self dismissModalViewControllerAnimated:NO];
	[mGopherViewController shutdownStuff];
	self.view = mBackgroundView;
	
	
	/*if([levelName isEqualToString:@"Splash"])
	{
		// coming in from splash screen
		DLog(@"Done loading splash");
		
		pthread_mutex_lock(&mutex);
		mFinishedGLInit = true;		
		pthread_mutex_unlock(&mutex);
		
	}
	else */
	// go back to prefs view (level load up)
	{	
		// gopher view may have changed this
		if(mAudioIsOn)
		{
			[mMuteButton setImage:[UIImage imageNamed:@"SoundOn.png"] forState:UIControlStateNormal];
			[self restartPlayback];
		}
		else
		{
			[mMuteButton setImage:[UIImage imageNamed:@"SoundOff.png"] forState:UIControlStateNormal];
		}
		
		PreferencesViewController *controller = [[PreferencesViewController alloc] initWithNibName:@"PreferencesViewController" bundle:nil];
		
		//controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
		controller.delegate = self;
		
		[self presentModalViewController:controller animated:NO];
		
		[controller release];		
	}
}

#pragma mark CONTROLLER SPECIFIC

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
   
	
	self.view = mBackgroundView;
	
	if(mSplashFrame == 0)
	{
#if DEBUG
		float delayInterval = 0.1f;
#else
		float delayInterval = 4.0f;
#endif
		[NSTimer scheduledTimerWithTimeInterval:delayInterval
										 target:self
									   selector:@selector(updateCounter:)
									   userInfo:nil
										repeats:NO];
		
	}
	
#ifdef IN_APP_PURCHAES    
	// starts a request for purchase
	[self requestProductData];
	
	// Create an instance of the levelpackVC
	// this will be the observer
	LevelPackPurchaseVC *purchaseVC = [[LevelPackPurchaseVC alloc] initWithNibName:@"LevelPackPurchaseVC" 
																			bundle:nil
																	 andPurchaseID:kMyFeatureIdentifier];
	self.levelPackVC = purchaseVC;
	self.levelPackVC.delegate = self;
	
	[[SKPaymentQueue defaultQueue] addTransactionObserver:self.levelPackVC];
#endif    
    if ([GameCenterManager isGameCenterAvailable])
    {
        
        self.gameCenterManager =[[[GameCenterManager alloc] init] autorelease];
        self.gameCenterManager.delegate=self;
        [self.gameCenterManager authenticateLocalUser];
    }
    else
    {
    //The current device does not support Game Center
    }
}


// delegate needs to unload, load GopherViewController
- (void)updateCounter:(NSTimer *)theTimer {
	// message delegate to do something
	
	if(mSplashFrame == 0)
	{
		mSplashFrame++;
		
		mSplashView.image = [UIImage imageNamed:@"Splash.png"];
		
		[NSTimer scheduledTimerWithTimeInterval:4.0f
										 target:self
									   selector:@selector(updateCounter:)
									   userInfo:nil
										repeats:NO];
		
		
	}
	else if(mSplashFrame == 1)
	{
		mSplashFrame++;
		
		[NSTimer scheduledTimerWithTimeInterval:4.0f
										 target:self
									   selector:@selector(updateCounter:)
									   userInfo:nil
										repeats:NO];
		
		//[self showGopherView:@"Splash"];
	}
	else
	{
	//
	//	pthread_mutex_lock(&mutex);
		
#if USE_OF	
		NSDictionary* settings = [NSDictionary dictionaryWithObjectsAndKeys:
								  [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight], OpenFeintSettingDashboardOrientation,
								  @"GopherGoBoom", OpenFeintSettingShortDisplayName, 
								  [NSNumber numberWithBool:YES], OpenFeintSettingEnablePushNotifications,
								  nil
								  ];
		OFDelegatesContainer* container = [OFDelegatesContainer containerWithOpenFeintDelegate:self];
		
		[OpenFeint initializeWithProductKey:@"R0TWOUEqZvDtxIkBSNwQ"
								  andSecret:@"ZIk4XeNgEnAhSIAcxtyJHcLJD1I2b6KJGc6aRVOTo"
							 andDisplayName:@"Gopher Go Boom"
								andSettings:settings    // see OpenFeintSettings.h
							   andDelegates:container];              // see OFDelegatesContainer.h
		
#endif
		
		//if(mFinishedGLInit)
		{
			mSplashView.image = [UIImage imageNamed:@"PlayScreen.png"];
			
			[self.view addSubview:mLandingView];
			[self animateIn];
			
		}
		/*else {
			
			[NSTimer scheduledTimerWithTimeInterval:2.0f
											 target:self
										   selector:@selector(updateCounter:)
										   userInfo:nil
											repeats:NO];
		}

		pthread_mutex_unlock(&mutex);*/
		
		
	}

}


- (void) viewWillAppear:(BOOL)animated
{
	
#ifndef DEBUG
	if(mScoresButton != nil)
	{
	//	[mScoresButton removeFromSuperview];
//		mScoresButton = nil;
	}
#endif
	
	[super viewWillAppear:animated];
	mLandingView.frame = CGRectMake(-mLandingView.frame.size.width, 
								 mLandingView.frame.origin.y, 
								 mLandingView.frame.size.width, 
								 mLandingView.frame.size.height);
	
		
	
}

- (void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	if(mFirstAppearance)
	{
		[self startPlayback];
		mFirstAppearance = false;
	}
}

// animate in landing view
- (void) animateIn
{
	[UIView beginAnimations:@"LandingViewAnimation" context:nil];
	mLandingView.frame = CGRectMake(0, 
								 mLandingView.frame.origin.y, 
								 mLandingView.frame.size.width, 
								 mLandingView.frame.size.height);
	[UIView commitAnimations];
}
	

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;

    self.gameCenterManager=nil;
}


- (void)dealloc {
    [gameCenterManager release];
    [gameCenterManager_ release];
    [super dealloc];
}

#pragma mark LEVEL PLAYED
////////////////////////////////////////////////////////////////

- (NSString *) playedLevelsFileName
{
	return @"GopherLevelsPlayed.plist";
}

- (NSString *) highScoresFileName
{
	return @"GopherLevelScores.plist";
}

- (void) resetPlayedLevels
{
	{
		NSString *playedLevelsFile = [self.playedLevelsFileName stringByExpandingToUserDirectory];
		NSMutableDictionary *playedLevels = [NSMutableDictionary dictionaryWithContentsOfFile:playedLevelsFile];
		
		if (!playedLevels)
		{
			return;
		}
		
		NSArray *keyArray = [playedLevels allKeys];
		
		for (id key in keyArray) 
		{	
			[playedLevels setValue:NO forKey:key];
		}
		
		[playedLevels writeToFile:playedLevelsFile atomically:YES];
	}
	
	{
		NSString *scoresLevelFile = [self.highScoresFileName stringByExpandingToUserDirectory];
		NSMutableDictionary *playedLevels = [NSMutableDictionary dictionaryWithContentsOfFile:scoresLevelFile];
		
		if (!playedLevels)
		{
			return;
		}
		
		NSArray *keyArray = [playedLevels allKeys];
		
		for (id key in keyArray) 
		{	
			[playedLevels setValue:0 forKey:key];
		}
		
		[playedLevels writeToFile:scoresLevelFile atomically:YES];
	}
}


- (void) setLevelPlayed:(NSString *)playedLevel played:(BOOL)played
{
	if (!playedLevel)
	{
		return;
	}
	
	NSString *playedLevelsFile = [self.playedLevelsFileName stringByExpandingToUserDirectory];
	NSMutableDictionary *playedLevels = [NSMutableDictionary dictionaryWithContentsOfFile:playedLevelsFile];
	
	if (!playedLevels)
	{
		playedLevels = [NSMutableDictionary dictionary];
	}
	
	[playedLevels setValue:[NSNumber numberWithBool:played] forKey:playedLevel];
	
	[playedLevels writeToFile:playedLevelsFile atomically:YES];
}


- (BOOL) isLevelPlayed:(NSString *)levelName
{
	
	NSString *playedLevelsFile = [self.playedLevelsFileName stringByExpandingToUserDirectory];
	NSDictionary *playedLevels = [NSDictionary dictionaryWithContentsOfFile:playedLevelsFile];
	
	if (!playedLevels)
	{
		return NO;
	}
	
	return [[playedLevels valueForKey:levelName] boolValue];
}

- (bool) isLevelUnlockedFromName:(NSString *)currentLevelName
{
#if !GGB_ALLOW_LOCKING
	return true;
#else


	int currentLevelIndex = 0;

	// get index of currentLevelName
	for( int i = 0; i < [levels count]; i++)
	{
		NSDictionary *dict = [levels objectAtIndex:i];
		NSString *levelName = [ dict objectForKey:@"filename"];
		if([currentLevelName isEqualToString:levelName])
		{
			currentLevelIndex = i;
			break;
		}
	}

	if(currentLevelIndex <= 1)
	{
		return true;
	}

	if([self isBonusLevel:currentLevelName])
	{
		return true;
	}
	
	
	NSDictionary *previousDictionary = [levels objectAtIndex:currentLevelIndex -1];
	NSString *previousLevel = [previousDictionary objectForKey:@"filename"];
	
	// they've scored more than a zero
	return [self getScore:previousLevel] > 0;
#endif
	
}

- (NSString*) getNextLevelName: (NSString*) currentLevelName
{
	for( int i = 0; i < [levels count]-1; i++)
	{
		NSDictionary *dict = [levels objectAtIndex:i];
		NSString *levelName = [ dict objectForKey:@"filename"];
		if([currentLevelName isEqualToString:levelName])
		{
			NSDictionary *nextDict = [levels objectAtIndex:i+1];
			return [ nextDict objectForKey:@"filename"];		
			 
		}
	}
	return nil;
	
}

- (bool) isLastLevel: (NSString*) levelName
{	
	return [self.lastLevelName isEqualToString:levelName];
}

- (bool) isBonusLevel: (NSString*) currentLevelName
{
	for( int i = 0; i < [levels count]; i++)
	{
		NSDictionary *dict = [levels objectAtIndex:i];
		NSString *levelName = [ dict objectForKey:@"filename"];
		if([currentLevelName isEqualToString:levelName])
		{
			return [dict valueForKey:@"bonus"];
		}
	}
	return false;
}

- (void) writeScore:(int) score forLevel:(NSString*) levelName 
{
	DLog(@"Writing Scores");
	if (!levelName)
	{
		return;
	}
	
	NSString *playedLevelsFile = [self.highScoresFileName stringByExpandingToUserDirectory];
	NSMutableDictionary *playedLevels = [NSMutableDictionary dictionaryWithContentsOfFile:playedLevelsFile];
	
	if (!playedLevels)
	{
		playedLevels = [NSMutableDictionary dictionary];
	}
	
	[playedLevels setValue:[NSNumber numberWithInt:score] forKey:levelName];
	
	[playedLevels writeToFile:playedLevelsFile atomically:YES];
	
}


- (int) getScore:(NSString*) levelName
{
	DLog(@"Getting Scores");
	
	NSString *playedLevelsFile = [self.highScoresFileName stringByExpandingToUserDirectory];
	NSDictionary *playedLevels = [NSDictionary dictionaryWithContentsOfFile:playedLevelsFile];
	
	if (!playedLevels)
	{
		return 0;
	}
	
	return [[playedLevels valueForKey:levelName] intValue];
}

//
- (int64_t) getGameScore
{
	DLog(@"Get Game Score");
	int64_t gameScore=0;
	NSString *playedLevelsHighScoresFile = [self.highScoresFileName stringByExpandingToUserDirectory];
	NSDictionary *playedLevelsHighScores = [NSDictionary dictionaryWithContentsOfFile:playedLevelsHighScoresFile];
	
	if (!playedLevelsHighScores)
	{
		gameScore= 0;
	}
    else
    { 
        for ( id levelName in playedLevelsHighScores)
    
        {
            int64_t score = [[playedLevelsHighScores valueForKey:levelName] intValue];
            if (score >0)
            {
                gameScore=gameScore+score;
            }
        }
    }
	return gameScore;
}
                    



#pragma mark AUDIO
- (bool) isAudioOn
{
	return mAudioIsOn;
}

- (void) setAudioOn:(bool) isOn
{
	//TODO - actually do something with audio dispatch
	mAudioIsOn = isOn;
}


- (void) appPaused
{
	NSLog(@"App paused - do something");
	
	// if gopher view visible, pause
	if(mGopherViewController!= nil &&
	   (! mFirstAppearance) &&
	   [self view] == [mGopherViewController view])
	{
		[mGopherViewController pauseLevel];
		
		NSLog(@"pause gopher view");
	}
	
}

- (void) appResumed
{
	NSLog(@"App resumed");
}


@end
