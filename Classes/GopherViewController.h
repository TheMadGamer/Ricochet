//
//  GopherViewController.h
//  Gopher
//
//  Created by Anthony Lobay on 5/12/10.
//  Copyright 2010 3dDogStudios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "GopherView.h"
#import "GameCenterManager.h"
#import "AppSpecificValues.h"

@protocol GopherViewControllerDelegate;

@interface GopherViewController : UIViewController <GopherViewDelegate> {
	
	IBOutlet GopherView *gopherView;	
	UIView *scoreView;
	UILabel *scoreLabel;
	
	UIView *mPauseView;
	
	UIView *mEndOfGameView;
	
	UIButton *audioButton;

	UIImageView *mInstructionsView;
	UIButton *mInstructionsButton;
	
	int mFrameIndex;
	
	id <GopherViewControllerDelegate> delegate;
	NSString *levelName;
	
	IBOutlet float tiltGravityCoef;
	IBOutlet bool offsetGravityEnabled;
    GameCenterManager *gameCenterManager;
}

@property (nonatomic, assign) IBOutlet GopherView *gopherView;
@property (nonatomic, assign) id <GopherViewControllerDelegate> delegate;
@property (nonatomic, assign) NSString *levelName;

@property (nonatomic, assign) float tiltGravityCoef;

@property (nonatomic, assign) bool offsetGravityEnabled;
@property (nonatomic,retain) GameCenterManager *gameCenterManager;

- (IBAction) resumePushed:(id)sender;
- (IBAction) endOfGamePushed:(id)sender;
- (IBAction) restartPushed:(id)sender;
- (IBAction) audioButtonPushed:(id)sender;
- (IBAction) helpButtonPushed:(id)sender;
- (IBAction) nextInstructionFramePressed:(id)sender;
- (IBAction) nextLevelPushed:(id) sender;


// animates in a view
- (void) animateIn:(UIView*) animView;

-(void) exitLevel;
-(void) restartLevel;

// pause level decl'd in GopherViewDelegate protocol
-(void) resumeLevel;

-(UILabel *) makeScoreLabel;

- (void)initStuff;
- (void)shutdownStuff;


@end


///////// Protocol for delegate ////////////
@protocol GopherViewControllerDelegate

- (void)gopherViewControllerDidFinish:(GopherViewController *)controller withResult:(NSString *)levelName;

// writes out the score for a win
- (void) writeScore:(int) score forLevel:(NSString*) levelName;

// gets the high score
- (int) getScore:(NSString*)levelName;

//gets the game score as Sum of All level Score
- (int64_t) getGameScore;

- (NSString*) getNextLevelName: (NSString*) currentLevelName;
- (void) setLevelPlayed:(NSString*) levelName played:(BOOL)played;

- (bool) isLastLevel: (NSString*) levelName;
- (bool) isBonusLevel: (NSString*) currentLevelName;

- (bool) isAudioOn;
- (void) setAudioOn:(bool) isOn;

@end