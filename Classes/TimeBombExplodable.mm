//
//  TimeBombExplodable.cpp
//  Grenades
//
//  Created by Anthony Lobay on 11/20/11.
//  Copyright (c) 2011 3dDogStudios.com. All rights reserved.
//

#import "TimeBombExplodable.h"

#import <vector>

#import "AudioDispatch.h"
#import "Entity.h"
#import "ExplodableComponent.h"
#import "GraphicsComponent.h"
#import "GraphicsManager.h"
#import "PhysicsManager.h"
#import "PhysicsComponent.h"
#import "SceneManager.h"

using namespace std;

namespace Dog3D
{
    // roller and ricochet ball
    void TimeBombExplodable::OnCollision( Entity *collidesWith )
    { 
        // not a goph, explode
        
        GopherController *controller = collidesWith != NULL ?  dynamic_cast<GopherController*>(collidesWith->GetController()) : NULL;
        
        // time bomb
        if(collidesWith == NULL)
        {
            Explode();
            
            // get fx component				
            vector<Component *> fxComponents;
            mParent->FindComponentsOfType(FX, fxComponents);
            
            // disable
            for(int i = 0; i < fxComponents.size(); i++)
            {
                FXGraphicsComponent *fxComponent = static_cast<FXGraphicsComponent*>( fxComponents[i] );
                fxComponent->mActive = false;
                
            }
            
            AudioDispatch::Instance()->PlaySound(AudioDispatch::Boom2);
            
            btVector3 position = mParent->GetPosition();
            
            if(mExplosionType != ELECTRO && mExplosionType != FREEZE && mExplosionType != FIRE)
            {
                GraphicsManager::Instance()->ShowFXElement(position, mExplosionType);
            }
            
            // remove the physics component
            PhysicsComponent *physicsComponent =  mParent->GetPhysicsComponent();
            if(physicsComponent)
            {
                // remove ball from world
                physicsComponent->GetRigidBody()->setLinearVelocity(btVector3(0,0,0));
                physicsComponent->GetRigidBody()->setAngularVelocity(btVector3(0,0,0));
                PhysicsManager::Instance()->MarkForRemoval(physicsComponent);
            }
            
            mParent->GetGraphicsComponent()->mActive = false;
            
            
        }
        else if (controller != NULL) {
            
            btVector3 position = mParent->GetPosition();
            
            if(mExplosionType != ELECTRO && mExplosionType != FREEZE && mExplosionType != FIRE)
            {
                GraphicsManager::Instance()->ShowFXElement(position, mExplosionType);
            }
            
            AudioDispatch::Instance()->PlaySound(AudioDispatch::Boom2);
        }
        
    }
}
