//
//  GameScene.m
//  SpriteKitDemo
//
//  Created by Neeraj Solanki on 19/04/17.
//  Copyright © 2017 Neeraj Solanki. All rights reserved.
//

#import "GameScene.h"
#import "common.h"

@implementation GameScene {
    
    NSTimeInterval _lastUpdateTime;
    
    SKLabelNode *eggLeftLabel;
    SKLabelNode *scoreLabel;
    SKLabelNode *lifeLeftLabel;
    SKLabelNode *resumeGameLabel;
    
    CGMutablePathRef pathToDraw;
    CGMutablePathRef shortPathToDraw;
    
    SKShapeNode *yourline;
    
    NSMutableArray <SKShapeNode*> *lineNodes;
    
    float waitDuratonFallingEgg;
    float levelGravity;
    
    BOOL isGamePaused;
    BOOL isGameOver;
    BOOL initiate;
    BOOL isUserDrawLine1;
    BOOL isUserDrawLine2;
    BOOL isUserDrawLine3;
    
    int currentLevel;
    int limitLines;
    int score;
    int eggLeft;
    int lifeLeft;
    int eggLimit;
    
    NSMutableDictionary *mantainLinePaths;
    NSMutableArray *tempPath;
}




- (void)sceneDidLoad {
    // Setup your scene here

    if(initiate)
    {
        return;
    }
    initiate=YES;
    
    levelGravity=(0-1.0f);
    waitDuratonFallingEgg = 2.0f;
    isUserDrawLine3=NO;
    isUserDrawLine2=NO;
    isUserDrawLine1=NO;
    
    
    score=0;
    lifeLeft=3;
    limitLines=3;
    _lastUpdateTime = 0;
    eggLimit =25;
    eggLeft=25;
    currentLevel=1;
    
    isGamePaused=NO;
    isGameOver=NO;
    
    
    [self scenePhysicsBody];
    [self timerEggGenerator];
    [self bucketBodyWithSide:BUCKET_LEFT];
    [self bucketBodyWithSide:BUCKET_RIGHT];
    [self scoreBoardInitilize];
    
    mantainLinePaths = [NSMutableDictionary dictionary];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:@"gameStatusCheck" object:nil];
}



//==========================Methods======================================//
#pragma mark Methods

-(SKLabelNode*)getLabelNodeWithName:(NSString*)nodeName
{
    return (SKLabelNode*)[self childNodeWithName:nodeName];
}

-(SKSpriteNode*)getSpriteNodeWithName:(NSString*)nodeName
{
    return (SKSpriteNode*)[self childNodeWithName:nodeName];
}

-(SKShapeNode*)getShapeNodeWithName:(NSString*)nodeName
{
    return (SKShapeNode*)[self childNodeWithName:nodeName];
}

-(SKTexture*)textureWithName:(NSString*)name
{
    SKTexture *texture = [SKTexture textureWithImageNamed:name];
    return texture;
}


//===========================Score Board=======================================//
#pragma mark Score Board

-(void)scoreBoardInitilize
{
    scoreLabel = [self getLabelNodeWithName:SCORE_LABEL];
    lifeLeftLabel = [self getLabelNodeWithName:LIFE_LEFT];
    eggLeftLabel = [self getLabelNodeWithName:EGG_LEFT];
    
    resumeGameLabel = [SKLabelNode new];
    resumeGameLabel.zPosition=1;
    resumeGameLabel.text=GAME_RESUME_TEXT;
    resumeGameLabel.name=RESUME;
    resumeGameLabel.color=[SKColor blackColor];
    resumeGameLabel.fontSize =  50;
    resumeGameLabel.position=CGPointMake(0,0);
}



//===================== SCENE PHYSICS BODY =========================//
#pragma mark Physics World

-(void)scenePhysicsBody
{
    
    SKSpriteNode* background = [SKSpriteNode spriteNodeWithImageNamed:BACKGROUND_SCENE];
    background.size = self.frame.size;
    background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    background.zPosition=-1;
    
    [self addChild:background];
    
    self.physicsWorld.contactDelegate = self;
    self.physicsWorld.gravity = CGVectorMake(0.0f, -1.0f);
}

