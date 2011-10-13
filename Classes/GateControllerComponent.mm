/*
 *  GateControllerComponent.cpp
 *  Gopher
 *
 *  Created by Anthony Lobay on 4/8/11.
 *  Copyright 2011 3dDogStudios.com. All rights reserved.
 *
 */

#import "GateControllerComponent.h"
#import "PhysicsComponent.h"

using namespace Dog3D;

void GateController::Activate()
{
    mTimer = 0;
    mState = !mState;
    
    // set physics hinge target

    PhysicsComponent *physicsComponent = GetParent()->GetPhysicsComponent();
    
    if (mState) 
    {
        physicsComponent->EnableHingeMotor();
    } else {
        physicsComponent->DisableHingeMotor();
    }
    
}
