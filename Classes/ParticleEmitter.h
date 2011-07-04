//
//  ParticleEmitter.h
//  Grenades
//
//  Created by Anthony Lobay on 7/2/11.
//  Copyright 2011 3dDogStudios.com. All rights reserved.
//


#import "GraphicsComponent.h"

namespace Dog3D
{
    
    enum ParticleType { SMOKE, FUSE, FIRE, LEAF };
    
	class ParticleEmitter : public Component
	{
        public:
        ParticleEmitter(float rate, ParticleType p) : m_rate(rate), m_type(p){}
        
        virtual void Update(float deltaTime, bool show3D);
        
        float m_rate;
        ParticleType m_type;

    };
}