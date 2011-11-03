//
//  InstructionsViewController.mm
//  Gopher
//
//  Created by Anthony Lobay on 5/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "InstructionsViewController.h"
#import "SceneManager.h"

using namespace Dog3D;

@implementation InstructionsViewController

@synthesize instructionView;
@synthesize delegate;
@synthesize levelToLoad;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	frameIndex = 1;	
}

- (void)viewWillAppear:(BOOL)animated
{
	if(![levelToLoad isEqualToString:@"Basics"])
	{
		NSString *path = [[NSBundle mainBundle] bundlePath];
		NSString *finalPath = [path stringByAppendingPathComponent:levelToLoad];
		NSDictionary *rootDictionary = [[NSDictionary dictionaryWithContentsOfFile:finalPath] retain];
		
		NSDictionary *controlDictionary = [[rootDictionary objectForKey:@"LevelControl"] retain];
		
		SceneManager::LevelControlInfo levelControl(controlDictionary);
		
		NSString* imageName = @"Instructions_Cannon.png";
		
		instructionView.image = [UIImage imageNamed:imageName];
		[controlDictionary release];
		[rootDictionary release];
	}
}

// show in landscap right
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

//- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event

- (IBAction) NextFrame:(id) sender;
{
    // Code for multi-plate instructions
	/*if([levelToLoad isEqualToString:@"Basics"])
	{
		if(frameIndex == 1 ) 
		{
			
			frameIndex++;
			
			NSString* imageName = @"Instructions_Goal.png";

			instructionView.image = [UIImage imageNamed:imageName];
			
		}
		else if(frameIndex == 2){
			
			NSString* imageName = @"Instructions_Tilt.png";
			
			
			instructionView.image = [UIImage imageNamed:imageName];
			frameIndex++;
		}
		else
		{
			
			[self.delegate instructionsViewControllerDidFinish:self withSelectedLevel:levelToLoad];
			frameIndex++;
		}
		
		
	}
	else 
	{
		[self.delegate instructionsViewControllerDidFinish:self withSelectedLevel:levelToLoad];
		
	}*/
    [self.delegate instructionsViewControllerDidFinish:self withSelectedLevel:levelToLoad];
}

- (void)dealloc {
    [super dealloc];
}

@end
