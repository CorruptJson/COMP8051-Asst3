//
//  Copyright © Borna Noureddin. All rights reserved.
//

#include <Box2D/Box2D.h>
#include "CBox2D.h"
#include <stdio.h>
#include <map>

// Some Box2D engine paremeters
const float MAX_TIMESTEP = 1.0f/60.0f;
const int NUM_VEL_ITERATIONS = 10;
const int NUM_POS_ITERATIONS = 3;


#pragma mark - Box2D contact listener class

// This C++ class is used to handle collisions
class CContactListener : public b2ContactListener
{
public:
    void BeginContact(b2Contact* contact) {};
    void EndContact(b2Contact* contact) {};
    void PreSolve(b2Contact* contact, const b2Manifold* oldManifold)
    {
        b2WorldManifold worldManifold;
        contact->GetWorldManifold(&worldManifold);
        b2PointState state1[2], state2[2];
        b2GetPointStates(state1, state2, oldManifold, contact->GetManifold());
        if (state2[0] == b2_addState)
        {
            // Use contact->GetFixtureA()->GetBody() to get the body
            b2Body* bodyA = contact->GetFixtureA()->GetBody();
            CBox2D *parentObj = (__bridge CBox2D *)(bodyA->GetUserData());
        }
    }
    void PostSolve(b2Contact* contact, const b2ContactImpulse* impulse) {};
};


#pragma mark - CBox2D

@interface CBox2D ()
{
    // Box2D-specific objects
    b2Vec2 *gravity;
    b2World *world;
    b2BodyDef *groundBodyDef;
    b2Body *groundBody;
    b2PolygonShape *groundBox;
    b2Body *theBrick, *theBrick2, *theBall;
    CContactListener *contactListener;
    float totalElapsedTime;

    // You will also need some extra variables here for the logic

    bool ballLaunched;
    bool gameStart;
}
@end

@implementation CBox2D

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Initialize Box2D
        gravity = new b2Vec2(0.0f, 0.0f);
        world = new b2World(*gravity);
        
        // For HelloWorld
        groundBodyDef = NULL;
        groundBody = NULL;
        groundBox = NULL;

        // For brick & ball sample
        contactListener = new CContactListener();
        world->SetContactListener(contactListener);
        
        // Set up the brick and ball objects for Box2D
        b2BodyDef brickBodyDef;
        brickBodyDef.type = b2_dynamicBody;
        brickBodyDef.position.Set(BRICK_POS_X, BRICK_POS_Y);
        
        theBrick = world->CreateBody(&brickBodyDef);
        if (theBrick)
        {
            theBrick->SetUserData((__bridge void *)self);
            theBrick->SetAwake(false);
            theBrick->SetType(b2_kinematicBody);
            b2PolygonShape dynamicBox;
            dynamicBox.SetAsBox(BRICK_WIDTH/2, BRICK_HEIGHT/2);
            b2FixtureDef fixtureDef;
            fixtureDef.shape = &dynamicBox;
            fixtureDef.density = 1.0f;
            fixtureDef.friction = 0.0f;
            fixtureDef.restitution = 1.0f;
            theBrick->CreateFixture(&fixtureDef);
            theBrick->SetAwake(true);
            
            b2BodyDef ballBodyDef;
            ballBodyDef.type = b2_dynamicBody;
            ballBodyDef.position.Set(BALL_POS_X, BALL_POS_Y);
            theBall = world->CreateBody(&ballBodyDef);
            
            
            b2BodyDef brickBodyDef2;
            brickBodyDef2.type = b2_dynamicBody;
            brickBodyDef2.position.Set(BRICK_POS_X + 600, BRICK_POS_Y);
            theBrick2 = world->CreateBody(&brickBodyDef2);
            if (theBrick2)
            {
                theBrick2->SetUserData((__bridge void *)self);
                theBrick2->SetAwake(false);
                theBrick2->SetType(b2_kinematicBody);
                b2PolygonShape dynamicBox2;
                dynamicBox2.SetAsBox(BRICK_WIDTH/2, BRICK_HEIGHT/2);
                b2FixtureDef fixtureDef2;
                fixtureDef2.shape = &dynamicBox2;
                fixtureDef2.density = 1.0f;
                fixtureDef2.friction = 0.0f;
                fixtureDef2.restitution = 1.0f;

                theBrick2->CreateFixture(&fixtureDef2);
                theBrick->SetAwake(true);
                
            }
            
            
            
            
            if (theBall)
            {
                theBall->SetUserData((__bridge void *)self);
                theBall->SetAwake(false);
                b2CircleShape circle;
                circle.m_p.Set(0, 0);
                circle.m_radius = BALL_RADIUS;
                b2FixtureDef circleFixtureDef;
                circleFixtureDef.shape = &circle;
                circleFixtureDef.density = 1.0f;
                circleFixtureDef.friction = 0.0f;
                circleFixtureDef.restitution = 1.2f;
                theBall->CreateFixture(&circleFixtureDef);
            }
        }
        
        totalElapsedTime = 0;
        ballLaunched = false;
        gameStart = false;
    }
    return self;
}

- (void)dealloc
{
    if (gravity) delete gravity;
    if (world) delete world;
    if (groundBodyDef) delete groundBodyDef;
    if (groundBox) delete groundBox;
    if (contactListener) delete contactListener;
}

