/*
 *  GopherController.mm
 *  Gopher
 *
 *  Created by Anthony Lobay on 4/12/10.
 *  Copyright 2010 3dDogStudios. All rights reserved.
 *
 */

#import "GopherController.h"
#import "GraphicsComponent.h"
#import "GamePlayManager.h"
#import "ExplodableComponent.h"


#import <vector>
#import <algorithm>

#import "Entity.h"
#import "GraphicsManager.h"
#import "TargetComponent.h"


namespace Dog3D
{
	
	void GopherController::Spawn( const btVector3 &spawnPosition)
	{
		mParent->SetPosition(spawnPosition);
		
		mControllerState = SPAWN;
		
		static_cast<AnimatedGraphicsComponent *>(mParent->GetGraphicsComponent())
			->StartAnimation(AnimatedGraphicsComponent::JUMP_DOWN_HOLE, MIRROR_NONE,  false);
	}

	void GopherController::Idle()
	{
		DLog(@"Idle");

		mControllerState = IDLE;
		mPauseFrame = 30;
		
		static_cast<AnimatedGraphicsComponent*>(mParent->GetGraphicsComponent())->StartAnimation(AnimatedGraphicsComponent::IDLE);
	}
	
	/*void GopherController::Freeze()
	{
		
		DLog(@"Freeze");

		mPreviousState = mControllerState;
		mControllerState = FREEZE;
		mPauseFrame = 90;
		
		static_cast<AnimatedGraphicsComponent*>(mParent->GetGraphicsComponent())->StartAnimation(AnimatedGraphicsComponent::FREEZE);
		
	}*/
	
	void GopherController::Electro()
	{
		
		DLog(@"Electro");
		
		mPreviousState = mControllerState;
		mControllerState = ELECTRO;
		mPauseFrame = 90;
		
		dynamic_cast<AnimatedGraphicsComponent*>(mParent->GetGraphicsComponent())->StartAnimation(AnimatedGraphicsComponent::ELECTRO);
		
	}
	
	
	void GopherController::Fire()
	{
		DLog(@"FIRE-");
		mPreviousState = mControllerState;
		mControllerState = FIRE;
		mPauseFrame = 45;
		
		AnimationMirroring mirror = (rand() %2) ? MIRROR_HORIZONTAL : MIRROR_NONE;
		
		static_cast<AnimatedGraphicsComponent*>(mParent->GetGraphicsComponent())->StartAnimation(
										AnimatedGraphicsComponent::FIRE, mirror);
	}
	
	void GopherController::Taunt()
	{
		DLog(@"Taunt");
		mPreviousState = mControllerState;
		mControllerState = TAUNT;
		mPauseFrame = 121;
		
		// note hard coded taunt time
		SetRandomTauntDelay();
		
		static_cast<AnimatedGraphicsComponent*>(
			mParent->GetGraphicsComponent())->StartAnimation(
			AnimatedGraphicsComponent::TAUNT,  (rand() %2) == 1 ? MIRROR_NONE : MIRROR_HORIZONTAL);

	}
	
	void GopherController::Eat()
	{
		DLog(@"Eat");
		
		mControllerState = EAT;
		mPauseFrame = 119;
		
		GamePlayManager::Instance()->RemoveCarrotLife();
		
		static_cast<AnimatedGraphicsComponent*>(mParent->GetGraphicsComponent())->StartAnimation(AnimatedGraphicsComponent::EAT_CARROT);
		
		
	}
	
	void GopherController::JumpDown()
	{
		mControllerState = JUMP_DOWN;
		mPauseFrame = 30;
		
		// keep active target
		// do not deactivate holes
		
		// cache where we started jumping from
		mStartMotionPosition = mParent->GetPosition();
		
		// kick off jump down anim
		static_cast<AnimatedGraphicsComponent*>(
					mParent->GetGraphicsComponent())->StartAnimation(AnimatedGraphicsComponent::JUMP_DOWN_HOLE);
		
	}
	
