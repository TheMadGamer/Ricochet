//
//  AnimatedGraphicsComponent.mm
//  Grenades
//
//  Created by Anthony Lobay on 12/23/11.
//  Copyright (c) 2011 3dDogStudios.com. All rights reserved.
//

#import <cstdlib>
#import <OpenGLES/ES1/gl.h>

#import <map>

#import "VectorMath.h"
#import "GraphicsComponent.h"
#import "GraphicsManager.h"
#import "Entity.h"
#import "GamePlayManager.h"

using namespace Dog3D;
using namespace std;

AnimatedGraphicsComponent::~AnimatedGraphicsComponent()
{
	if(mBigVertices)
	{
		delete [] mBigVertices;
		mBigVertices = NULL;
	}
	
	if(mVertices)
	{
		delete [] mVertices;
		mVertices = NULL;
	}
	
	if(mNormals)
	{
		delete [] mNormals;
		mNormals = NULL;
	}	
	
	if(mTexCoords)
	{
		delete [] mTexCoords;
		mTexCoords = NULL;
	}
	
	if(mColors)
	{
		delete [] mColors;
		mColors = NULL;
 	}
	
	for(map<int, SpriteAnimation*>::iterator it = mAnimations.begin(); it != mAnimations.end(); it++)
	{
		delete it->second;
	}
	
	mAnimations.clear();
	
}

void AnimatedGraphicsComponent::AddAnimation(SpriteAnimation *animation, int ID)
{
	mAnimations[ID] = animation;
}

void AnimatedGraphicsComponent::StartAnimation(GopherAnims ID, AnimationMirroring mirror, int startFrame )
{
	//DLog(@"Play Anim %d", ID);
	mActiveAnimationID = ID;
	mPlayForward = true;
	mFrameTime = 0;
	
	mAnimations[ID]->mTileIndex = startFrame;
	
	mMirrorAnimation = mirror;
	
}

void AnimatedGraphicsComponent::StartAnimation(GopherAnims ID, AnimationMirroring mirror, bool playForward )
{
	//DLog(@"Play Anim %d", ID);
	mActiveAnimationID = ID;
	mPlayForward = playForward;
	mFrameTime = 0;
	
	mAnimations[ID]->mTileIndex = (playForward) ? 0 : ( mAnimations[ID]->mTileCount -1);
	
	mMirrorAnimation = mirror;
}

void AnimatedGraphicsComponent::PlayAnimation(GopherAnims ID, AnimationMirroring mirror, bool playForward )
{
	if(mActiveAnimationID != ID)
	{
		StartAnimation(ID, mirror, playForward);
	}
}

void AnimatedGraphicsComponent::StepAnimation(SpriteAnimation *activeAnimation, float deltaTime)
{
	// update anim frames (in case this anim is not drawn)
	if(mFrameTime >= activeAnimation->mFrameDuration)
	{
		mFrameTime = 0;
		
		if(!activeAnimation->mLoopAnimation)
		{
			if(mPlayForward && ( activeAnimation->mTileIndex < (activeAnimation->mTileCount-1)))
			{
				activeAnimation->mTileIndex++;
			}
			else if((!mPlayForward) && activeAnimation->mTileIndex > 0)
			{
				activeAnimation->mTileIndex--;
			}
		}
		else 
		{
			// next tile
			if(mPlayForward)
			{
				activeAnimation->mTileIndex++;
			}
			else 
			{
				activeAnimation->mTileIndex--;
			}
			
			activeAnimation->mTileIndex %= activeAnimation->mTileCount;
		}
	}
	else
	{
		mFrameTime += deltaTime;
	}
}

// plays animated walk
// if direction length == 0, idles
void AnimatedGraphicsComponent::UpdateAnimatedWalkDirection( btVector3 &direction)
{
	if( direction.length() == 0)
	{
		PlayAnimation(IDLE, MIRROR_NONE);
		return;
	}
	
	if( direction.x() > cos(PI/8.0))
	{
		PlayAnimation(WALK_FORWARD);
	}
	else if( direction.x() > cos(3.0*PI/8.0))
	{
		PlayAnimation(WALK_FORWARD_LEFT);		
	}
	
	else if( direction.x() > cos(5.0*PI/8.0))
	{
		PlayAnimation(WALK_LEFT);
	}
	
	else if( direction.x() > cos(7.0*PI/8.0))
	{
		PlayAnimation(WALK_BACK_LEFT);
	}
	
	else 
	{
		PlayAnimation(WALK_BACK);
	}
	
	mMirrorAnimation = (direction.z() > 0.0) ? MIRROR_HORIZONTAL : MIRROR_NONE;
}

