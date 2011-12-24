/*
 *  Drawable.h
 *  Gopher
 *
 *  Created by Anthony Lobay on 1/22/10.
 *  Copyright 2010 3dDogStudios. All rights reserved.
 *
 */

#import <btBulletDynamicsCommon.h>
#import <map>
#import <list>

#import "Component.h"
#import "Texture2D.h"
#import "VectorMath.h"

namespace Dog3D
{
	
	class CoordinateSet
	{
	public: 
		Vec3* mVertices;
		Vec3* mNormals;
		Vec2* mTexCoords;
		Color* mColors;
		int mVertexCount;
		
		CoordinateSet(int nVertices)
		{
			mVertexCount = nVertices;
			mVertices = new Vec3[nVertices];
			mNormals = new Vec3[nVertices];
			mTexCoords = new Vec2[nVertices];
			mColors = new Color[nVertices];
		}
		
		~CoordinateSet()
		{
			delete [] mColors;
			delete [] mNormals;
			delete [] mTexCoords;
			delete [] mVertices;
		}
	};
	
	class MaterialSet
	{
	public:
		GLfloat mat_ambient[4];
		GLfloat mat_diffuse[4]; 
		GLfloat mat_specular[4];
		GLfloat mat_shininess[1];
		
		MaterialSet()
		{
			mat_ambient[0] = 0.8;
			mat_ambient[1] = 0;
			mat_ambient[2] = 0;
			mat_ambient[3] = 1;
			
			mat_diffuse[0] = 1;
			mat_diffuse[1] = 1;
			mat_diffuse[2] = 1;
			mat_diffuse[3] = 1;
			
			mat_specular[0] = 0.77;
			mat_specular[1] = 0.77;			
			mat_specular[2] = 0.77;
			mat_specular[3] = 1;
			
			mat_shininess[0]  = 0.6;	
		}
	
	};
		
	// Drawable component
	// Basic vertex container
	class GraphicsComponent : public Component
	{
	protected: 
		
		btVector3 mScale;
		
		const Vec3* mVertices;
		const Vec3* mNormals;
		const Vec2* mTexCoords;
		const Color* mColors;
		int mVertexCount;
		
		const MaterialSet *mMaterialSet;
		
		const Texture2D* mTexture;
		btVector3 mOffset;

		
	public:
		
		bool mActive;
 		
	public:
		GraphicsComponent() : 
		mVertices(NULL), 
		mNormals(NULL), 
		mTexCoords(NULL),
		mVertexCount(0), 
		mActive(true),
		mTexture(NULL),
		mOffset(0,0,0),
		mScale(1,1,1)
		{ 
			mTypeId = GRAPHICS;
		}
		
		virtual ~GraphicsComponent();
		
		inline void SetVertices( const Vec3* vertices, int nVertices )
		{
			mVertices = vertices;
			mVertexCount = nVertices;
		}
		
		inline void SetNormals( const Vec3* normals)
		{
			mNormals = normals;
		}
		
		inline void SetColors( const Color* colors)
		{
			mColors = colors;
		}
		
		inline void SetTexCoords( const Vec2* coords)
		{ 
			mTexCoords = coords;
		}
		
		inline void SetTexture( const Texture2D *texture)
		{
			mTexture = texture;	
		}
		
		void SetScale( float s) { mScale = btVector3(s,s,s); }
		void SetScale( btVector3 &s) { mScale = s; }
		
		inline btVector3 GetScale() { return mScale;}
		
		// assign a material setup (usually from gfx mgr's cached palette)
		inline void SetMaterialSet( const MaterialSet *materialSet)
		{ 
			mMaterialSet = materialSet;
		}
		
		// default material lighting setup
		inline void SetupMaterials()
		{}
		
		virtual void Update(float deltaTime);
		
		inline void SetOffset(btVector3 &offset){ mOffset = offset; }
		inline void SetOffset(btVector3 offset){ mOffset = offset; }
		
		inline btVector3 GetOffset() { return mOffset; }
	};
	
	class LineComponent : public GraphicsComponent
	{		
		virtual void Update(float deltaTime);
	};
	
	// holds n graphics components
	class CompoundGraphicsComponent : public GraphicsComponent
	{
	public:
		CompoundGraphicsComponent() {}
		
		~CompoundGraphicsComponent();
		
		void AddChild(GraphicsComponent *child);
		
		GraphicsComponent *RemoveFirstChild();
		
		GraphicsComponent *GetFirstChild();
		
		inline int IsEmtpy() { return mChildren.empty();}
			 
		// draw each child
		void Update(float deltaTime);
		
	protected:
		std::list<GraphicsComponent *> mChildren;
		
	};
	
	
	class TexturedGraphicsComponent : public GraphicsComponent
	{
		
	public:
		TexturedGraphicsComponent(float width, float height) 
		{ 
			mTexture = NULL;
			mScale = btVector3(width, 0, height);
		}
		
		float getWidth() { return mScale.x();}
		float getHeight() { return mScale.z();}
		
		~TexturedGraphicsComponent();
		
		void Update(float deltaTime);		
		
	};
	
	
	
	class HUDGraphicsComponent : public GraphicsComponent 
	{
		// texture
		btVector3 mExtents;
		float mWidthSpacing;
		int mTotalLives; 
		int mCurrentLives;
		bool mAlignLeft; //if not align right
		
	public:
		HUDGraphicsComponent(Texture2D* texture,  btVector3 &extents, float widthSpacing, int nTotal, bool alignLeft) : 
		mExtents(extents),
		mWidthSpacing(widthSpacing),
		mTotalLives(nTotal), 
		mCurrentLives(nTotal),
		mAlignLeft(alignLeft)
		{ 
			mTexture = texture; 
		}
		
		inline void RemoveLife()
		{ 
			mCurrentLives--; 
			if (mCurrentLives < 0) 
			{
				mCurrentLives = 0;
			}
		}
		
		void Update(float dt) ;
		
	};
	
	class SquareTexturedGraphicsComponent : public TexturedGraphicsComponent
	{

	public:
		
		SquareTexturedGraphicsComponent(float width, float height) :
		TexturedGraphicsComponent(width, height){ }
		
		void Update(float deltaTime);	
	};
	
	// screen space based graphics componentt
	class ScreenSpaceComponent : public TexturedGraphicsComponent
	{
		
	public:
		
		ScreenSpaceComponent(float width, float height, btVector3 target, float duration) :
		TexturedGraphicsComponent(width, height), 
		mTarget(target), 
		mDuration(duration),
		mRotateTowardsTarget(true),
		mConstrainToCircle(true){ }
		
		void Update(float deltaTime);	
		
		bool IsFinished() { return mDuration <= 0;}
		
		btVector3 mTarget;
		float mDuration;
		
		// forces rotation
		bool mRotateTowardsTarget;
		
		// keeps object contstrained to a visible circle
		bool mConstrainToCircle;
	};
	
}