//
//  BurstEmitter.cpp
//  Grenades
//
//  Created by Anthony Lobay on 10/6/11.
//  Copyright 2011 3dDogStudios.com. All rights reserved.
//
#import "BurstEmitter.h"
#import "GraphicsManager.h"
using namespace Dog3D;
using namespace std;

void BurstEmitter::EmitBurst(int nParticles)
{
    int particlesToCreate = nParticles;
    while(particlesToCreate >= 1)
    {
        // create a particle
        Particle *p = new Particle();
        p->position = GetParent()->GetPosition();
        
        float theta = (float) random()/RAND_MAX * PI * 2.0f;
        float mag = (float)  random()/RAND_MAX * mVelocityMagnitude + mVelocityMagnitude; 
        
        p->velocity = btVector3(sin(theta) * mag ,0,cos(theta) * mag);
        
        mParticles.push_back(p);
        particlesToCreate -= 1.0f;
    }

}