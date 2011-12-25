//
//  GopherGameController.h
//  Gopher
//
//  Created by Anthony Lobay on 5/22/10.
//  Copyright 2010 3dDogStudios. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#ifdef IN_APP_PURCHAES
#import <StoreKit/StoreKit.h>
#endif
#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

#import "PreferencesViewController.h"
#import "InstructionsViewController.h"
#import "GopherViewController.h"
#import "ScoresViewController.h"
#import "LevelPackPurchaseVC.h"
#import "GameCenterManager.h"
#if USE_OF
#import "OpenFeint.h"
#endif

@interface GopherGameController : UIViewController <PreferencesViewControllerDelegate, 
	InstructionsViewControllerDelegate, GopherViewControllerDelegate, 
	AVAudioPlayerDelegate,
	ScoresViewDelegate,
    GameCenterManagerDelegate,
    GKLeaderboardViewControllerDelegate,
#if USE_OF
 OpenFeintDelegate,
#endif
	UIAlertViewDelegate
#ifdef IN_APP_PURCHAES
	,SKProductsRequestDelegate,
	LevelUnlockDelegate>
#else
    >
#endif
{

	// play, sound, scores
	IBOutlet UIView *mLandingView;
		
	// what's this?
	IBOutlet UIImageView *mSplashView;
	
	// what's this?
	IBOutlet UIView *mBackgroundView;
	
	IBOutlet UIButton *mMuteButton;
		
	IBOutlet UIButton *mScoresButton;
		
	// gopher game view	
	IBOutlet GopherViewController *mGopherViewController;

	int mSplashFrame;

	bool mAudioIsOn;
		
	bool mFinishedGLInit;
		
	pthread_mutex_t mutex;	
	
	AVAudioPlayer* mPlayer;

	bool mFirstAppearance;
		
}

+ (NSString *) levelPlist;

@property (readonly) NSString *playedLevelsFileName;
@property (readonly) NSString *highScoresFileName;
@property (nonatomic, retain) LevelPackPurchaseVC *levelPackVC;
@property (nonatomic, retain) NSString *lastLevelName;

@property (nonatomic, retain) NSMutableArray *internalLevels;

@property(nonatomic,retain) GameCenterManager *gameCenterManager;

- (IBAction)mutePressed;

- (IBAction)play;

- (IBAction) scoresPressed;

- (IBAction) instructionsPressed;

- (IBAction) buyMoreLevelsPressed;

- (IBAction) checkinWithHeyzap:(id)sender;

- (void) animateIn;

- (void) showGopherView:(NSString*) levelName;

- (void) showInstructionsView:(NSString *) levelName;

- (void) showScoresView;

- (void) setLevelPlayed:(NSString *)levelName played:(BOOL)played;

- (BOOL) isLevelPlayed:(NSString *)levelName;

- (bool) isLevelUnlockedFromName:(NSString *)currentLevelName;

// for anything returning that doesn't need special handling
- (void) genericViewControllerDidFinish;

/////// AUDIO ///////////

- (bool) isAudioOn;

- (void) setAudioOn:(bool) isOn;

- (void) pausePlayback;
- (void) resumePlayback;
- (void) startPlayback;
- (void) restartPlayback;


- (void) appPaused;
- (void) appResumed;

@end
