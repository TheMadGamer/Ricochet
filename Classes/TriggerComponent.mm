/*
 *  TriggerComponent.cpp
 *  Gopher
 *
 *  Created by Anthony Lobay on 4/8/11.
 *  Copyright 2011 3dDogStudios.com. All rights reserved.
 *
 */
#import "TriggerComponent.h"

#import "AudioDispatch.h"
#import "GraphicsComponent.h"

using namespace Dog3D;

void TriggerComponent::OnCollision( Entity *collidesWith)
{
	if(mGate != NULL && mCountdown <= 0)
	{
        HoldLastAnim *graphics = (HoldLastAnim *)mParent->GetGraphicsComponent();
        
        // trigger frog
        graphics->StartAnimation(AnimatedGraphicsComponent::IDLE);
        AudioDispatch::Instance()->PlaySound(2);
        
        mCountdown = kCountdown;
		mGate->Activate();
	}
}