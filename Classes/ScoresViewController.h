//
//  ScoresViewController.h
//  Gopher
//
//  Created by Anthony Lobay on 8/9/10.
//  Copyright 2010 3dDogStudios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LevelsViewController.h"

@protocol ScoresViewDelegate

// reset 
- (void) resetPlayedLevels;

@end

@interface ScoresViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>  {
	NSArray *states_;
}

@property (nonatomic, assign) IBOutlet UITableView *tableView;
@property (nonatomic, assign) id <LevelsViewControllerDelegate, ScoresViewDelegate> delegate;
@property (nonatomic, retain) NSArray *states;

- (IBAction) goBack;
- (IBAction) resetScores;

@end
