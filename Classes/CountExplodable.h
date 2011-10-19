/*
 *  Explodable.h
 *  Gopher
 *
 *  Created by Anthony Lobay on 2/24/10.
 *  Copyright 2010 3dDogStudios. All rights reserved.
 *
 */


#import <vector>
#import <string>
#import "Component.h"
#import "GraphicsComponent.h"

namespace Dog3D 
{
		
	// Explodes after n bumps 
	class CountExplodable : public ExplodableComponent
	{
	public:
		CountExplodable( ExplosionType explosionType, int maxBumps) : 
		ExplodableComponent(explosionType), mNBumps(0), mMaxBumps(maxBumps), mLastCollider(NULL) {
        mTimeBomb = false;
        }
		
        void Detonate();
		void OnCollision(Entity *collidesWith);
        int mNBumps;
        int mMaxBumps;
        Entity *mLastCollider;
    };
	
}