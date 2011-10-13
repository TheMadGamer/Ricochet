/*
 *  GateControllerComponent.h
 *  Gopher
 *
 *  Created by Anthony Lobay on 4/8/11.
 *  Copyright 2011 3dDogStudios.com. All rights reserved.
 *
 */

#import "Component.h"
#import "PhysicsManager.h"

#import <vector>

namespace Dog3D
{
	
	// Gate controller component
	class GateController : public Component
	{				
		
	public:
        
		GateController(float speed, float interval, float openAngle, float closedAngle) :
		mSpeed(speed),
		mInterval(interval),
		mTimer(0.0f),
		mOpenAngle(openAngle),
		mClosedAngle(closedAngle),
		mState(true)
		{}
        
		virtual void Activate();
		
	protected:
		
		float mSpeed;
		
		// how long this stays open
		float mInterval;
		
		float mTimer;
		
		float mOpenAngle;
		float mClosedAngle;
		
		// int open = true
		bool mState;
		
		
	};
    
}