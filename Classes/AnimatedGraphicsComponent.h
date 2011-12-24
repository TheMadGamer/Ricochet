//
//  AnimatedGraphicsComponent.h
//  Grenades
//
//  Created by Anthony Lobay on 12/23/11.
//  Copyright (c) 2011 3dDogStudios.com. All rights reserved.
//

#import <btBulletDynamicsCommon.h>
#import <map>
#import <list>

#import "Component.h"
#import "GraphicsComponent.h"
#import "Texture2D.h"
#import "VectorMath.h"

namespace Dog3D
{
    
    
	class SpriteAnimation
	{
	public:
		int mTileWidth;
		int mTileHeight;
		int mTileCount;
		
		//  current tile index
		int mTileIndex;
		
		// frame duration in time
		float mFrameDuration;
        
		Texture2D* mSpriteSheet;
        
		bool mPlayBigVertices;
		bool mLoopAnimation;
		
		SpriteAnimation(bool playBigVertices = false, bool loopAnimation = true) : 
        mFrameDuration(1.0/30.0),
        mSpriteSheet(NULL), 
        mPlayBigVertices(playBigVertices),
        mLoopAnimation(loopAnimation)
		{} 
		
		inline float getDS()
		{
			float wide = [mSpriteSheet pixelsWide];
			float frameSize= wide/mTileWidth;
			
			return ((float) frameSize)/ ((float) wide);
		}
		
		float getDT()
		{
			float high = [mSpriteSheet pixelsHigh];
			float frameSize = high/mTileHeight;
            
			return ((float) frameSize)/ ((float) high);
		}
		
		
		inline float getS() 
		{
			int j = ( mTileIndex % mTileWidth);		
			return ((float) j) * getDS();
		}
		
		inline float getT() 
		{
			int i = ( mTileIndex / mTileWidth);
			return ((float) i) * getDT();
		}
		
	};	
    
    enum AnimationMirroring
	{
		MIRROR_NONE = 0x0, MIRROR_HORIZONTAL = 0x1, MIRROR_VERTICAL = 0x2
	};

    class AnimatedGraphicsComponent : public GraphicsComponent
    {
    protected:
        std::map<int, SpriteAnimation*> mAnimations;
        
        Vec3 *mBigVertices;
        
        // draw me this wide, tall
        float mFrameTime;
        
        int mActiveAnimationID;
        
        int mMirrorAnimation;
        bool mPlayForward;
        bool mIgnoreParentRotation;
        
    public:
        
        enum GopherAnims
        {
            IDLE = 0, 
            WALK_FORWARD, 
            WALK_FORWARD_LEFT, 
            WALK_LEFT, 
            WALK_BACK_LEFT, 
            WALK_BACK, 
            BLOWUP_FORWARD, 
            BLOWUP_LEFT, 
            SPAWN_IN, 
            JUMP_DOWN_HOLE,
            EAT_CARROT,
            WIN_DANCE,
            TAUNT,
            FREEZE,
            ELECTRO,
            FIRE
        };
        
        
        AnimatedGraphicsComponent(float width, float height) : 	
        mFrameTime(0),
        mActiveAnimationID(0),
        mMirrorAnimation(MIRROR_NONE),
        mPlayForward(true), 
        mIgnoreParentRotation(true),
        mBigVertices(NULL)
        {
            mScale = btVector3(width, 0, height);
        }
        
        ~AnimatedGraphicsComponent();
        
        inline bool LastFrame()
        { 
            if(mPlayForward)
            {
                return mAnimations[mActiveAnimationID]->mTileIndex == ( mAnimations[mActiveAnimationID]->mTileCount -1) ;
            }
            else {
                return mAnimations[mActiveAnimationID]->mTileIndex ==0;
            }
        }
        
        inline bool IsLooping()
        {
            return mAnimations[mActiveAnimationID]->mLoopAnimation;
        }
        
        void AddAnimation(SpriteAnimation *newSpriteSheet, int ID);
        
        // starts anim at frame 0 or end, if playForward = false
        void StartAnimation(GopherAnims animationID, AnimationMirroring mirror = MIRROR_NONE, bool playForward = true );	
        
        void StartAnimation(GopherAnims ID,  AnimationMirroring mirror, int startFrame );
        
        // will not restart anim if already playing
        void PlayAnimation(GopherAnims animationID,  AnimationMirroring mirror = MIRROR_NONE, bool playForward = true );
        
        // direction based anim play
        void UpdateAnimatedWalkDirection( btVector3 &direction );
        
        
        void Update(float deltaTime);	
        
        inline void SetBigVertices( Vec3 * bigVertices)
        {
            mBigVertices = bigVertices;
        }
        
        void StepAnimation(SpriteAnimation *activeAnimation, float dt);
        
    };
}