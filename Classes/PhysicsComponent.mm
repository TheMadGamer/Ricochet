/*
 *  PhysicsComponent.cpp
 *  Gopher
 *
 *  Created by Anthony Lobay on 1/22/10.
 *  Copyright 2010 3dDogStudios. All rights reserved.
 *
 */

#import "Entity.h"
#import "PhysicsComponent.h"
#import "PhysicsManager.h"

namespace Dog3D
{
	
	void PhysicsComponent::Update(float deltaTime)
	{
		if(mKinematic)
		{
			btTransform trans;
			trans.setIdentity();
			trans.setOrigin(mParent->GetPosition());
			
			//rotate off parent
			trans.setBasis(mParent->GetRotation());
            
			mRigidBody->getMotionState()->setWorldTransform(trans);
			
			mRigidBody->setWorldTransform(trans);
			
		}
        else if(mHinge)
        {
            
            btTransform trans;
            mRigidBody->getMotionState()->getWorldTransform(trans);
			
            btVector3 pos = trans.getOrigin();
            
			mParent->SetPosition(pos);
            
            btQuaternion q;
            trans.getBasis().getRotation(q);
			
            
            if(q.getAxis().y() < 0)
            {
                mParent->SetYRotation(-q.getAngle());
            }
            else
            {
                mParent->SetYRotation(q.getAngle());
            }
            
        }
		else 
		{
			
			
			btTransform trans;
			trans.setIdentity();
			mRigidBody->getMotionState()->getWorldTransform(trans);
			
			btVector3 position = trans.getOrigin();
			mParent->SetPosition(position);
			
			btMatrix3x3 basis = trans.getBasis();
			mParent->SetRotation(basis);
		}
		
	}
	
	void PhysicsComponent::AddGhostCollider( )
	{
		if(mRigidBody)
		{
			if(!mGhostCollider)
			{
				mGhostCollider = new btPairCachingGhostObject();
			}
			mGhostCollider->setCollisionShape( /* 2 new btSphereShape(4)*/  mRigidBody->getCollisionShape() );
			
			
			btTransform trans; //  = mRigidBody->getWorldTransform();  // 3 trans;
			trans.setIdentity();
			trans.setOrigin(btVector3(mParent->GetPosition().getX(), 1,mParent->GetPosition().getZ() )); //mParent->GetPosition().getX(),1,mParent->GetPosition().getZ()));
			mGhostCollider->setCollisionFlags(mGhostCollider->getCollisionFlags() | btCollisionObject::CF_NO_CONTACT_RESPONSE);
            
			mGhostCollider->setWorldTransform(trans);
			mGhostCollider->setUserPointer(this);
		}
		else {
			DLog(@"Ghost collider WTF");
		}
        
	}
	
	void PhysicsComponent::SetGhostColliderShape( btCollisionShape *shape )
	{
		
#if DEBUG
		DLog(@"Change Ghost Collider %s ", mParent->mDebugName.c_str());
#endif
		
		if(!mGhostCollider)
		{
			mGhostCollider = new btPairCachingGhostObject();
		}
		
		mGhostCollider->setCollisionShape( shape );
		btTransform trans; 
		trans.setIdentity();
		trans.setOrigin(btVector3(mParent->GetPosition().getX(), 1, mParent->GetPosition().getZ()));
		mGhostCollider->setCollisionFlags(mGhostCollider->getCollisionFlags() | btCollisionObject::CF_NO_CONTACT_RESPONSE);
		
		mGhostCollider->setWorldTransform(trans);
		mGhostCollider->setUserPointer(this);
		
	}
	
	void PhysicsComponent::SetKinematic(bool kinematic)
	{ 
		if(mKinematic == kinematic)
		{
			return;
		}
        
		mKinematic = kinematic;	
		
		bool removeAndAdd = (mRigidBody->isInWorld());
		
		if(removeAndAdd)
		{
			PhysicsManager::Instance()->RemoveComponent(this);
		}
        
		if(kinematic)
		{
			mRigidBody->setCollisionFlags( mRigidBody->getCollisionFlags() | btCollisionObject::CF_KINEMATIC_OBJECT);
			mRigidBody->setActivationState( DISABLE_DEACTIVATION );
		}
		else 
		{
			// flip off kinematic flags
			mRigidBody->setCollisionFlags(  mRigidBody->getCollisionFlags() & ~btCollisionObject::CF_KINEMATIC_OBJECT);
			mRigidBody->setActivationState( WANTS_DEACTIVATION );
		}
        
		if(removeAndAdd)
		{
			PhysicsManager::Instance()->AddComponent(this);
		}
		
	}
    
    void PhysicsComponent::AddHingeMotor()
    {
        
        PhysicsComponent *ground = PhysicsManager::Instance()->GetGround();
        
        mHinge = new btHingeConstraint(* mRigidBody, *ground->GetRigidBody(),   btVector3(0 /*1.5*/,1,0), mParent->GetPosition() ,
                                       btVector3(0,1,0), btVector3(0,1,0), true);
        
        
        
        mRigidBody->setActivationState( DISABLE_DEACTIVATION );
        
        //mHinge->setLimit( 0, 3.14/2.0);
        mHinge->enableAngularMotor(true, 1.0f, 100.0f);
        
        PhysicsManager::Instance()->AddConstraint(mHinge);
        
    }
    
    void PhysicsComponent::AddHingeMotorWithTarget(float targetAngle)
    {
        PhysicsComponent *ground = PhysicsManager::Instance()->GetGround();
        
        mHinge = new btHingeConstraint(* mRigidBody, *ground->GetRigidBody(),   btVector3(0 /*1.5*/,1,0), mParent->GetPosition() ,
                                       btVector3(0,1,0), btVector3(0,1,0), true);
        
        
        mRigidBody->setActivationState( DISABLE_DEACTIVATION );
        
        mHinge->setLimit( 0, targetAngle);
        mHinge->enableAngularMotor(true, 1.0f, 100.0f);
        
        PhysicsManager::Instance()->AddConstraint(mHinge);
        
    }
    
    void PhysicsComponent::EnableHingeMotor()
    {
        PhysicsManager::Instance()->RemoveConstraint(mHinge);
        mHinge->enableAngularMotor(true, 1.0f, 100.0f);
        PhysicsManager::Instance()->AddConstraint(mHinge);
    }

    void PhysicsComponent::DisableHingeMotor()
    {
        PhysicsManager::Instance()->RemoveConstraint(mHinge);
        mHinge->enableAngularMotor(true, 0.0f, 100.0f);
        PhysicsManager::Instance()->AddConstraint(mHinge);
    }
    
    void PhysicsComponent::SetHingeDirection(bool positive)
    {
        PhysicsManager::Instance()->RemoveConstraint(mHinge);
        mHinge->enableAngularMotor(true, positive ? 1.0f : -1.0f, 100.0f);
        PhysicsManager::Instance()->AddConstraint(mHinge);
    }
}

