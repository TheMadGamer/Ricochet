//
//  GopherView.m
//  Gopher
//
//  Copyright 2010 3dDogStudios. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import <UIKit/UIKit.h>
#import <OpenGLES/ES1/gl.h>

#import <vector>

#import <btBulletDynamicsCommon.h>

#import "GopherView.h"

#import "GameEntityFactory.h"

#import "PhysicsManager.h"
#import "GraphicsManager.h"
#import "GamePlayManager.h"
#import "SceneManager.h"
#import "AudioDispatch.h"

#import "FakeGLU.h"

#import "TriggerComponent.h"

using namespace Dog3D;
using namespace std;

const float kBallRadius = 0.5;

float kWallHeight = 1;

@implementation GopherView

@synthesize gopherViewController;

@synthesize offsetGravityEnabled;

@synthesize tiltGravityCoef;

- (id) initWithCoder:(NSCoder *)decoder
{
	if (self = [super initWithCoder:decoder])
	{
		
		srand(time(0));
		
		boundWidth = 20.0;
		boundHeight = 30.0; 
		boundDepth = 4.0;
		
		fpsTime = 0;
		fpsFrames = 0;
		
		physFrames = 0;
		physTime = 0;
		
		zEye = 40;
		delayFrames = 0;
		
		mViewState = LOAD;
		
		mScore = -1;
		mTotalGophers = -1;
		mDeadGophers = -1;
		mNumBallsLeft = -1;
		
		touchStartTime = 0;
		touchStart.setZero();
		
        movingFarmer = false;
		
		lastTimeInterval = [NSDate timeIntervalSinceReferenceDate];
		lastAccelInterval = [NSDate timeIntervalSinceReferenceDate];
		
		mEngineInitialized = false;
		
		offsetGravityEnabled = true;
		tiltGravityCoef = 20.0f;
		
		fX = 0;
		fY = 0;
			
        enableSlider = false;		
	}
	
	return self;
}


- (void) pauseGame
{
	mViewState = PAUSE;
}

- (void) resumeGame
{
	mViewState = PLAY;
}

- (void) initEngine
{
	if(mEngineInitialized)
	{
		return;
	}
	
	PhysicsManager::Initialize();
	GraphicsManager::Initialize();
	GamePlayManager::Initialize();
	SceneManager::Initialize();
	AudioDispatch::Initialize();
	
	mEngineInitialized = true;
}

-(bool) isEngineInitialized
{
	return mEngineInitialized;
}

- (void) reloadLevel
{
	NSString *level = [[NSString alloc] initWithUTF8String:SceneManager::Instance()->GetSceneName().c_str()];
	
	SceneManager::Instance()->UnloadScene();
	[self loadLevel:level];
	
}

- (NSString*) loadedLevel
{
	return mLoadedLevel;
}

- (int) currentScore
{
	return GamePlayManager::Instance()->ComputeScore();
}

- (int) deadGophers
{	
	return GamePlayManager::Instance()->GetTotalGophers();
}

-(int) remainingBalls
{
	return GamePlayManager::Instance()->GetNumBallsLeft();
}

- (int) numDestroyedObjects 
{
    return GamePlayManager::Instance()->GetNumDestroyedObjects();
}

- (void) loadLevel:(NSString*) levelName
{

	DLog(@"GView Load Level");
	if([levelName isEqualToString:@"Splash"])
	{
		mViewState = LOAD;
		return;
	}
	
	[levelName retain];
	
	if(mLoadedLevel != nil)
	{
		[mLoadedLevel release];
	}
	
	mLoadedLevel = levelName;
	
	SceneManager::Instance()->LoadScene(levelName);
	GamePlayManager::Instance()->SetGameState(GamePlayManager::PLAY);
	
    self.animationInterval = 1.0 / 60.0;
	
	int score = GamePlayManager::Instance()->ComputeScore();
	int deadGophs = GamePlayManager::Instance()->GetDeadGophers(); 
	int totalGophs = GamePlayManager::Instance()->GetTotalGophers();
	int ballsLeft = GamePlayManager::Instance()->GetNumBallsLeft();
	
    // update score if it has changed
    [ gopherViewController updateScore: score withDead:deadGophs andTotal: totalGophs andBallsLeft:ballsLeft];
	
	mViewState = PLAY;
	DLog(@"GView Done Load");
}