	void GopherController::OnCollision(Entity *collidesWith)
	{
		if(!CanExplode())
		{
			return;
		}
		
		btVector3 direction = mParent->GetPosition() - collidesWith->GetPosition();
		direction.setY(0);
		direction.normalize();
		
		// explode w/ object
		ExplodableComponent *explodable = collidesWith->GetExplodable();
		
		if(explodable)
		{
			switch (explodable->GetExplosionType()) {

				case ExplodableComponent::ELECTRO:
					if(CanReact())
					{
						Electro();
					}
					break;
				case ExplodableComponent::FREEZE:
					if(CanReact())
					{
						//Freeze();
					}
					break;
				case ExplodableComponent::FIRE:
					if(CanReact())
					{
						Fire();
					}
					break;
				case ExplodableComponent::MUSHROOM:
				case ExplodableComponent::EXPLODE_SMALL:
				default:
					Explode(direction);
					break;
			}
		}
		else 
		{
			// hits another gopher
			Component *controller = collidesWith->GetController(); 
			if(controller)
			{
				GopherController *gc = dynamic_cast<GopherController*> (controller);
				ControllerState state = gc->GetControllerState();
				
				if(state == EXPLODE || CanReact())
				{
					
					switch (state) {
						case FIRE:
							if(CanReact())
							{
								Fire();
							}
							break;
						case FREEZE:
							if(CanReact())
							{
								//Freeze();
							}
							break;
						case ELECTRO:
							Electro();
							break;
						case EXPLODE:
						default:
							Explode(direction);
							break;
					}
				}
				
			}
			else
			{
			
				Explode(direction);
			}
		}
		
		
	}
	
	// triggers initial explosion
	void GopherController::Explode(btVector3 &direction)
	{
		mControllerState = EXPLODE;
		
		btVector3 zero(0,0,0);
		
		mExplodeTime = 0;
		
		mTetheredHole = NULL;
		
		// go pinball
		// move object up
		
		PhysicsComponent *physicsComponent =  mParent->GetPhysicsComponent();

		
		btRigidBody *body = physicsComponent->GetRigidBody();
		
		btVector3 pos = mParent->GetPosition();
		pos.setY(1.0);
		mParent->SetPosition(pos);

		
		btTransform trans;
		trans.setIdentity();
		trans.setOrigin(pos);
		
		//rotate off parent
		//trans.setBasis(mParent->GetRotation());
		
		body->getMotionState()->setWorldTransform(trans);
		body->setWorldTransform(trans);
		
		physicsComponent->SetKinematic(false);
		
		// apply a force
		//velocity.setY(1.0f);
		direction *= 100.0f;
		body->applyForce(direction, zero);
		
		AnimatedGraphicsComponent *graphicsComponent = static_cast<AnimatedGraphicsComponent *> ( mParent->GetGraphicsComponent() );					
		
		// queue blow up anims
		if(fabs(direction.getX()) < fabs(direction.getZ()))
		{					
			AnimationMirroring mirror =  (direction.getZ() > 0)? MIRROR_HORIZONTAL : MIRROR_NONE;
			graphicsComponent->PlayAnimation(AnimatedGraphicsComponent::BLOWUP_LEFT, mirror);				
		}
		else 
		{
			AnimationMirroring mirror =  (direction.getX() > 0)? MIRROR_VERTICAL : MIRROR_NONE;
			graphicsComponent->PlayAnimation(AnimatedGraphicsComponent::BLOWUP_FORWARD , mirror);
		}
	}
	
	void GopherController::WinDance()
	{
		mPauseFrame = 0;
		
		// keeps things eating
		if(mControllerState == EAT)
		{
			AnimatedGraphicsComponent *graphicsComponent = static_cast<AnimatedGraphicsComponent*>(mParent->GetGraphicsComponent());
			
			if(graphicsComponent->LastFrame())
			{
				graphicsComponent->PlayAnimation(AnimatedGraphicsComponent::WIN_DANCE);
				mControllerState = WIN_DANCE;
			}
			else 
			{
				mControllerState = EAT_FINAL;
			}				
		}
		else 
		{
			DLog(@"Win Dance");	
			mControllerState = WIN_DANCE;
			PlayWinAnimation();
		}
	}
	
