//
//  NSString+Extensions.m
//  GameBox
//
//  Created by Caleb Cannon on 2/26/10.
//  Copyright 2010 Caleb Cannon. All rights reserved.
//

#import "NSString+Extensions.h"


@implementation NSString (Extensions)


+ (NSString *) userDirectory
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *userDirectory = [paths objectAtIndex:0];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];

	BOOL exists, isDirectory;
	exists = [fileManager fileExistsAtPath:userDirectory isDirectory:&isDirectory];
	if (!exists || !isDirectory)
    {
		[fileManager createDirectoryAtPath:userDirectory 
               withIntermediateDirectories:YES 
                                attributes:nil
                                     error:nil];
	}
    
	return userDirectory;
}


+ (NSString *) levelsDirectory
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *userDirectory = [paths objectAtIndex:0];
    NSString *levelsDirectory = [userDirectory stringByAppendingString:@"/levels"];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
    
	BOOL exists, isDirectory;
	exists = [fileManager fileExistsAtPath:levelsDirectory isDirectory:&isDirectory];
	if (!exists || !isDirectory)
    {
		[fileManager createDirectoryAtPath:levelsDirectory 
               withIntermediateDirectories:YES 
                                attributes:nil
                                     error:nil];
	}
    
	return levelsDirectory;
}

+ (NSString *) pathForUserFile:(NSString *)filename
{
	return [[NSString userDirectory] stringByAppendingPathComponent:filename];
}

- (NSString *) stringByExpandingToBundleDirectory
{
    return [[NSBundle mainBundle] pathForResource:self ofType:nil];
}

- (NSString *) stringByExpandingToUserDirectory
{
	return [[NSString userDirectory] stringByAppendingPathComponent:self];
}

- (NSString *) stringByExpandingToLevelsDirectory
{
	return [[NSString levelsDirectory] stringByAppendingPathComponent:self];
}

- (NSArray *) allLevelFiles
{
    NSString *levelsDirectory = [NSString levelsDirectory];

    NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:levelsDirectory error:nil];
    NSArray *onlyPlist = 
        [dirContents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.plist'"]];
    return onlyPlist;
}

// Whitespace

- (bool)hasNonWhitespace 
{
    return ([[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]length] > 0);
    
}

@end
