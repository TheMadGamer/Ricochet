//
//  GopherViewController.m
//  Gopher
//
//  Created by Anthony Lobay on 5/10/10.
//  Copyright 2010 3dDogStudios. All rights reserved.
//

#import "GopherViewController.h"
#import "InstructionsViewController.h"

#import "AudioDispatch.h"
#import "GraphicsManager.h"
#import "GamePlayManager.h"
#import "PhysicsManager.h"
#import "SceneManager.h"

using namespace Dog3D;

@implementation GopherViewController

@synthesize gopherView;
@synthesize delegate;
@synthesize levelName;
@synthesize offsetGravityEnabled;
@synthesize tiltGravityCoef;
@synthesize gameCenterManager = gameCenterManager_;
@synthesize editorViewController = editorViewController_;

#pragma mark GopherEditProtocol

- (void) startPotTool
{
    [gopherView pauseGame]; 
    gopherView.viewState = EDIT;
}


- (void) startHedgeTool
{
    [gopherView pauseGame];
}


- (void) endEdit 
{    
	[gopherView resumeGame];
    gopherView.viewState = PLAY;
}

- (void) saveLevel:(NSString *)fileName
{
    SceneManager::Instance()->SaveScene(fileName);
}

#pragma mark pause, resume

// pauses level
// puts up a bunch of buttons
- (void)pauseLevel
{
    // no showing pause display in edit mode
    if (gopherView.viewState == EDIT)
    {
        return;
    }
    
	[gopherView pauseGame];
	
	// attach subview
	// pause
	if(mPauseView == nil)
	{
		
		mPauseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
		[gopherView addSubview:mPauseView];
		
		// Rotates button views
		CGAffineTransform transform = CGAffineTransformMakeRotation(3.14159/2);
		mPauseView.transform = transform;
		
		
		/*UIView *pauseGrayBack = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
		[pauseGrayBack setBackgroundColor:[UIColor grayColor]];
		[pauseGrayBack setAlpha:0.50];
		pauseGrayBack.transform = transform;
		[mPauseView addSubview:pauseGrayBack];*/

		/*CGRectMake(-80+60, 80+40, 360, 240)*/
		UIImageView *pauseBack = [[UIImageView alloc] initWithFrame:CGRectMake(-80, 80, 480, 320)];
		[pauseBack setImage:[UIImage imageNamed:@"PauseScreenHalf.png"]];
		//pauseBack.transform = transform;
		
		[mPauseView addSubview:pauseBack];
		
		// resume
		{
			UIButton *resumeButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain]; 
			[resumeButton setBackgroundImage:[UIImage imageNamed:@"Resume.png"] forState:UIControlStateNormal];
			[resumeButton addTarget:self action:@selector(resumePushed:) 
				   forControlEvents:UIControlEventTouchUpInside];
			
			
			CGRect rect = CGRectMake(246-80,146+80,161,52);
			[resumeButton setFrame:rect];
			
			[mPauseView addSubview:resumeButton];
		}
		
		// restart button
		{
			UIButton *restartButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain]; 
			
			[restartButton setBackgroundImage:[UIImage imageNamed:@"Restart.png"] forState:UIControlStateNormal];
			
			[restartButton addTarget:self action:@selector(restartPushed:) 
				 forControlEvents:UIControlEventTouchUpInside];
			
			CGRect rect = CGRectMake(150-80,80+80,174,53);
			[restartButton setFrame:rect];
			
			[mPauseView addSubview:restartButton];
			
		}
		
		
		{
			UIButton *exitButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain]; 
			
			[exitButton setBackgroundImage:[UIImage imageNamed:@"ExitText2.png"] forState:UIControlStateNormal];
			
			[exitButton addTarget:self action:@selector(endOfGamePushed:) 
				 forControlEvents:UIControlEventTouchUpInside];
			
			CGRect rect = CGRectMake(72-80,146+80,112,52);
			[exitButton setFrame:rect];
			
			[mPauseView addSubview:exitButton];
			
		}
		
		
		{
			audioButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain]; 
			
			if([delegate isAudioOn])
			{
				[audioButton setBackgroundImage:[UIImage imageNamed:@"SoundOn.png"] forState:UIControlStateNormal];
			}
			else
			{
				[audioButton setBackgroundImage:[UIImage imageNamed:@"SoundOff.png"] forState:UIControlStateNormal];
			}
			
			[audioButton addTarget:self action:@selector(audioButtonPushed:) 
				 forControlEvents:UIControlEventTouchUpInside];
				
			CGRect rect = CGRectMake(60-16,276,32,32);
			[audioButton setFrame:rect];
			
			[mPauseView addSubview:audioButton];
			
		}
		
		{
			UIButton *helpButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain]; 
			
			[helpButton setBackgroundImage:[UIImage imageNamed:@"InstructionsText.png"] forState:UIControlStateNormal];
			
			[helpButton addTarget:self action:@selector(helpButtonPushed:) 
				 forControlEvents:UIControlEventTouchUpInside];
			
			CGRect rect = CGRectMake(150-80,207+80,160,64);
			[helpButton setFrame:rect];
			
			[mPauseView addSubview:helpButton];
			
		}
		
		[self animateIn:mPauseView];
	}
}