//===================== BUCKET BODY =========================//
#pragma mark BucketBody

-(void)bucketBodyWithSide:(NSString*)bucketName
{
    
    SKSpriteNode *bucketSide = [self getSpriteNodeWithName:bucketName];
    bucketSide.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bucketSide.size];
    bucketSide.physicsBody.usesPreciseCollisionDetection = YES;
    bucketSide.physicsBody.dynamic=NO;
    
}




//================== EGG GENERATOR ==========================//
#pragma mark Egg Generator

-(void)timerEggGenerator
{
    id wait = [SKAction waitForDuration:waitDuratonFallingEgg];
    id run = [SKAction runBlock:^{
        // your code here ...
        if(eggLeft%3!=1)
        {
            [self randomEggNodesWithType:GOLDEN_EGG];
        }
        else
        {
            [self randomEggNodesWithType:GREEN_EGG];
        }
        
        eggLeft--;
        eggLeftLabel.text=[NSString stringWithFormat:@"X %d",eggLeft];
    
    }];
    
    SKAction *sequence = [SKAction sequence:@[wait, run]];
    SKAction *repeat = [SKAction repeatAction:sequence count:eggLimit];
    [self runAction:repeat];
    
    
}

-(void)randomEggNodesWithType:(NSString *)eggType
{
    srandomdev();
    
    float x=(self.size.width /2) -20;
    x=  (0-x) + arc4random()%(int)(x-(0-x));
    float y=(self.size.height /2 ) + 100 + arc4random()%200;
    
    SKSpriteNode *newEgg = [[SKSpriteNode alloc] initWithImageNamed:eggType];
    newEgg.name=eggType;
    newEgg.size = CGSizeMake(60, 60);
    
//    SKTexture *texture = [SKTexture textureWithImageNamed:eggType];
    newEgg.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:newEgg.size];
    newEgg.position = CGPointMake(x, y);
    newEgg.physicsBody.dynamic = YES;
    newEgg.physicsBody.contactTestBitMask = EGG_CATEGORY;
    newEgg.physicsBody.categoryBitMask = LINE_CATEGORY;
    newEgg.physicsBody.restitution=0.0001f;
    newEgg.physicsBody.usesPreciseCollisionDetection = YES;
    [newEgg runAction:[SKAction sequence:@[
                                          [SKAction waitForDuration:15],
                                          [SKAction runBlock:^
    {
    if([eggType isEqualToString:GREEN_EGG])
    {
        lifeLeft--;
    }
        
    }],
                                          [SKAction removeFromParent],
                                          ]]];
    [self addChild : newEgg];
}


//===================== Game Reset ==========================//
#pragma mark Game Reset

-(void)gameReset
{

    GKScene *scene = [GKScene sceneWithFileNamed:GAME_SCENE];
    GameScene *sceneNode = (GameScene *)scene.rootNode;
    sceneNode.entities = [scene.entities mutableCopy];
    sceneNode.graphs = [scene.graphs mutableCopy];
    sceneNode.scaleMode = SKSceneScaleModeAspectFill;
    [self.view presentScene:sceneNode];
}


// =================== Quit Game ==========================//
#pragma mark Quit Game
-(void)quitGame
{
    self.paused=YES;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:CONFIRMATION message:QUIT_GAME_MESSAGE preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction *quit = [UIAlertAction actionWithTitle:QUIT style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        UINavigationController *vc = (UINavigationController *)self.view.window.rootViewController;
        [vc popToRootViewControllerAnimated:YES];
    }];
    
    UIAlertAction *resume = [UIAlertAction actionWithTitle:RESUME style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        if(!isGameOver)
        {
            if(isGamePaused)
            {
            self.paused=YES;
            }
            else
            {
                self.paused=NO;
            }
        }
        
        }];
    [alert addAction:resume];
    [alert addAction:quit];
    [self.view.window.rootViewController presentViewController:alert animated:YES completion:nil];
}



