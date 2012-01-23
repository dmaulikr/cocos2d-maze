//
// @author Jonny Brannum <jonny.brannum@gmail.com> 
//         1/22/12
//

#import "Entity.h"
#import "CCActionInterval.h"
#import "CGPointExtension.h"
#import "CCActionGrid3D.h"

static const float indexMultiplier = 20.f;

@interface Entity ()
@property (nonatomic, retain) NSMutableDictionary *currentEntities;
@property (nonatomic, retain) NSMutableDictionary *cancelledEntities;
@end

@implementation Entity
@synthesize currentEntities = _currentEntities;
@synthesize cancelledEntities = _cancelledEntities;


- (id)init
{
    self = [super init];
    CCSprite *glow = [CCSprite spriteWithFile:@"entity.png"];
    [glow setBlendFunc: (ccBlendFunc) { GL_SRC_ALPHA, GL_ONE }];
    id sequence = [CCSequence actions:
        [CCFadeTo actionWithDuration:0.5f opacity:100],
        [CCFadeTo actionWithDuration:0.5f opacity:255],
        nil
    ];
    [glow runAction:[CCRepeatForever actionWithAction:sequence]];
    [glow setPosition:ccp(glow.textureRect.size.width/2, glow.textureRect.size.height/2)];
    [self addChild:glow];
    self.currentEntities = [NSMutableDictionary dictionaryWithCapacity:20];
    self.cancelledEntities = [NSMutableDictionary dictionaryWithCapacity:20];
    return self;
}

- (void)beginMovement
{
    [self stopAllActions];
    [_currentEntities enumerateKeysAndObjectsUsingBlock:
        ^(id key, id sprite, BOOL *stop) {
            [self.parent removeChild:sprite cleanup:YES];
        }
    ];
    [_currentEntities removeAllObjects];
    
    [_cancelledEntities enumerateKeysAndObjectsUsingBlock:
        ^(id key, id sprite, BOOL *stop) {
            [self.parent removeChild:sprite cleanup:YES];
        }
    ];
    [_cancelledEntities removeAllObjects];
}

- (void)dropCurrent:(id)node
{
    CCSprite *current = [CCSprite spriteWithFile:@"entity.png"];
    [current setColor:ccBLUE];
    [current setPosition:[node position]];
    [_currentEntities setObject:current forKey:[NSNumber numberWithFloat:current.position.x + current.position.y * indexMultiplier]];
    [self.parent addChild:current];
}

- (void)dropCancelled:(id)node
{
    CGPoint pos = [node position];
    NSNumber *key = [NSNumber numberWithFloat:pos.x + pos.y * indexMultiplier];
    CCSprite *current = [_currentEntities objectForKey:key];
    [self.parent removeChild:current cleanup:YES];
    [_currentEntities removeObjectForKey:key];
    CCSprite *cancelled = [CCSprite spriteWithFile:@"entity.png"];
    [cancelled setColor:ccc3(100, 100, 100)];
    [cancelled setPosition:pos];
    [_cancelledEntities setObject:cancelled forKey:key];
    [self.parent addChild:cancelled];
}

- (void)dealloc {
    [_currentEntities release];
    [_cancelledEntities release];
    [super dealloc];
}

@end