- (void)showEdit:(id)sender
{
    if (!self.editorViewController) 
    {
        self.editorViewController = [[EditorViewController alloc] initWithNibName:@"EditorViewController" bundle:nil];
        // Rotates the score view
        CGAffineTransform transform = self.editorViewController.view.transform; 
        transform = CGAffineTransformRotate(transform, M_PI/2.0);
        self.editorViewController.view.transform = transform;
        self.editorViewController.view.center = self.view.center;
        self.editorViewController.delegate = self;
    }
    
    [self.view addSubview:self.editorViewController.view];

}

// resumes gameplay
- (void)resumeLevel
{
	[gopherView resumeGame];
	
	[mPauseView removeFromSuperview];
	[mPauseView release];
	mPauseView = nil;
}

- (void) exitLevel
{
	[gopherView endLevel];
	[gopherView stopAnimation];		
	[delegate gopherViewControllerDidFinish:self withResult:@"Foo"];
}

- (void) restartLevel
{
	if(mEndOfGameView != nil)
	{
		[mEndOfGameView removeFromSuperview];
		[mEndOfGameView release];
		mEndOfGameView = nil;
	
	}
	if(mPauseView != nil)
	{
		[mPauseView removeFromSuperview];
		[mPauseView release];
		mPauseView = nil;
	}
	
	
	[gopherView reloadLevel];
	
}

- (UILabel *) makeScoreLabel
{
	int numGophers = [gopherView deadGophers];
    int numRemainingBalls = [gopherView remainingBalls];
    int numDestroyedObjects = [gopherView numDestroyedObjects];
	int currentScore =   numRemainingBalls * 100 + numGophers * 10 + numDestroyedObjects * 10;
	int currentHigh = [delegate getScore:[gopherView loadedLevel]];

	UILabel *highScoreLabel;
	
	if(currentHigh < currentScore)
	{
		DLog(@"New High Score");
		[delegate writeScore:currentScore forLevel:[gopherView loadedLevel]];
		int64_t gameScore=[delegate getGameScore];
		highScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(160-240/2- 32-46/2,240-160/2 + 80,360,102)];
		NSString *formatString = @"Gophers: %i x 10 = %i\nBalls: %i x 100 = %i\n"
            @"Destruction: %i x 10 = %i\nNew High Score: %i  Global High: %i";
		NSString *scoreString = [NSString stringWithFormat:formatString, numGophers, numGophers *10, 
                                 numRemainingBalls, numRemainingBalls*100,
                                 numDestroyedObjects, numDestroyedObjects*10,
                                 currentScore, gameScore];
		highScoreLabel.text = scoreString;
        //send score to game center
        [self.gameCenterManager reportScore:gameScore forCategory:kLeaderboardHighScore];    
    }
	else 
	{	
		highScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(160-240/2 - 32,240-160/2 + 80,314,96)];
		NSString *formatString = @"Gophers: %i x 10 = %i\nBalls: %i x 100 = %i\n"
                @"Destruction: %i x 10 = %i\nScore: %i";
		NSString *scoreString = [NSString stringWithFormat:formatString, numGophers, numGophers *10,
                                 numRemainingBalls, numRemainingBalls*100, 
                                 numDestroyedObjects, numDestroyedObjects*10,
                                 currentScore];
		highScoreLabel.text = scoreString;
	}
	
	highScoreLabel.textAlignment = UITextAlignmentCenter;
	highScoreLabel.numberOfLines = 4;
	highScoreLabel.backgroundColor = [UIColor clearColor];
	highScoreLabel.font = [UIFont fontWithName:@"Marker Felt" size:22.0f];
	highScoreLabel.textColor = [UIColor orangeColor];
	highScoreLabel.shadowColor = [UIColor blackColor];
	highScoreLabel.shadowOffset = CGSizeMake(2,2);	
	
	return highScoreLabel;
	
}