- (void)drawView 
{	
	if(mViewState == PAUSE)
	{
		return; 
	}
	
	[EAGLContext setCurrentContext:context];
	
	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
		
	
	if(!mEngineInitialized)
	{
		[self initEngine];
	}
	
	if(mViewState == LOAD ) 
	{
		// final draw
		GraphicsManager::Instance()->OrthoViewSetup(backingWidth, backingHeight, zEye);		
		
		
		GraphicsManager::Instance()->OrthoViewCleanUp();
		
		mViewState = PAUSE;

		// record these
		startTimeInterval = [NSDate timeIntervalSinceReferenceDate];
		lastTimeInterval = [NSDate timeIntervalSinceReferenceDate];
		
		[gopherViewController finishedLoadUp];
		
	}
	
	
	if(mViewState == PLAY)	
	{
		// transition out of Play
		if(GamePlayManager::Instance()->GetGameState() == GamePlayManager::GOPHER_WIN ||
		   GamePlayManager::Instance()->GetGameState() == GamePlayManager::GOPHER_LOST)
		{
			mViewState = (GamePlayManager::Instance()->GetGameState() == GamePlayManager::GOPHER_LOST)? GOPHER_LOST : GOPHER_WIN;
			
			// message delegate
			[gopherViewController finishedLevel:(mViewState == GOPHER_LOST)]; 
		}
		
	}
	
		
	if(mViewState == PLAY || mViewState == GOPHER_WIN || mViewState == GOPHER_LOST)
	{
		// strangely, there must be no GL context or something in the init 
		GraphicsManager::Instance()->SetupLights();
		GraphicsManager::Instance()->SetupView(
											   backingWidth,  
											   backingHeight,  
											   zEye
											   );
		
		
		glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		
		double dt = ([NSDate timeIntervalSinceReferenceDate] - lastTimeInterval);
		
		
		lastTimeInterval = [NSDate timeIntervalSinceReferenceDate];	
#if DEBUG
		if(fpsTime > 1.0f)
		{
			//float  fps = fpsFrames / fpsTime;
			//NSLog(@"FPS : %f", fps);
				
			fpsTime = 0;
			fpsFrames = 0;
		}
		else {
			fpsFrames++;
			fpsTime += dt;
		}
#endif
		// clamp dt
		dt = MIN(0.2, dt);
		
		// in tilt mode, update phys in acclerometer thread
        PhysicsManager::Instance()->Update(dt);
		GamePlayManager::Instance()->Update(dt);	
		GraphicsManager::Instance()->Update(dt);

		if(mViewState == PLAY)
		{
			SceneManager::Instance()->Update(dt);
		}
		
		int score = GamePlayManager::Instance()->ComputeScore();
		int deadGophs = GamePlayManager::Instance()->GetDeadGophers(); 
		int totalGophs = GamePlayManager::Instance()->GetTotalGophers();
		int ballsLeft = GamePlayManager::Instance()->GetNumBallsLeft();
		
        if(score != mScore || deadGophs != mDeadGophers || totalGophs != mTotalGophers || ballsLeft != mNumBallsLeft)
        {
            // update score if it has changed
            [ gopherViewController updateScore: score withDead:deadGophs andTotal: totalGophs andBallsLeft:ballsLeft];
        }
		
		mScore = score;
		mDeadGophers = deadGophs;
		mTotalGophers = totalGophs;
		mNumBallsLeft = ballsLeft;
	}

	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	[context presentRenderbuffer:GL_RENDERBUFFER_OES];
	
	
	int error = glGetError();
	if(error )
	{ 
		DLog(@"Gl error. Still effed up %d?", error);
	}

}

-(void) endLevel
{
	SceneManager::Instance()->UnloadScene();
	if(mLoadedLevel != nil)
	{
		[mLoadedLevel release];
		mLoadedLevel = nil;
	}
}

- (btVector3) getTouchPoint:( CGPoint ) touchPoint
{
	// map touch into local coordinates
	float x = touchPoint.x/320.0;
	float y = touchPoint.y/480.0;
	
	x -= 0.5;
	x *= -20.0;
	
	y -= 0.5;
	y *= -30.0;
	
	return btVector3(x, 0, y);
}

