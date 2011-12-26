//
//  GopherView.h
//  Gopher
//

//  Copyright 2010 3dDogStudios. All rights reserved.
//


#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "EAGLView.h"

#import "GameEntityFactory.h"
#import "GraphicsManager.h"

#import "SoundEffect.h"

@protocol GopherViewDelegate


// called by gopher view when loadup is complete
- (void) finishedLoadUp;

// called during game play - updates score
- (void) updateScore:(int) score withDead:(int) nDead andTotal:(int) total;

// during limited ball play
- (void) updateScore: (int) score withDead:(int) nDead andTotal:(int) total andBallsLeft:(int) ballsLeft;


// finished level
- (void) finishedLevel:(bool) playerWon;

- (void) pauseLevel;

@end

enum ViewState
{
    LOAD, PLAY, PAUSE, GOPHER_WIN, GOPHER_LOST, EDIT
};

enum EditTool
{
    POT, HEDGE, GOPHER, SPINNER
};

@interface GopherView : EAGLView <UIAccelerometerDelegate> {

	id <GopherViewDelegate> gopherViewController;
	
	UIImage *worldMask;
	UIImage *worldView;
	
	float boundDepth, boundHeight, boundWidth;

	NSTimeInterval lastTimeInterval;
	NSTimeInterval lastAccelInterval;

	GLfloat zEye;

	int delayFrames;
	
	btVector3 touchStart;
	CFTimeInterval touchStartTime;
	
	double startTimeInterval;
	
	float tiltGravityCoef;
	
	int mScore;
	int mDeadGophers;
	int mTotalGophers;
	int mNumBallsLeft;
	
	int fpsFrames;
	float fpsTime;
	
	int physFrames;
	float physTime;
	
	NSString* loadedLevel;
	
	// touch started
	bool movingFarmer;
	
	bool graphics3D;

	bool mDidMove;
	
	bool mEngineInitialized;
    
    bool enableSlider;

}

@property (nonatomic, assign) id<GopherViewDelegate> gopherViewController;
@property (nonatomic, assign) ViewState viewState;
@property (nonatomic, assign) EditTool editTool;
@property (nonatomic, assign) btVector3 editExtents;
@property (nonatomic, assign) float yRotation;

- (void) pauseGame;

- (void) resumeGame;

- (void) initEngine;
- (bool) isEngineInitialized;

- (void) loadLevel:(NSString*) levelName;

- (void) reloadLevel;

- (btVector3) getTouchPoint:( CGPoint ) touchPoint;

// unloads scene mgr
- (void) endLevel;

- (NSString*) loadedLevel;

- (int) currentScore;
- (int) deadGophers;
- (int) remainingBalls;
- (int) numDestroyedObjects;


@end