- (void) finishedLevel: (bool) playerWon
{

    if (playerWon) 
    {
        AudioDispatch::Instance()->PlaySound(AudioDispatch::Cheer);
    }
    else
    {
        AudioDispatch::Instance()->PlaySound(AudioDispatch::Lose);        
    }
    
	// add subview try gain or whatever
	if(mEndOfGameView == nil)
	{
	
		mEndOfGameView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
						  
		[gopherView addSubview:mEndOfGameView];
		
		// Rotates the score view
		CGAffineTransform transform = CGAffineTransformMakeRotation(3.14159/2);
		mEndOfGameView.transform = transform;
		
		// win/try again
		UIImageView *mainLabel;
		if(playerWon)
		{
			mainLabel  = [[UIImageView alloc] initWithFrame:CGRectMake(160-240/2,240-160/2 - 48 ,240,160)]; 
			[mainLabel setImage:[UIImage imageNamed:@"LevelCleared.png"]];
			[mEndOfGameView addSubview:mainLabel];
			[mainLabel release];
			
			UILabel *highScoreLabel = [self makeScoreLabel];			
			[mEndOfGameView addSubview:highScoreLabel];
			[highScoreLabel release];
			
			
			// replay option
			{
				// exit button
				UIButton *restartButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain]; 
				
				[restartButton setBackgroundImage:[UIImage imageNamed:@"Restart.png"] forState:UIControlStateNormal];
				
				[restartButton addTarget:self action:@selector(restartPushed:) 
						forControlEvents:UIControlEventTouchUpInside];
				
				CGRect rect = CGRectMake(240,332,128,64);
				[restartButton setFrame:rect];
				
				[mEndOfGameView addSubview:restartButton];
				
			}
			
			// exit option
			// TODO - get isLastLevel from delegate
			if((![delegate isLastLevel:levelName]) )
			{
				// exit button
				UIButton *exitButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain]; 
				
				[exitButton setBackgroundImage:[UIImage imageNamed:@"NextLevel.png"] forState:UIControlStateNormal];
				
				[exitButton addTarget:self action:@selector(nextLevelPushed:) 
					 forControlEvents:UIControlEventTouchUpInside];
				
				CGRect rect = CGRectMake(100,332,128,64);
				[exitButton setFrame:rect];
				
				[mEndOfGameView addSubview:exitButton];
				
			}
			
			// exit option
			{
				// exit button
				UIButton *exitButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain]; 
				
				[exitButton setBackgroundImage:[UIImage imageNamed:@"ExitText2.png"] forState:UIControlStateNormal];
				
				[exitButton addTarget:self action:@selector(endOfGamePushed:) 
					 forControlEvents:UIControlEventTouchUpInside];
				
				CGRect rect = CGRectMake(-20,332,128,64);
				[exitButton setFrame:rect];
				
				[mEndOfGameView addSubview:exitButton];
				
			}
			
			
		}
		else 
		{
			// replay option
			{
				// exit button
				UIButton *restartButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain]; 
				
				[restartButton setBackgroundImage:[UIImage imageNamed:@"TryAgain.png"] forState:UIControlStateNormal];
				
				[restartButton addTarget:self action:@selector(restartPushed:) 
						forControlEvents:UIControlEventTouchUpInside];
				
				CGRect rect = CGRectMake (252-80,280,160,64);
				[restartButton setFrame:rect];
				
				[mEndOfGameView addSubview:restartButton];
				
			}
			
			// exit option
			{
				// exit button
				UIButton *exitButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain]; 
				
				[exitButton setBackgroundImage:[UIImage imageNamed:@"ExitText2.png"] forState:UIControlStateNormal];
				
				[exitButton addTarget:self action:@selector(endOfGamePushed:) 
					 forControlEvents:UIControlEventTouchUpInside];
				
				CGRect rect = CGRectMake(72-80,280,128,64);
				[exitButton setFrame:rect];
				
				[mEndOfGameView addSubview:exitButton];
				
			}

			
		}

		
		[self animateIn:mEndOfGameView];
	}
}