//===================== Game Over ==========================//
#pragma mark Game Over

-(void)gameOver
{
    isGameOver=YES;
    SKLabelNode *gameOverlabel=[SKLabelNode new];
    gameOverlabel.text=PLAY_AGAIN_MESSAGE;
    gameOverlabel.color=[UIColor darkTextColor];
    gameOverlabel.fontSize =  50;
    gameOverlabel.name=GAME_OVER_LABEL;
    gameOverlabel.position=CGPointMake(0,0);
    [self addChild:gameOverlabel];
    self.paused =YES;
    
}



//===================== Game Pause & Play ==========================//
#pragma mark Game Pause & Resume
-(void)gamePausePlay:(NSString *)status
{
    SKSpriteNode *spriteNode = [self getSpriteNodeWithName:PAUSE_PLAY];
    spriteNode.texture=[self textureWithName:status];
    if(self.paused)
    {
        isGamePaused=NO;
        [resumeGameLabel removeFromParent];
        self.paused=NO;
    }
    else
    {
        isGamePaused=YES;
        [self addChild:resumeGameLabel];
        self.paused=YES;
    }
}


-(void)applicationWillEnterForeground:(NSNotification *)notification
{
    if(isGameOver)
    {
        
        [self gameReset];
    }
    else
    {
    if(isGamePaused)
    {
        [self gamePausePlay:PAUSE];
    }
    }
    
}



//==========================================================//
#pragma mark Touch Methods

- (void)touchDownAtPoint:(CGPoint)pos {
    
    pathToDraw =CGPathCreateMutable();
    
    tempPath = [NSMutableArray new];
    [tempPath addObject:[NSValue valueWithCGPoint:(pos)]];
    
    CGPathMoveToPoint(pathToDraw, NULL, pos.x, pos.y);
    CGPathAddLineToPoint(pathToDraw, NULL, pos.x, pos.y);
    
    shortPathToDraw =pathToDraw;
    
    yourline = [[SKShapeNode alloc] init];
    yourline.lineWidth=10;
    yourline.glowWidth=2;
    
    [self addChild:yourline];
}

- (void)touchMovedToPoint:(CGPoint)pos {
    
    NSValue *pointValue = (NSValue*)[tempPath lastObject];
    CGPoint lastPoint = (CGPoint)[pointValue CGPointValue];
    
    if((lastPoint.x != pos.x) && ( lastPoint.y != pos.y ))
    {
        [tempPath addObject:[NSValue valueWithCGPoint:(pos)]];
        CGPathAddLineToPoint(shortPathToDraw, NULL, pos.x, pos.y);
    }
    
   CGPathAddLineToPoint(pathToDraw, NULL, pos.x, pos.y);
   yourline.path = pathToDraw;
}

