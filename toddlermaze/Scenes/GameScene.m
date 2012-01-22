//
// @author Jonny Brannum <jonny.brannum@gmail.com> 
//         1/21/12
//

#import "GameScene.h"
#import "MazeGenerator.h"
#import "GameLayer.h"

@implementation GameScene
- (id)init
{
    self = [super init];
    [self addChild:[[[GameLayer alloc] init] autorelease]];
    return self;
}
@end