// animate in landing view
- (void) animateIn:(UIView*) animView
{
	int x = animView.frame.origin.x;
	
	animView.frame = CGRectMake(-animView.frame.size.width, 
								animView.frame.origin.y, 
								animView.frame.size.width, 
								animView.frame.size.height);
	
	[UIView beginAnimations:@"GameViewAnimation" context:nil];
	animView.frame = CGRectMake(x, 
								   animView.frame.origin.y, 
								   animView.frame.size.width, 
								   animView.frame.size.height);
	[UIView commitAnimations];
}

#pragma mark ACTIONS


- (IBAction) resumePushed:(id)sender
{
	[self resumeLevel];
}

- (IBAction) endOfGamePushed:(id)sender
{
	[self exitLevel];
}

- (IBAction) nextLevelPushed:(id) sender
{
	
	if([delegate isLastLevel:levelName])
	{
		DLog(@"MASSIVE FAIL!");
	}
	else {
		[mEndOfGameView removeFromSuperview];
		[mEndOfGameView release];
		mEndOfGameView = nil;
		
		levelName = [delegate getNextLevelName:levelName];
		
		// load next level		
		[gopherView startAnimation];
		[gopherView loadLevel:levelName];
		
	}

	
}

- (IBAction) restartPushed:(id)sender
{
	[self restartLevel];
}

-(IBAction) audioButtonPushed:(id)sender
{
	[delegate setAudioOn: ![delegate isAudioOn]];
	
	if([delegate isAudioOn])
	{
		[audioButton setImage:[UIImage imageNamed:@"SoundOn.png"] forState:UIControlStateNormal];
		AudioDispatch::Instance()->SetAudioOn(true);
	}
	else
	{
		[audioButton setImage:[UIImage imageNamed:@"SoundOff.png"] forState:UIControlStateNormal];
		AudioDispatch::Instance()->SetAudioOn(false);
	}
}

-(IBAction) helpButtonPushed:(id)sender
{
	if(mInstructionsView == nil)
	{
		mInstructionsView = [[UIImageView alloc] initWithFrame:CGRectMake(-80, 80, 480, 320)];
		
		[gopherView addSubview:mInstructionsView];
		
		CGAffineTransform transform = CGAffineTransformMakeRotation(3.14159/2.0);
		mInstructionsView.transform = transform;
		
        UIImage *image = [UIImage imageWithContentsOfFile:
                          [[NSBundle mainBundle] pathForResource:@"Instructions1" ofType:@"png"]];
		mInstructionsView.image = image;
		
		{
			mInstructionsButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain]; 
			
			[mInstructionsButton setImage:[UIImage imageNamed:@"ArrowButtonGold32.png"] forState:UIControlStateNormal];
			
			[mInstructionsButton addTarget:self action:@selector(nextInstructionFramePressed:) 
				 forControlEvents:UIControlEventTouchUpInside];
			
			CGRect rect = CGRectMake(60,400,32,32);
			[mInstructionsButton setFrame:rect];
			
			mInstructionsButton.transform = transform;
			
			[gopherView addSubview:mInstructionsButton];
			mFrameIndex = 1;
			
		}
		
	}
}

#pragma mark SCORE

- (void) updateScore: (int) score withDead:(int) nDead andTotal:(int) total
{
	if(scoreLabel != nil)
	{
		scoreLabel.text = [NSString stringWithFormat: @"Gophers: %d/%d", nDead, total];
	}
}

- (void) updateScore: (int) score withDead:(int) nDead andTotal:(int) total andBallsLeft:(int) ballsLeft
{
	if(scoreLabel != nil)
	{
		scoreLabel.text = [NSString stringWithFormat: @"Balls: %d", ballsLeft];
	}
}


#pragma mark LOADUP
// for initializing during splash load up
// message the delegate that we're done
- (void)finishedLoadUp
{
	[gopherView pauseGame];
	[gopherView stopAnimation];
	[delegate gopherViewControllerDidFinish:self withResult:@"Splash"];
}

 
#pragma mark LOAD AND APPEAR

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
// called 1x in lifetime
- (void)viewDidLoad {
	[super viewDidLoad];
	 
	DLog(@"--> Gopher View Did Load");
	
	//gopherView.animationInterval = 1.0 / 60.0;
	
	if(![gopherView isEngineInitialized])
	{
		DLog(@"Init Engine");
		[gopherView initEngine];
	}
	[gopherView setGopherViewController:self];
	
}

