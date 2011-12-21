#import "Entity.h"
#import "ExplodableComponent.h"
#import "FireballExplodable.h"
#import "GraphicsComponent.h"
#import "GraphicsManager.h"
#import "PhysicsManager.h"
#import "PhysicsComponent.h"
#import "SceneManager.h"
#import "AudioDispatch.h"

#import <vector>

using namespace std;

namespace Dog3D
{
    // Flower pots use this
    void FireballExplodable::OnCollision( Entity *collidesWith )
    { 
        DLog(@"Fireball collision");
        if(mExplodeState == TIMED_EXPLODE)
        {
            DLog(@"Already exploding");
        }
        
        mExplodeState = TIMED_EXPLODE;
        
        // get fx component				
        vector<Component *> fxComponents;
        mParent->FindComponentsOfType(FX, fxComponents);
        
        // Disable this object's FX components (if any) 
        for(int i = 0; i < fxComponents.size(); i++)
        {
            FXGraphicsComponent *fxComponent = static_cast<FXGraphicsComponent*>( fxComponents[i] );
            fxComponent->mActive = false;
            
        }
        
        btVector3 position = mParent->GetPosition();
        
        // Light up a fireball
        if(mExplosionType != ELECTRO && mExplosionType != FREEZE && mExplosionType != FIRE)
        {
            GraphicsManager::Instance()->ShowFXElement(position, mExplosionType);
        }
        
        AudioDispatch::Instance()->PlaySound(AudioDispatch::Boom2);
        
        PhysicsComponent *physicsComponent =  mParent->GetPhysicsComponent();
        
        // remove ball from world
        physicsComponent->GetRigidBody()->setLinearVelocity(btVector3(0,0,0));
        physicsComponent->GetRigidBody()->setAngularVelocity(btVector3(0,0,0));
        physicsComponent->SetKinematic(true);
        
        // Not used as this slows things down too much
        // AddGhostCollider();
        
        // time out mechanism
        mFuseTime = 0.5f;
        
        mParent->GetGraphicsComponent()->mActive = false;
        
        // Notify GamePlay manager of a destroyed object
        GamePlayManager::Instance()->IncrementDestroyedObjects();
        
    }
    
    void FireballExplodable::AddGhostCollider() 
    {
        PhysicsComponent *physicsComponent =  mParent->GetPhysicsComponent();
        physicsComponent->SetGhostColliderShape(PhysicsManager::Instance()->GetSmallBlastGhost());
        
        PhysicsManager::Instance()->AddGhostCollider(physicsComponent->GetGhostCollider(), GRP_EXPLODABLE | GRP_BALL );
        
        GamePlayManager::Instance()->AddExplodable(this);
    }
    
}