- (void)touchUpAtPoint:(CGPoint)pos {

    
    [tempPath addObject:[NSValue valueWithCGPoint:(pos)]];
    
    if(yourline.path>0)
    {
        
        SKShapeNode *newline = [[SKShapeNode alloc] init];

        if(!isUserDrawLine1)
        {
            newline.name=USER_DRAW_LINE_1;
            isUserDrawLine1 = YES;
            [mantainLinePaths setValue:tempPath forKey:USER_DRAW_LINE_1];
        }
        else if (!isUserDrawLine2)
        {
            newline.name=[NSString stringWithFormat:USER_DRAW_LINE_2];
            isUserDrawLine2 =YES;
            [mantainLinePaths setValue:tempPath forKey:USER_DRAW_LINE_2];
        }
        else if(!isUserDrawLine3)
        {
            [mantainLinePaths setValue:tempPath forKey:USER_DRAW_LINE_3];
            newline.name=[NSString stringWithFormat:USER_DRAW_LINE_3];
            isUserDrawLine3 =YES;
        }
        
        [yourline removeFromParent];
        
        newline.lineWidth=10;
        newline.glowWidth=2;
        newline.path=shortPathToDraw;
        
        [self addChild:newline];
        
        newline.physicsBody=[SKPhysicsBody bodyWithEdgeChainFromPath:newline.path];
        [newline runAction:[SKAction sequence:@[
                                                  [SKAction waitForDuration:0.3],
                                                  [SKAction fadeOutWithDuration:3],
                                            
                                                  [SKAction runBlock:^
        {
            limitLines++;
            if([newline.name isEqualToString:USER_DRAW_LINE_1])
            {
                isUserDrawLine1=NO;
                [mantainLinePaths removeObjectForKey:USER_DRAW_LINE_1];
            }
            else if([newline.name isEqualToString:USER_DRAW_LINE_2])
            {   isUserDrawLine2 =NO;
                [mantainLinePaths removeObjectForKey:USER_DRAW_LINE_2];
            }
            else if([newline.name isEqualToString:USER_DRAW_LINE_3])
            {   isUserDrawLine3 =NO;
            [mantainLinePaths removeObjectForKey:USER_DRAW_LINE_3];
            }
        }],
                                                  [SKAction removeFromParent]
                                                  ]]];
        limitLines--;
    }
    else
    {
        [yourline removeFromParent];
      //  [self removeLineAtTouch:pos];
    }
}

- (float)distanceFrom:(CGPoint)point1 to:(CGPoint)point2 {

    CGFloat xDist = (point2.x - point1.x);
    CGFloat yDist = (point2.y - point1.y);
  
//    NSLog(@"Distance %f %f Point1 %f %f Point2 %f %f",xDist,yDist,point1.x, point1.y,point2.x ,point2.y);
    return sqrt(pow(xDist,2)+pow(yDist,2));

}


//===========================CHeck Path EXist =======================================//
#pragma mark Check Path Exist

-(void)checkPathExistOnLines:(NSString *)lineName tapPosition:(CGPoint )position
{
    tempPath = [mantainLinePaths objectForKey:lineName];
    for(int i=0;i<tempPath.count;i++)
    {
        
        if((i+1)<tempPath.count)
        {
            NSValue *nsPointA = (NSValue*)[tempPath objectAtIndex:i];
            CGPoint tempPointA = [nsPointA CGPointValue];
            
            NSValue *nsPointB= (NSValue*)[tempPath objectAtIndex:i+1];
            CGPoint tempPointB = [nsPointB CGPointValue];
            
//            float ab = [self distanceFrom:tempPointA to:tempPointB];
            float ac = [self distanceFrom:tempPointA to:position];
//            // c is touch point
//            float bc = [self distanceFrom:tempPointB to:position];
//            
            
            CGFloat area =(tempPointA.x *(tempPointB.y - position.y) + tempPointB.x * (position.y - tempPointA.y) + position.x * (tempPointA.y -tempPointB.y))/2;
            CGFloat height=area*2/ac;
            if(height<0)
                height = (0-height);
            
            if(height<=5)
            {
                SKShapeNode *node =(SKShapeNode*)[self childNodeWithName:lineName];
                [node removeFromParent];
                [mantainLinePaths removeObjectForKey:lineName];
                if([lineName isEqualToString:USER_DRAW_LINE_1])
                {
                isUserDrawLine1=NO;
                }
                else if([lineName isEqualToString:USER_DRAW_LINE_2])
                {
                isUserDrawLine2=NO;
                }
                else if([lineName isEqualToString:USER_DRAW_LINE_3])
                {
                    isUserDrawLine3=NO;
                }
                limitLines++;
                
                break;
            }
        }
        
        
    }
    
}



//===========================Remove Line =======================================//
#pragma mark Remove Line
-(void)removeLineAtTouch:(CGPoint)position

