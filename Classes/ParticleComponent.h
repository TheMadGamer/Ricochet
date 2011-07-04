//
//  ParticleComponent.h
//  Grenades
//
//  Created by Anthony Lobay on 7/2/11.
//  Copyright 2011 3dDogStudios.com. All rights reserved.
//

#import "GraphicsComponent.h"

namespace Dog3D
{
    
    
	class ParticleComponent : public Component
	{
    public:
        ParticleComponent(btVector3 &vel) : m_velocity(vel){}
        
        virtual void Update(float deltaTime, bool show3D);
        
                        
        btVector3 m_velocity;
    };
}