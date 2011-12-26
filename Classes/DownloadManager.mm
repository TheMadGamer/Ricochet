//
//  DownloadManager.mm
//  Grenades
//
//  Created by Anthony Lobay on 12/25/11.
//  Copyright (c) 2011 3dDogStudios.com. All rights reserved.
//

#import "DownloadManager.h"

#import "Parse/Parse.h"

#import "DogDebug.h"
#import "NotificationTags.h"
#import "NSString+Extensions.h"

using namespace Dog3D;

NSString *const kUserLevel = @"UserLevel";
NSString *const kLevelFile = @"LevelFile";
NSString *const kCreatedBy = @"CreatedBy";
NSString *const kAnonymousUser= @"Problem?";
NSString *const kLevelName = @"LevelName";

DownloadManager *DownloadManager::sInstance;

// Downloads all levels from server that we don't have.
// Sends an NSNotification upon successful download of a level.
void DownloadManager::UpdateLevels()
{
    // Query
    PFQuery *query = [PFQuery queryWithClassName:kUserLevel];
    [query whereKey:kCreatedBy equalTo:kAnonymousUser];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    if (!error) {
        // TODO - For each, check for file, if not, download
        // 
        for (PFObject *object in objects)
        {
            NSString *levelName = [object objectForKey:kLevelName];
            DLog2(@"DebugDownload", @"Found file on server: %@", levelName);
            
            if (levelName)
            {
                NSString *levelPath = [levelName stringByExpandingToLevelsDirectory];

                BOOL exists;
                exists = [[NSFileManager defaultManager] fileExistsAtPath:levelPath];
                if (!exists)
                {
                    DLog2(@"DebugDownload", @"File downloading: %@", levelName);
     
                    // Force download
                    PFFile *file = [object objectForKey:kLevelFile];
                    NSData *levelData = [file getData];
                    
                                    [levelData writeToFile:levelPath atomically:YES];
                }
                else
                {
                    DLog2(@"DebugDownload", @"File already exists: %@", levelName);
                }
            }
        }
     
        DLog2(@"DebugDownload", @"Successfully retrieved %d files.", objects.count);
    } else {
         // Log details of the failure
        DLog2(@"DebugDownload", @"Error: %@ %@", error, [error userInfo]);
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdatedLevels
                                                        object:nil];
    

    }];
}
