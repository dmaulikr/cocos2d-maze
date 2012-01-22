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

@implementation GameLayer
- (id)init
{
    self = [super init];
    self.isTouchEnabled = YES;
    CCSpriteBatchNode *wallSprites = [CCSpriteBatchNode batchNodeWithFile:@"walls.png" capacity:4];
    [self addChild:wallSprites];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"walls.plist"];
    MazeGenerator *generator = [[[MazeGenerator alloc] init] autorelease];
    [generator.grid enumerateKeysAndObjectsUsingBlock:
        ^(id cellKey, id cell, BOOL *cellStop) {
            CGPoint cellPoint = ccpMult([cell point], 32);
            [[cell walls] enumerateKeysAndObjectsUsingBlock:
                ^(id wallKey, id neighbor, BOOL *wallStop) {
                    CGPoint neighborPoint = ccpMult([neighbor point], 32);
                    CCSprite *wall = nil;
                    CGPoint wallPos = cellPoint;
                    if (neighborPoint.x < cellPoint.x) {
                        wall = [CCSprite spriteWithFile:@"vert.png"];
                        wallPos.x -= 16;
                    } else if (neighborPoint.x > cellPoint.x) {
                        wall = [CCSprite spriteWithFile:@"vert.png"];
                        wallPos.x += 16;
                    } else if (neighborPoint.y < cellPoint.y) {
                        wall = [CCSprite spriteWithFile:@"horiz.png"];
                        wallPos.y -= 16;
                    } else {
                        wall = [CCSprite spriteWithFile:@"horiz.png"];
                        wallPos.y += 16;
                    }
                    [wall setAnchorPoint:ccp(0.5, 0.5)];
                    [wall setPosition:wallPos];
                    [self addChild:wall];
                }
            ];
        }
    ];
    return self;
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

}
@end