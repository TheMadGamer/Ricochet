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
        
        if( mSoundEffect == AudioDispatch::Boing1 )
        {
            AudioDispatch::Instance()->PlaySound(AudioDispatch::Boing1 + random() % 2);
        }
        else 
        {
            AudioDispatch::Instance()->PlaySound(mSoundEffect);
        }
        
        mCountdown = kCountdown;
		mGate->Activate();
	}
}