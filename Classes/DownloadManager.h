//
//  DownloadManager.h
//  Grenades
//
//  Created by Anthony Lobay on 12/25/11.
//  Copyright (c) 2011 3dDogStudios.com. All rights reserved.
//

// Download data type
extern NSString *const kUserLevel;
extern NSString *const kLevelFile;
extern NSString *const kCreatedBy;
extern NSString *const kAnonymousUser;
extern NSString *const kLevelName;

namespace Dog3D
{
    class DownloadManager 
    {
    public:
        static void Initialize() { sInstance = new DownloadManager(); }
        static DownloadManager *Instance(){ return sInstance; }	
        static void ShutDown() { delete sInstance;  sInstance = NULL; }
        
        DownloadManager() : mDownloading(false) {}
        
        // Downloads all levels from server that we don't have.
        // Sends an NSNotification upon successful download of a level.
        void UpdateLevels();
        
    private: 
        static DownloadManager *sInstance;
        
        bool mDownloading;
    };
}