- (void)initStuff 
{
	DLog(@"--> GViewC will appear");
	
	if(![levelName isEqualToString:@"Splash"])
	{
		AudioDispatch::Instance()->SetAudioOn([delegate isAudioOn]);
	}
	
	gopherView.animationInterval = 1.0 / 60.0;
	
	[gopherView startAnimation];
	[gopherView loadLevel:levelName];
	
	DLog(@"--> GViewC did appear");
	
	[[self view] setFrame:CGRectMake(0,0,320, 480)];
	
	if(mEndOfGameView != nil)
	{
		[mEndOfGameView removeFromSuperview];
		[mEndOfGameView release];
		mEndOfGameView = nil;
	}
	
	if(mInstructionsView != nil)
	{
		[mInstructionsView removeFromSuperview];
		[mInstructionsView release];
		mInstructionsView = nil;
		
	}
	
	[[UIApplication sharedApplication ] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];
	
	
	// add score overlay
	scoreView  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
	[gopherView addSubview:scoreView];

	// Rotates the score view
	CGAffineTransform transform = CGAffineTransformMakeRotation(3.14159/2);
	scoreView.transform = transform;
	
	// add score label
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10,0,256, 32)];
	label.text = @"Gophers: ";
	label.backgroundColor = [UIColor clearColor];
	label.font = [UIFont fontWithName:@"Marker Felt" size:17.0f];
	label.textColor = [UIColor orangeColor];
	label.shadowColor = [UIColor blackColor];
	label.shadowOffset = CGSizeMake(2,2);	
	
	{
		/// TODO - extract into fcn
		int score = GamePlayManager::Instance()->ComputeScore();
		int deadGophs = GamePlayManager::Instance()->GetDeadGophers(); 
		int totalGophs = GamePlayManager::Instance()->GetTotalGophers();
		int ballsLeft = GamePlayManager::Instance()->GetNumBallsLeft();
		

    // update score if it has changed
    [ self updateScore: score withDead:deadGophs andTotal: totalGophs andBallsLeft:ballsLeft];
			
	}
	
	scoreLabel = label;	
	[scoreView addSubview:label];
	
	
    UIButton *editButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain]; 	
	[editButton setImage:[UIImage imageNamed:@"Edit.png"] forState:UIControlStateNormal];
	[editButton addTarget:self action:@selector(showEdit:) forControlEvents:UIControlEventTouchUpInside];
    
	// this is a bit absurd
	// the frame stuff is done in world space
	CGRect editRect = CGRectMake( 10, 30, 32, 32);
	[editButton setFrame:editRect];
	[scoreView addSubview:editButton]; 
	
	// this is needed to keep the overlay from making this single touch
	[scoreView setMultipleTouchEnabled:YES];
}

-(void)shutdownStuff 
{
	DLog(@"--> Gopher View Ctlr will disappear");
		
	[scoreLabel release];
	scoreLabel = nil;
	
	[scoreView removeFromSuperview];
	[scoreView release];
	scoreView = nil;
	
	if(mPauseView != nil)
	{
		[mPauseView removeFromSuperview];
		[mPauseView release];
		mPauseView = nil;
	}
	
	if(mInstructionsView != nil)
	{
		
		[mInstructionsView removeFromSuperview];
		[mInstructionsView release];
		mInstructionsView = nil;
		
	}
	if(mInstructionsButton != nil)
	{
		
		[mInstructionsButton removeFromSuperview];
		mInstructionsButton = nil;
		
	}
	
	[[UIAccelerometer sharedAccelerometer] setDelegate:nil];
	
}



#pragma mark MUSIC

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
    [gameCenterManager_ release];
    [editorViewController_ release];
    [super dealloc];
  }


- (IBAction) nextInstructionFramePressed:(id)sender
{
	if(mInstructionsView == nil)
	{
		return;
	}
	else if (mFrameIndex == 1) {
        mInstructionsView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Instructions2" ofType:@"png"]];
        mFrameIndex++;
    } else {
        
        [mInstructionsView removeFromSuperview];
        [mInstructionsView release];
        mInstructionsView = nil;				
        
        [mInstructionsButton removeFromSuperview];
        mInstructionsButton = nil;
        
        [self resumeLevel];
        mFrameIndex = 1;
    }
}

@end