-(void)Update:(float)elapsedTime
{
    b2Vec2 pos = theBall->GetPosition();
    b2Vec2 velocity = theBall->GetLinearVelocity();
    
    b2Vec2 brick2Pos = theBrick2->GetPosition();
    
    //Move AI slightly slower than the ball (to prevent jittering), but only up the the max speed.
    float brick2Vel = MIN(ABS(velocity.y) - 5, 250);
    
    // Check here if we need to launch the ball
    //  and if so, use ApplyLinearImpulse() and SetActive(true)
    if (!gameStart && ballLaunched)
    {
        
        // ball x speed -+ 20%
        float ballXMod = (arc4random_uniform(40)) -20.0f;
        
        //ball y speed -+30%
        float ballYMod = (arc4random_uniform(60)) -30.0f;
        
        //Up or down
        
        float ballDir = ((arc4random_uniform(2)) * 2.0f ) - 1.0f;
        
        NSLog(@"Start Ball %f", ballDir);
        
        theBall->ApplyLinearImpulse(b2Vec2(-BALL_VELOCITY * (1 + (ballXMod / 100)), BALL_VELOCITY * (1 + (ballYMod/100)) * ballDir ), theBall->GetPosition(), true);
        theBall->SetActive(true);

        ballLaunched = false;
        gameStart = true;
    }
    
    
    // Screen Bounce
    //NSLog(@"yPos: %f", pos.y);
    if (pos.y <= 0 && velocity.y < 0) {
        theBall->SetLinearVelocity(b2Vec2(velocity.x, -velocity.y));
    }
    if (pos.y >= 600 && velocity.y > 0) {
        theBall->SetLinearVelocity(b2Vec2(velocity.x, -velocity.y));
    }
    
    //NSLog(@"BALLS VEL: %f", theBall->GetLinearVelocity().y);
    




    
    
    if(pos.y > brick2Pos.y) {
        theBrick2->SetLinearVelocity(b2Vec2(0, brick2Vel));
    }
    else if (pos.y < brick2Pos.y){
        theBrick2->SetLinearVelocity(b2Vec2(0, -brick2Vel));
    } else {
        theBrick2->SetLinearVelocity(b2Vec2(0, 0));
    }
    
    
    
    
    
    if (world)
    {
        while (elapsedTime >= MAX_TIMESTEP)
        {
            world->Step(MAX_TIMESTEP, NUM_VEL_ITERATIONS, NUM_POS_ITERATIONS);
            elapsedTime -= MAX_TIMESTEP;
        }
        
        if (elapsedTime > 0.0f)
        {
            world->Step(elapsedTime, NUM_VEL_ITERATIONS, NUM_POS_ITERATIONS);
        }
    }
    
    
    
}



-(void)ResetGame
{
    theBall->SetAwake(false);
    theBall->SetLinearVelocity(b2Vec2(0,0));
    theBall->SetTransform(b2Vec2(BALL_POS_X, BALL_POS_Y), 0);
    theBrick->SetTransform(b2Vec2(BRICK_POS_X, BRICK_POS_Y), 0);
    theBrick2->SetTransform(b2Vec2(BRICK_POS_X + 600, BRICK_POS_Y), 0);
    
    ballLaunched = false;
    gameStart = false;
}

-(void)LaunchBall
{
    // Set some flag here for processing later...
    ballLaunched = true;
}

// Used to move player addle
-(void)movePaddle: (float) translation
{
    float topVariable = theBrick->GetPosition().y;
    
    
    theBrick->SetTransform(b2Vec2(BRICK_POS_X, topVariable - translation), 0.0);
    
    NSLog(@"MOVEPADDLE: %f", translation - topVariable);
}

-(void *)GetObjectPositions
{
    auto *objPosList = new std::map<const char *,b2Vec2>;
    if (theBall)
        (*objPosList)["ball"] = theBall->GetPosition();
    if (theBrick)
        (*objPosList)["brick"] = theBrick->GetPosition();
    if (theBrick2)
        (*objPosList)["brick2"] = theBrick2->GetPosition();
    return reinterpret_cast<void *>(objPosList);
}


-(float)GetBallX {
    return theBall->GetPosition().x;
}



-(void)HelloWorld
{
    groundBodyDef = new b2BodyDef;
    groundBodyDef->position.Set(0.0f, -10.0f);
    groundBody = world->CreateBody(groundBodyDef);
    groundBox = new b2PolygonShape;
    groundBox->SetAsBox(50.0f, 10.0f);
    
    groundBody->CreateFixture(groundBox, 0.0f);
    
    // Define the dynamic body. We set its position and call the body factory.
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position.Set(0.0f, 4.0f);
    b2Body* body = world->CreateBody(&bodyDef);
    
    // Define another box shape for our dynamic body.
    b2PolygonShape dynamicBox;
    dynamicBox.SetAsBox(1.0f, 1.0f);
    
    // Define the dynamic body fixture.
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &dynamicBox;
    
    // Set the box density to be non-zero, so it will be dynamic.
    fixtureDef.density = 1.0f;
    
    // Override the default friction.
    fixtureDef.friction = 0.3f;
    
    // Add the shape to the body.
    body->CreateFixture(&fixtureDef);
    
    // Prepare for simulation. Typically we use a time step of 1/60 of a
    // second (60Hz) and 10 iterations. This provides a high quality simulation
    // in most game scenarios.
    float32 timeStep = 1.0f / 60.0f;
    int32 velocityIterations = 6;
    int32 positionIterations = 2;
    
    // This is our little game loop.
    for (int32 i = 0; i < 60; ++i)
    {
        // Instruct the world to perform a single step of simulation.
        // It is generally best to keep the time step and iterations fixed.
        world->Step(timeStep, velocityIterations, positionIterations);
        
        // Now print the position and angle of the body.
        b2Vec2 position = body->GetPosition();
        float32 angle = body->GetAngle();
        
        printf("%4.2f %4.2f %4.2f\n", position.x, position.y, angle);
    }
}

@end