{
    if(isUserDrawLine1)
    {
        [self checkPathExistOnLines:USER_DRAW_LINE_1 tapPosition:position];
        
    }
    if(isUserDrawLine2)
    {
        
      [self checkPathExistOnLines:USER_DRAW_LINE_2 tapPosition:position];
    }
    if(isUserDrawLine3)
    {
    [self checkPathExistOnLines:USER_DRAW_LINE_3 tapPosition:position];
        
    }
    
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // Run 'Pulse' action from 'Actions.sks'
    UITouch *touch = [touches anyObject];
    CGPoint positionInScene = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:positionInScene];
    if(touch.tapCount==2)
    {
        [self removeLineAtTouch:positionInScene];
    }
    else
    {
        
        if([node.name isEqualToString:RESTART]|| [node.name isEqualToString:GAME_OVER_LABEL])
        {
            [self gameReset];
        }
    else if([node.name isEqualToString:QUIT])
    {
        [self quitGame];
    }
        
    if(!isGameOver)
    {
        if(!isGamePaused)
        {
       
            for (UITouch *t in touches) {[self touchDownAtPoint:[t locationInNode:self]];}
        }
        if([node.name isEqualToString:PAUSE_PLAY] || [node.name isEqualToString:RESUME])
        {
            
            if(isGamePaused)
            {
                
                [self gamePausePlay:PAUSE];
            }
            else
            {
                [self gamePausePlay:PLAY];
                
            }
            
        }
    }
}
}




- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if(!isGameOver && !isGamePaused)
    {
        if(limitLines>0)
        {
            for (UITouch *t in touches) {[self touchMovedToPoint:[t locationInNode:self]];}
        }
    }
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for (UITouch *t in touches) {[self touchUpAtPoint:[t locationInNode:self]];}
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *t in touches) {[self touchUpAtPoint:[t locationInNode:self]];}
}



// ========================================================================//
#pragma mark Begin Contact Nodes

-(void)didBeginContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    
    // Crash This Eggs (EVIL)
    if([firstBody.node.name isEqualToString:GOLDEN_EGG] && ([secondBody.node.name isEqualToString:USER_DRAW_LINE_1] || [secondBody.node.name isEqualToString:USER_DRAW_LINE_2] || [secondBody.node.name isEqualToString:USER_DRAW_LINE_3]))
    {
        firstBody.node.physicsBody.dynamic=NO;
        [self removeEgg:(SKSpriteNode *) firstBody.node didCollideWithLine:(SKSpriteNode *) secondBody.node];
    }
    
    // Life Decrement Evil Egg
    else if([firstBody.node.name isEqualToString:GOLDEN_EGG] && ([secondBody.node.name isEqualToString:BUCKET_LEFT] || [secondBody.node.name isEqualToString:BUCKET_RIGHT]))
    {
        lifeLeft--;
        if(lifeLeft<0)
        {
            
            firstBody.node.physicsBody.dynamic=NO;
            [self lifeDecrement:(SKSpriteNode *)firstBody.node];
            [self gameOver];
        }
        else
        {
            firstBody.node.physicsBody.dynamic=NO;
            [self lifeDecrement:(SKSpriteNode *)firstBody.node];
            lifeLeftLabel.text=[NSString stringWithFormat:@"X %d",lifeLeft];
        }
    }
    
    // Score Increment Green Egg
    else if([firstBody.node.name isEqualToString:GREEN_EGG] && ([secondBody.node.name isEqualToString:BUCKET_LEFT] || [secondBody.node.name isEqualToString:BUCKET_RIGHT]))
    {
        score++;
        firstBody.node.physicsBody.dynamic=NO;
        [self scoreIncrement:(SKSpriteNode *)firstBody.node];
        scoreLabel.text=[NSString stringWithFormat:@"X %d",score];
        
    }
    else if([firstBody.node.name isEqualToString:GREEN_EGG] && ([secondBody.node.name isEqualToString:BOTTOM_BORDER]))
    {
        lifeLeft--;
        if(lifeLeft<0)
        {
            
            firstBody.node.physicsBody.dynamic=NO;
            [self lifeDecrement:(SKSpriteNode *)firstBody.node];
            [self gameOver];
        }
        else
        {
            firstBody.node.physicsBody.dynamic=NO;
            [self lifeDecrement:(SKSpriteNode *)firstBody.node];
            lifeLeftLabel.text=[NSString stringWithFormat:@"X %d",lifeLeft];
        }
    }
    
    
    else if([firstBody.node.name isEqualToString:GOLDEN_EGG] && ([secondBody.node.name isEqualToString:BOTTOM_BORDER]))
    {
        firstBody.node.physicsBody.dynamic= NO;
        [self removeEgg:(SKSpriteNode*)firstBody.node didCollideWithLine:(SKSpriteNode*)secondBody.node];
    }
}


