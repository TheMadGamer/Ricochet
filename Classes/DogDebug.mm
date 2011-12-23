//
//  DogDebug.m
//  Grenades
//
//  Created by Anthony Lobay on 12/22/11.
//  Copyright (c) 2011 3dDogStudios.com. All rights reserved.
//

#import "DogDebug.h"

#import <Foundation/Foundation.h>
#include <stdarg.h>

//using namespace Dog3D;

NSDictionary *debugFlags;

void DLog(NSString *fmt, ...) 
{
#if DEBUG
    va_list args;
    va_start(args, fmt);
    
    NSLogv(fmt, args);
    
    va_end(args);
#endif
}

void DLog2(NSString *flag, NSString *fmt, ...) 
{
#if DEBUG
    if (!debugFlags) {
        NSString * path = [[NSBundle mainBundle] pathForResource:@"Debug" ofType:@"plist"];
        debugFlags = [[NSDictionary dictionaryWithContentsOfFile:path] retain];
    }
    
    if ([[debugFlags objectForKey:flag] boolValue]) 
    {    
        va_list args;
        va_start(args, fmt);
        
        NSLogv(fmt, args);
        
        va_end(args);
    }
#endif
}