	void GopherController::Update(float dt)
	{
		if(mControllerState == EXPLODE )
		{
			UpdateExplode(dt);
		}
		else if(mControllerState == FREEZE)
		{
			if(mPauseFrame == 0)
			{
				mPauseFrame = 10;
				Idle();
			}
		}
		else if(mControllerState == ELECTRO || mControllerState == FIRE)
		{
			if(mPauseFrame == 0)
			{
				mControllerState = DEAD;
				// let game play mgr clean up
			}
		}
		else if(mControllerState == IDLE) 
		{
			UpdateIdle(dt);
		}
		else if(mControllerState == JUMP_DOWN)
		{
			UpdateJumpDown(dt);
		}
		else if(mControllerState == EAT)
		{
			UpdateEat(dt);
		}
		else if(mControllerState == EAT_FINAL)
		{
			mControllerState = WIN_DANCE;
		}
		else if(mControllerState == SPAWN)
		{
			UpdateSpawn( dt);
			
		}
		else if(mControllerState == TAUNT)
		{
		
			UpdateTaunt( dt);
		}
		
		if(mControllerState == WIN_DANCE)
		{
			// pick random moon or win dance
			PlayWinAnimation();
		}

		
		if(mPauseFrame > 0 )
		{
		   if(mIntraFrameTime >= (1.0/30.0))
		   {
			   mPauseFrame--;
			   mIntraFrameTime = 0;
		   }
		   else 
		   {
			   mIntraFrameTime += dt;   
		   }
		}
	}
	
	void GopherController::UpdateTaunt(float dt)
	{
		// if done taunting
		if(mPauseFrame ==0)
		{
			
				Idle();
			
		}
	}
	
	void GopherController::UpdateExplode(float dt)
	{
		// let physics control
		//btVector3 position = mParent->GetPosition();
		//DLog(@"Goph Expl %f %f %f", position.x(), position.y(), position.z());
		
		// character gets deactivated, respawnned, no transition out
		mExplodeTime += dt;
	
		PhysicsComponent *physics = mParent->GetPhysicsComponent();
		
		btVector3 linearVel = physics->GetRigidBody()->getLinearVelocity();

		const float kMinVel = 25.0f;
		const float kMaxVel = 40.0f;
		float vel = linearVel.length();
	
		if(vel > 0)
		{
			if(vel > kMaxVel)
			{
				linearVel.normalize();
				linearVel *= kMaxVel;
			}
			else if (vel < kMinVel)
			{
				linearVel.normalize();
				linearVel *= kMinVel;
			}
		}
	}
	
	void GopherController::UpdateSpawn(float dt)
	{
		// TODO - update the controller's spawn in 
		btVector3 position = mParent->GetPosition();
		
		// moves the gopher off the hole (up/down)
		float dX = position.getX() > 0 ? -0.006f : 0.006f; 
		position.setX(position.getX() + dX);					
		
		mParent->SetPosition(position);	
		
		// at end of animation, transition to Idle
		if(static_cast<AnimatedGraphicsComponent *>(mParent->GetGraphicsComponent())->LastFrame())
		{
			Idle();	
		}
	}
	
	void GopherController::UpdateEat(float dt)
	{
		// if not paused, and can get an active target, transition to attack
		if(mPauseFrame == 0 )
		{
			
			// node should be inactive, and not selectable
      Idle();
			
		}
		else if(GamePlayManager::Instance()->GetNumActiveTargets() == 0 && mPauseFrame == 0)
		{
			WinDance();
		}
	}
	
	void GopherController::UpdateJumpDown(float dt)
	{
		btVector3 position = mParent->GetPosition();
		
		float x = position.getX();
		
		if(x > 0)
		{
			position.setX(x+0.016f);
		}
		else {
			position.setX(x-0.020f);
		}

		
		mParent->SetPosition(position);
		
		if(mPauseFrame == 0)
		{
			// was a deactivate - let game mgr reclaim
			mControllerState = DEAD;
			mSpawnTime = kRespawnWait;
		}
		
		// TODO - move gopher towards hole
	}
	
	void GopherController::UpdateIdle(float dt)
	{
		// if not paused, and can get an active target, transition to attack
		if( mPauseFrame == 0 )
		{

				Taunt();
		}
	}
			
	void GopherController::PlayWinAnimation()
	{
		AnimatedGraphicsComponent *graphicsComponent = static_cast<AnimatedGraphicsComponent*>(mParent->GetGraphicsComponent());		
		
		if(graphicsComponent->LastFrame())
		{
			int randomNumber = rand();
			//DLog(@"Rand %d", randomNumber);
			
			if( (randomNumber % 3) == 1)
			{
				graphicsComponent->PlayAnimation(AnimatedGraphicsComponent::TAUNT);
				//DLog(@"Play taunt");
			}
			else 
			{
				graphicsComponent->PlayAnimation(AnimatedGraphicsComponent::WIN_DANCE);
				//DLog(@"Play win");
			}
		}
	}
			
			
	
}