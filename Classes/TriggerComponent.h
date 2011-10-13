/*
 *  TriggerComponent.h
 *
 *  Created by Anthony Lobay on 2/1/10.
 *  Copyright 2010 3dDogStudios. All rights reserved.
 *
 */

#import "Component.h"
#import "ExplodableComponent.h"
#import "PhysicsManager.h"
#import <vector>

namespace Dog3D
{
	
	// Collidable component
	class TriggerComponent : public ExplodableComponent
	{				
		
	public:
		
		TriggerComponent( Component *gate ) : mGate(gate), ExplodableComponent(BUMPER), mCountdown(0) {
      mExplodeState = PRIMED;
    }
    
    virtual void Update(float dt) { if( mCountdown > 0) mCountdown -= dt; }

		// trips a sensor
		virtual void OnCollision( Entity *collidesWith);
		
	protected:	
    float mCountdown;
		Component *mGate;
	};
	
	typedef std::vector<TriggerComponent*>::iterator  TriggerComponentIterator;
	
}