//
// @author Jonny Brannum <jonny.brannum@gmail.com> 
//         1/21/12
//

#import <AVFoundation/AVFoundation.h>
#import "GameLayer.h"
#import "MazeGenerator.h"
#import "CCSpriteBatchNode.h"
#import "CCSpriteFrameCache.h"
#import "CCSprite.h"
#import "CGPointExtension.h"
#import "CCActionInterval.h"

@interface GameLayer ()
@property (nonatomic, retain) MazeGenerator *mazeGenerator;
@property (nonatomic, assign) CCSprite *playerEntity;
@end

@implementation GameLayer
@synthesize mazeGenerator = _mazeGenerator;
@synthesize playerEntity = _playerEntity;


- (id)init
{
    self = [super init];
    self.isTouchEnabled = YES;
    CCSpriteBatchNode *wallSprites = [CCSpriteBatchNode batchNodeWithFile:@"walls.png" capacity:4];
    [self addChild:wallSprites];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"walls.plist"];
    self.mazeGenerator = [[[MazeGenerator alloc] init] autorelease];
    [_mazeGenerator createUsingDepthFirstSearch];
    [self loadGeneratedMaze];
    return self;
}

- (void)loadGeneratedMaze
{
    [_mazeGenerator.grid enumerateKeysAndObjectsUsingBlock:
        ^(id cellKey, id cell, BOOL *cellStop) {
            [self addChild:cell];
        }
    ];
    // determine our maze center
    CGPoint mazeCenter = ccp((_mazeGenerator.size.width)/2, (_mazeGenerator.size.height)/2);
    self.playerEntity = [CCSprite spriteWithSpriteFrameName:@"entity.png"];
    [_playerEntity setPosition:ccp(mazeCenter.x, mazeCenter.y)];
    CCSprite *glow = [CCSprite spriteWithSpriteFrameName:@"entity.png"];
    [glow setBlendFunc: (ccBlendFunc) { GL_SRC_ALPHA, GL_ONE }];
    id sequence = [CCSequence actions:
        [CCFadeTo actionWithDuration:0.5f opacity:100],
        [CCFadeTo actionWithDuration:0.5f opacity:255],
        nil
    ];
    [glow runAction:[CCRepeatForever actionWithAction:sequence]];
    [glow setPosition:ccp(glow.textureRect.size.width/2, glow.textureRect.size.height/2)];
    [_playerEntity addChild:glow];
    [self addChild:_playerEntity];
    // determine the window center
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CGPoint winCenter = ccp(winSize.width/2, winSize.height/2);
    // determine the difference between the two
    CGPoint diff = ccpSub(winCenter, mazeCenter);
    // add the difference to our current position to center the maze
    [self setPosition:ccpAdd(position_, diff)];
}

- (void)ccTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{

}

- (void)ccTouchesMoved:(NSSet*)touches withEvent:(UIEvent *)event
{
    // we also handle touches for map movement
    // simply move the layer around by the diff of this move and the last
    UITouch *touch = [touches anyObject];
    // get our GL location
    CGPoint location = [[CCDirector sharedDirector]
            convertToGL:[touch locationInView:touch.view]
    ];
    CGPoint previousLocation = [[CCDirector sharedDirector]
            convertToGL:[touch previousLocationInView:touch.view]
    ];
    // create the difference
    CGPoint diff = ccp(location.x - previousLocation.x, location.y - previousLocation.y);
    // add the diff to the current position
    [self setPosition:ccp(position_.x + diff.x, position_.y + diff.y)];
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    // get our GL location
    CGPoint location = [[CCDirector sharedDirector]
            convertToGL:[touch locationInView:touch.view]
    ];
    [_mazeGenerator searchUsingDepthFirstSearch:_playerEntity.position endingAt:ccpSub(location, position_) movingEntity:_playerEntity];
}

- (void)dealloc {
    [_mazeGenerator release];
    [super dealloc];
}
@end