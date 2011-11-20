//
//  TimeBombExplodable.h
//  Grenades
//
//  Created by Anthony Lobay on 11/20/11.
//  Copyright (c) 2011 3dDogStudios.com. All rights reserved.
//

#import "ExplodableComponent.h"

namespace Dog3D 
{
	// Used as Ricochet time bomb
	class TimeBombExplodable : public ExplodableComponent
	{
	public:
		TimeBombExplodable( ExplosionType explosionType) : 
		ExplodableComponent(explosionType){}
		virtual void Activate() { mTimeBomb = true; }
		void OnCollision(Entity *collidesWith);
	};
}