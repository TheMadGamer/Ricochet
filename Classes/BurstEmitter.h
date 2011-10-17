//
//  BurstEmitter.h
//  Grenades
//
//  Created by Anthony Lobay on 10/6/11.
//  Copyright 2011 3dDogStudios.com. All rights reserved.
//

#ifndef Grenades_BurstEmitter_h
#define Grenades_BurstEmitter_h

#import "ParticleEmitter.h"

namespace Dog3D 
{
    class BurstEmitter : public Dog3D::ParticleEmitter {
        
    public:
        BurstEmitter(float attenuationRate) : ParticleEmitter(0, attenuationRate, @"leaf", true)
        {
            mTypeId = BURST;
            mVelocityMagnitude = 2;
        }
        
        void EmitBurst( int nParticles);
        
    };
}

#endif
