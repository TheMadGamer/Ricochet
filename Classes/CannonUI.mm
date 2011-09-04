/*
 *  CannonUI.cpp
 *  Gopher
 *
 *  Created by Anthony Lobay on 5/27/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#include "CannonUI.h"
#include "CannonController.h"
#include "GamePlayManager.h"

using namespace std;
using namespace Dog3D;

void CannonUI::SetTouch(btVector3 touch)
{
	// test against 
	if(touch.getZ() < 0)
	{
		touch -= mButton->GetPosition();
		touch.setY(0);
		if(touch.length() < kFireRadius)
		{
			static_cast<CannonController*>(mCannon->GetController())->FireBall();
			DLog(@"Fire Ball");
		}
	}
	else 
	{
		
	}
}

bool CannonUI::StartSwipe(btVector3 &swipe)
{
	mSwipeStarted = false;
	
	// 10 is the boundary
	if(swipe.z() < 10)
	{
			return false;
	}
	else
	{
		//add in rotation offset mojo
		float cannonAngle = mCannon->GetYRotation( ) - mRotationOffset;
		
		float x = AngleToX(cannonAngle);
		
		if( fabs(x - swipe.x()) < 2.0f)
		{
			mSwipeStarted = true;
		}
		
		return mSwipeStarted;
	}
}


void CannonUI::MoveSwipe(btVector3 &swipe)
{
	// 10 is the boundary
	{
		float angle = XToAngle(swipe.x()) +  mRotationOffset;
		
		mCannon->SetYRotation( angle );
		
		btVector3 pos = mWheel->GetPosition();
		pos.setX(swipe.x());
		mWheel->SetPosition(pos);
	}
}

void CannonUI::ApplyRotation(float delta)
{
    float angle = mCannon->GetYRotation();
    angle += delta;
    mCannon->SetYRotation( angle );
}

void CannonUI::EndSwipe(btVector3 swipe)
{
	if(mSwipeStarted)
	{
		MoveSwipe(swipe);
	}
}

void CannonUI::CancelSwipe()
{
	float yRotation = mCannon->GetYRotation() - mRotationOffset;
	mCannon->SetYRotation( -mSwipeRotation + yRotation);
	mSwipeRotation = 0;
}