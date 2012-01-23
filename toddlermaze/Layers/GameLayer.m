//
// @author Jonny Brannum <jonny.brannum@gmail.com> 
//         1/21/12
//

#import "GameLayer.h"
#import "MazeGenerator.h"
#import "CCSpriteBatchNode.h"
#import "CCSpriteFrameCache.h"
#import "CCSprite.h"
#import "CGPointExtension.h"
#import "MazeCell.h"
#import "Entity.h"
#import "Constants.h"

@interface GameLayer ()
@property (nonatomic, retain) MazeGenerator *mazeGenerator;
@property (nonatomic, assign) Entity *playerEntity;
@property (nonatomic, assign) Entity *currentStart;
@property (nonatomic, assign) Entity *currentEnd;
@end

@implementation GameLayer
@synthesize mazeGenerator = _mazeGenerator;
@synthesize playerEntity = _playerEntity;
@synthesize currentStart = _currentStart;
@synthesize currentEnd = _currentEnd;

- (id)init
{
    self = [super init];
    self.isTouchEnabled = YES;
    CCSpriteBatchNode *wallSprites = [CCSpriteBatchNode batchNodeWithFile:@"walls.png" capacity:4];
    [self addChild:wallSprites];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"walls.plist"];
    self.mazeGenerator = [[[MazeGenerator alloc] init] autorelease];
    [self regenerateMaze];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(regenerateMaze) name:kRegenerateMazeNotification object:nil];
    return self;
}

- (void)regenerateMaze
{
    [self removeAllChildrenWithCleanup:YES];
    _currentStart = nil;
    _currentEnd = nil;
    _playerEntity = nil;
    [self setPosition:ccp(0, 0)];
    [_mazeGenerator createUsingDepthFirstSearch];
    [self loadGeneratedMaze];
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
    // find our center cell
    MazeCell *centerCell = [_mazeGenerator cellForPosition:mazeCenter];
    self.playerEntity = [Entity spriteWithFile:@"entity.png"];
    [_playerEntity setPosition:centerCell.position];
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
    [_playerEntity stopAllActions];
    if (_currentStart == nil) {
        _currentStart = [Entity spriteWithFile:@"entity.png"];
        [_currentStart setColor:ccRED];
        [self addChild:_currentStart];
    }
    [_currentStart setPosition:_playerEntity.position];
    if (_currentEnd == nil) {
        _currentEnd = [Entity spriteWithFile:@"entity.png"];
        [_currentEnd setColor:ccGREEN];
        [self addChild:_currentEnd];
    }
    MazeCell *cell = [_mazeGenerator cellForPosition:ccpSub(location, position_)];
    [_currentEnd setPosition:cell.position];

    [_mazeGenerator searchUsingDepthFirstSearch:_playerEntity.position endingAt:ccpSub(location, position_) movingEntity:_playerEntity];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_mazeGenerator release];
    [super dealloc];
}
@end