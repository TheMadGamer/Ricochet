//
//  PreferencesViewController.mm
//  Gopher
//
//  Created by Anthony Lobay on 5/22/10.
//  Copyright 2010 3dDogStudios. All rights reserved.
//

@class LevelsViewController;

@protocol LevelsViewControllerDelegate

@property (nonatomic, retain) NSArray *levels;

- (void)levelsViewControllerDidFinish:(LevelsViewController *)controller 
                    withSelectedLevel:(NSString*)levelName;

// gets the high score
- (int) getScore:(NSString*)levelName;
- (bool) isLevelUnlockedFromName:(NSString *)currentLevelName;
- (bool) isBonusLevel:(NSString *)levelName;

@end


@interface LevelsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>  

@property (nonatomic, assign) id <LevelsViewControllerDelegate> delegate;
@property (nonatomic, retain) NSIndexPath *currentLevelIndexPath;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, assign) BOOL isVisible;

- (IBAction) goBack;
- (IBAction)refreshLevels:(id)sender;

@end



