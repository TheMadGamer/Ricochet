//
//  GopherEditProtocol.h
//  Grenades
//
//  Created by Anthony Lobay on 12/22/11.
//  Copyright (c) 2011 3dDogStudios.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GopherEditProtocol <NSObject>

- (void) startPotTool;
- (void) startHedgeTool;
- (void) endEdit;
- (void) saveLevel:(NSString *)fileName;

@end