void AnimatedGraphicsComponent::Update( float deltaTime )
{
	if(! mParent->mActive || !mActive)
	{
		return;
	}
	
	// TEXTURE
	// get active sprite sheet
	SpriteAnimation *activeAnimation = mAnimations[mActiveAnimationID];
	
	StepAnimation(activeAnimation, deltaTime);
	
	btVector3 direction;
	
	GamePlayManager::Instance()->GetFocalPoint(direction);
	direction *= -1.0f;
	direction += mParent->GetPosition();
	direction += mOffset;
	
	
	// off screen, do not draw
	if( ( (direction.x() - 2.0f*mScale.x()) > 10.0f) || 
	   ( (direction.x() + 2.0f*mScale.x()) < -10.0f) ||
	   ( (direction.z() - 2.0f*mScale.z()) > 15.0f) ||
	   ( (direction.z() + 2.0f*mScale.z()) < -15.0f)	)
	{
		return;		
	}
	
	glEnableClientState(GL_VERTEX_ARRAY);
	
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); 
	glDisable(GL_DEPTH_TEST);
	
	btVector3 position = mParent->GetPosition();
	glPushMatrix();
	{
		// POSITION 				
		glTranslatef(position.getX(), position.getY(), position.getZ());
        
		
		if( (!mIgnoreParentRotation) && mParent->IsRotationSet())
		{
			/*const btMatrix3x3 &matrix = mParent->GetRotation();
             
             glMatrixMode(GL_MODELVIEW);
             
             btScalar m[16];
             
             matrix.getOpenGLSubMatrix(m);
             m[12] = 0;
             m[13] = 0;
             m[14] = 0;
             m[15] = 1;
             glMultMatrixf(m);*/
			
			// sprites only use y rotation
			glRotatef(mParent->GetYRotation()* 180.0/M_PI, 0, 1, 0);
			
		}
		
		if(!(mOffset.x() == 0 && mOffset.y() == 0 && mOffset.z() ==0))
		{
			glTranslatef(mOffset.x(), mOffset.y(), mOffset.z());
		}
		
		// MATERIAL
		SetupMaterials();
		
		
		Texture2D *texture = activeAnimation->mSpriteSheet;
		[texture enable];
        
		float s = activeAnimation->getS();
		float t = activeAnimation->getT();		
		
		float dS = s+ activeAnimation->getDS();
		float dT = t+ activeAnimation->getDT();
		
		
        GLfloat	coordinates[] = 
        {
            s, t,
            s, dT,
            dS, t,
            dS, dT
            
        };
		
		if(mMirrorAnimation & MIRROR_HORIZONTAL)
		{
			coordinates[0] = dS;
			coordinates[2] = dS;
			coordinates[4] = s;
			coordinates[6] = s;
		}
		
		if(mMirrorAnimation & MIRROR_VERTICAL)
		{
			coordinates[1] = dT;
			coordinates[3] = t;
			coordinates[5] = dT;
			coordinates[7] = t;
		}
        
		
		glTexCoordPointer(2, GL_FLOAT, 0, coordinates);	
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		
		// To-Do: add support for creating and holding a display list
		glVertexPointer(3, GL_FLOAT, 0, activeAnimation->mPlayBigVertices ? mBigVertices : mVertices);
		glEnableClientState(GL_VERTEX_ARRAY);
		
		if (mColors)
		{
			glColorPointer(4, GL_FLOAT, 0, mColors);
			glEnableClientState(GL_COLOR_ARRAY);
		}
		
		if (mNormals)
		{
			glNormalPointer(GL_FLOAT, 0, mNormals);
			glEnableClientState(GL_NORMAL_ARRAY);
		}
		
		glDrawArrays(GL_TRIANGLE_STRIP, 0, mVertexCount);
	}
	
	glPopMatrix();
	
	glDisable(GL_BLEND);
	glEnable(GL_DEPTH_TEST);
	
	glDisable(GL_TEXTURE_2D);
    if (mColors) 
    {
        glDisableClientState(GL_COLOR_ARRAY);
    }
}