const float kFarmerMin = 0.5f;
const float kFarmerMax = 10.0f;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{	
    // in non-play, ignore touch
	if(mViewState != PLAY)
	{
		return;
	}
	
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    
	// check for pause touch
	{
		btVector3 touchPt = [self getTouchPoint:touchPoint];
		touchPt -= btVector3(-9,0,-14);
		
		if(touchPt.length() < 1.5f)
		{
			[gopherViewController pauseLevel];
            return;
		}
    }		
	
    for (UITouch *touch in touches) 
    {
        
        CGPoint touchPoint = [touch locationInView:self];
        
        touchStart = [self getTouchPoint:touchPoint];
        btVector3 touchPosition = touchStart;
        
        //changed this to allow run cannon
        if(enableSlider && touchStart.z() > -10)
        {
            GamePlayManager::Instance()->StartSwipe(touchStart);
            //mDidMove = false;
        }
        else
        {
            //
            CannonController *cannon= GamePlayManager::Instance()->GetCannon();
            touchStart -= cannon->GetParent()->GetPosition();
            touchStart.setY(0);
            float dist = touchStart.length();
            if(kFarmerMin <= dist && dist <= kFarmerMax )
            {
                //NSLog(@"Touch near farmer");
                touchStart.normalize();
                movingFarmer = true;
                //NSLog(@"touch start %f %f %f", touchStart.x(), touchStart.y(), touchStart.z());
                
                // nothing happens until we begin rotation on move
            }
            else
            {
                // possibly a fire button 
                GamePlayManager::Instance()->Touch(touchPosition);	
            }
        }        
    }
	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{

	if(mViewState != PLAY)
	{
		return;
	}
	
    for (UITouch *touch in touches) 
    {

        // TODO : send in a relative motion	
        //UITouch *touch = [touches anyObject];
        
        CGPoint touchPoint = [touch locationInView:self];
        
        btVector3 touchPosition = [self getTouchPoint:touchPoint];
        if(enableSlider && touchPosition.z() > 0)
        {
            GamePlayManager::Instance()->MoveSwipe(touchPosition);
            mDidMove = true;
        }
        else
        {
            //
            CannonController *cannon= GamePlayManager::Instance()->GetCannon();
            touchPosition -= cannon->GetParent()->GetPosition();
            touchPosition.setY(0);
            
            float dist = touchPosition.length();
            if(kFarmerMin <= dist && dist <= kFarmerMax )
            {
                //NSLog(@"Move near farmer %f", dist);
                
                // form delta 
                touchPosition.normalize();
                
                btVector3 cp = touchPosition.cross( touchStart );
                float len = cp.y();
                if(len != 0)
                {  
                    //NSLog(@"cp %f %f %f", cp.x(), cp.y(), cp.z());
                    float theta = 0;
                    if(len < 0.001)
                    {
                        theta = len;
                    }
                    else
                    {
                        theta = asin(len);
                    }
                    theta = -theta;
                    //NSLog(@"theta %f z %f", theta, cp.y());
                    
                    if(! isnan(theta))
                    {
                        GamePlayManager::Instance()->ApplyRotation(theta);
                        touchStart = touchPosition;
                    }
                }
                
            }
            else
            {
                movingFarmer = false;
            }
        }  
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	movingFarmer = false;
	
	//GamePlayManager::Instance()->CancelSwipe();
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{

	UITouch *touch = [touches anyObject];
    movingFarmer = false;
    
    return; /////////////////////////////////// RETURN ///////////////
	
			
    //for (UITouch *touch in touches) {

        //CGPoint point = [touch locationInView:self];
        
        CGPoint touchPoint = [touch locationInView:self];
        
        btVector3 touchPosition = [self getTouchPoint:touchPoint];
        
        GamePlayManager::Instance()->Touch(touchPosition);
    //}

}

inline float clamp(float a, float mn, float mx)
{
	if(a > mx)
	{
		return mx;
	}
	if(a < mn)
	{
		return mn;
	}
	return a;
	
}

-(void) dealloc
{	
	GamePlayManager::ShutDown();
	GraphicsManager::ShutDown();
	PhysicsManager::ShutDown();
	SceneManager::ShutDown();
	AudioDispatch::ShutDown();
	
	[super dealloc];	
}
 
@end

