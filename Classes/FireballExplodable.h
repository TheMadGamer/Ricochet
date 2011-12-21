//
//  FireballExplodable.h
//  Grenades
//
//  Created by Anthony Lobay on 12/20/11.
//  Copyright (c) 2011 3dDogStudios.com. All rights reserved.
//

#import <vector>
#import <string>
#import "ExplodableComponent.h"

namespace Dog3D 
{
    // object releases from kinematic state on explode 
    class FireballExplodable : public ExplodableComponent
    {
    public:
        FireballExplodable( ExplosionType explosionType) : 
        ExplodableComponent(explosionType){}
        
        void OnCollision(Entity *collidesWith);
        
        // Adds blast radius (ghost object) on this object.
        // With continuous collisions, this slows things down significantly.
        void AddGhostCollider();
    };
}