//
//  GenericsFactory.h
//  Grenades
//
//  Created by Anthony Lobay on 11/16/11.
//  Copyright (c) 2011 3dDogStudios.com. All rights reserved.
//
#import <btBulletDynamicsCommon.h>
#import "Entity.h"
#import "SceneManager.h"
#import "ExplodableComponent.h"
#import "GraphicsManager.h"

#include <vector>
#import <string>

class GateFactory {
public:
    static std::pair<Dog3D::Entity *, Dog3D::Entity *>BuildSpinnerGate( btVector3 &initialPosition, btVector3 &halfExtents, 
                                                                float yRotation, float restitution, 
                                                                NSString *gateTextureName, NSString *targetTextureName,
                                                                float graphicsScale, float triggerX, float triggerZ);

    static std::pair<Dog3D::Entity *,Dog3D::Entity *> BuildDrivenGate( btVector3 &initialPosition, btVector3 &halfExtents, 
                                                          float yRotation, float restitution,
                                                          NSString *gateTextureName, NSString *targetTextureName,
                                                                      float graphicsScale, float triggerX, float triggerZ);
    
    static Dog3D::Entity *BuildSpinner( btVector3 &initialPosition, btVector3 &halfExtents, 
                                       float yRotation, float restitution, NSString *textureName,
                                       float graphicsScale);
};