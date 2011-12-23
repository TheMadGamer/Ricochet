//
//  DogDebug.h
//  Grenades
//
//  Created by Anthony Lobay on 12/22/11.
//  Copyright (c) 2011 3dDogStudios.com. All rights reserved.
//

// Our own debug

#import <Foundation/Foundation.h>

//namespace Dog3D {

    extern NSDictionary *debugFlags;
    /*
    #if DEBUG

    #define DLog  NSLog

    #else

    #define DLog  if(false) NSLog 

    #endif*/

    void DLog(NSString *fmt, ...);
    void DLog2(NSString *flag, NSString *fmt, ...);

//}