#pragma mark Life Decrement

-(void)lifeDecrement:(SKSpriteNode *)egg
{
    

    egg.texture=[self textureWithName:EVIL_IMAGE];
    [egg runAction:[SKAction sequence:@[
                                        [SKAction waitForDuration:0.5],
                                        [SKAction fadeOutWithDuration:0.5],
                                        [SKAction removeFromParent],
                                        ]]];
}



#pragma mark Score Increment

-(void)scoreIncrement:(SKSpriteNode *)egg
{

    egg.texture=[self textureWithName:COIN_IMAGE];
    [egg runAction:[SKAction sequence:[Utilities actionsArray:0.5 fade:0.5]]];
}

- (void)removeEgg:(SKSpriteNode *)evilQuare didCollideWithLine:(SKSpriteNode *)line {
    evilQuare.texture=[self textureWithName:BROKEN_EGG];
    [evilQuare runAction:[SKAction sequence:[Utilities actionsArray:0.5 fade:0.5]]];
}



-(void)removeUserLineDrawCollision:(NSString*)lineName
{
    SKLabelNode *line=[self getLabelNodeWithName:lineName];
    if(line.alpha <0.25)
    {
        line.physicsBody = nil;
    }
}


-(void)update:(CFTimeInterval)currentTime {
    
    // Initialize _lastUpdateTime if it has not already been
    if (_lastUpdateTime == 0) {
        _lastUpdateTime = currentTime;
    }
    int countNode= (int)self.children.count;
    if(countNode <= 19  && eggLeft ==0)
    {
        // Update Level
        currentLevel++;
        levelGravity = levelGravity + (0 - 0.5);
        waitDuratonFallingEgg = waitDuratonFallingEgg - 0.05;
        eggLimit = eggLimit + 15;
        eggLeft=eggLimit;
        self.physicsWorld.gravity= CGVectorMake(0.0f, levelGravity);
        SKLabelNode *gameOverlabel=[SKLabelNode new];
        gameOverlabel.text=[NSString stringWithFormat:@"Level %d",currentLevel];
        gameOverlabel.color=[UIColor darkTextColor];
        gameOverlabel.fontSize =  60;
        gameOverlabel.position=CGPointMake(0,0);
        [gameOverlabel runAction:[SKAction sequence:@[
                                                      [SKAction waitForDuration:1],
                                                      [SKAction fadeOutWithDuration:1],
                                                      [SKAction removeFromParent],
                                                      [SKAction runBlock:^{[self timerEggGenerator]; }]
                                                      ]]];
        [self addChild:gameOverlabel];
        
        
    }
    
    if(isUserDrawLine1)
    {
        [self removeUserLineDrawCollision:USER_DRAW_LINE_1];
    }
    if(isUserDrawLine2)
    {
        [self removeUserLineDrawCollision:USER_DRAW_LINE_2];
    }
    if(isUserDrawLine3)
    {
        [self removeUserLineDrawCollision:USER_DRAW_LINE_3];
    }
    // Calculate time since last update
    CGFloat dt = currentTime - _lastUpdateTime;
    
    // Update entities
    for (GKEntity *entity in self.entities) {
        [entity updateWithDeltaTime:dt];
    }
    
    _lastUpdateTime = currentTime;
}

@end
