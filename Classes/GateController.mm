/*
 *  GateControllerComponent.cpp
 *  Gopher
 *
 *  Created by Anthony Lobay on 4/8/11.
 *  Copyright 2011 3dDogStudios.com. All rights reserved.
 *
 */

#import "GateController.h"
#import "PhysicsComponent.h"

using namespace Dog3D;

void GateController::Activate()
{
    mTimer = 0;
    mState = !mState;
    
    // set physics hinge target direction
    PhysicsComponent *physicsComponent = GetParent()->GetPhysicsComponent();
    if(mFreeSpinner)
    {
        if(mState)
        {
            physicsComponent->EnableHingeMotor();
        }
        else
        {
            physicsComponent->DisableHingeMotor();
        }
    }
    else
    {
        physicsComponent->SetHingeDirection(mState);
    }
}