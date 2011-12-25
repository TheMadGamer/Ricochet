//
//  NSString+Extensions.h
//  GameBox
//
//  Created by Caleb Cannon on 2/26/10.
//  Copyright 2010 Caleb Cannon. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NSString (Extensions)

+ (NSString *) userDirectory;

// Where levels are stored
+ (NSString *) levelsDirectory;

+ (NSString *) pathForUserFile:(NSString *)filename;
- (NSString *) stringByExpandingToUserDirectory;

- (NSString *) stringByExpandingToLevelsDirectory;

// All files of type plist in /levels
- (NSArray *) allLevelFiles;

- (bool)hasNonWhitespace;

@end
