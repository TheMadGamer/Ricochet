//
//  main.m
//  Gopher
//

//  Copyright 3dDogStudios 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Parse/Parse.h"

int main(int argc, char *argv[]) {

	[Parse setApplicationId:@"TCkm1x4OZCpBpb2fTKlxQ4OJlMRvJwI6NP3LmZue" 
                  clientKey:@"z0gppB5AVW0VmBCEqsfKnYWTeY3Oswb7KLl1VXFl"];
    
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	int retVal = UIApplicationMain(argc, argv, nil, nil);
	[pool release];
	return retVal;
}
