

@protocol PreferencesViewControllerDelegate;

@interface PreferencesViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>  {
	id <PreferencesViewControllerDelegate> delegate;
	NSIndexPath *currentLevelIndexPath;
}

@property (nonatomic, assign) id <PreferencesViewControllerDelegate> delegate;
@property (nonatomic, retain) NSIndexPath *currentLevelIndexPath;

- (IBAction) goBack;

@end


@protocol PreferencesViewControllerDelegate

@property (nonatomic, retain) NSArray *levels;

- (void)preferencesViewControllerDidFinish:(PreferencesViewController *)controller withSelectedLevel:(NSString*)levelName  ;

// gets the high score
- (int) getScore:(NSString*)levelName;

- (bool) isLevelUnlockedFromName:(NSString *)currentLevelName;
- (bool) isBonusLevel:(NSString *)levelName;

@end

