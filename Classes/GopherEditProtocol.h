//
//  GopherEditProtocol.h
//  Grenades
//
//  Created by Anthony Lobay on 12/22/11.
//  Copyright (c) 2011 3dDogStudios.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <btBulletDynamicsCommon.h>

@protocol GopherEditProtocol <NSObject>

- (void) startPotTool;
- (void) startHedgeToolWithExtents:(btVector3)extents yRotation:(float)yRotation;
- (void) startGopherTool;
- (void) endEdit;
- (void) saveLevel:(NSString *)fileName;

@end
