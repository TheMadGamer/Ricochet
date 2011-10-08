//
//  ParticleEmitter.h
//  Grenades
//
//  Created by Anthony Lobay on 9/1/11.
//  Copyright (c) 2011 3dDogStudios. All rights reserved.
//

#import <btBulletDynamicsCommon.h>

#import <map>
#import <list>

#import "GraphicsComponent.h"

namespace Dog3D
{
    enum ParticleType { SMOKE, FUSE, FIRE, LEAF };
    
    struct Particle
    {
        Particle() : position(btVector3(0,0,0)), velocity(btVector3(0,0,0)), attenuation(1.0){}
        btVector3 position;
        btVector3 velocity;
        float attenuation;
        
    };
    
    class ParticleEmitter : public GraphicsComponent
    {
    public:
        
        ParticleEmitter(float emitterRate) : 
        mEmitterRate(emitterRate),
        mDX(0.2), 
        mDZ(0.2), 
        mParticlesToEmit(0),
        nDrawVerts(4096)
        {
            mDrawVerts = new Vec3[nDrawVerts];
            mTexVerts = new Vec2[nDrawVerts];
            mColors = new Color[nDrawVerts];
        }
        
        virtual ~ParticleEmitter()
        {
            delete [] mDrawVerts;
            delete [] mTexVerts;
            delete [] mColors;
            
        }
        
        virtual void Update(float deltaTime);
       
        inline void SetRate(float rate) { mEmitterRate = rate;}
        
    protected:
        
        void Draw();
        
        virtual void UpdateSimulation(float dt);
        
        // list of point locations
        std::list<Particle*> mParticles;
        
        Vec3 *mDrawVerts;
        int nDrawVerts;
        Vec2 *mTexVerts;
        Color *mColors;
        
        // TODO - try colors
        
        // TODO add list of color attenuations
        float mEmitterRate;
        
        float mDX;
        float mDZ;
        
        float mParticlesToEmit;
        ParticleType m_type;
        
    };
    
}

