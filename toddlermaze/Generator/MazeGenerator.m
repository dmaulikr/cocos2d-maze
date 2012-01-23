//
// @author Jonny Brannum <jonny.brannum@gmail.com> 
//         1/21/12
//

#import "MazeGenerator.h"
#import "CGPointExtension.h"
#import "CCActionInterval.h"
#import "MazeCell.h"

@interface MazeGenerator ()
@property (nonatomic, assign) float complexity;
@property (nonatomic, assign) float density;
@property (nonatomic, assign) NSUInteger visited;
@end

@implementation MazeGenerator
@synthesize size       = _size;
@synthesize complexity = _complexity;
@synthesize density    = _density;
@synthesize grid       = _grid;
@synthesize visited    = _visited;

- (id)init
{
    self = [super init];
    self.size = CGSizeMake(900, 600);
    self.complexity = 0.5f;
    self.density = 0.5f;
    self.visited = 0;
    [self generateGrid];
    return self;
}

- (NSNumber *)createIndex:(CGPoint)position
{
    return [NSNumber numberWithFloat:position.x + position.y * self.size.width];
}

// create the grid and assign the grid neighbors
- (void)generateGrid
{
    self.grid = [[[NSMutableDictionary alloc] initWithCapacity:(NSUInteger) (self.size.width * self.size.height / 32)] autorelease];
    for (NSUInteger x = 0; x <= self.size.width; x+=32) {
        for (NSUInteger y = 0; y <= self.size.height; y+=32) {
            MazeCell *cell = [[[MazeCell alloc] initWithIndex:[self createIndex:ccp(x, y)]] autorelease];
            [cell setPosition:ccp(x, y)];
            [self.grid setObject:cell forKey:cell.index];
        }
    }
    for (NSUInteger x = 0; x <= self.size.width; x+=32) {
        for (NSUInteger y = 0; y <= self.size.height; y+=32) {
            [self addToNeighbors:[self.grid objectForKey:[self createIndex:ccp(x, y)]]];
        }
    }
}

- (void)addToNeighbors:(MazeCell *)cell
{
    [[self.grid objectForKey:[self createIndex:ccpAdd(cell.position, kNorth)]] addNeighbor:cell];
    [[self.grid objectForKey:[self createIndex:ccpAdd(cell.position, kSouth)]] addNeighbor:cell];
    [[self.grid objectForKey:[self createIndex:ccpAdd(cell.position, kWest)]] addNeighbor:cell];
    [[self.grid objectForKey:[self createIndex:ccpAdd(cell.position, kEast)]] addNeighbor:cell];
}

- (void)createUsingDepthFirstSearch
{
    // we are going to iterate till every cell has been visited
    NSUInteger count = [self.grid count];
    // get a random cell in the grid
    MazeCell *currentCell = nil;
    NSEnumerator *cellEnumerator = [self.grid objectEnumerator];
    NSInteger randomCell = arc4random() % (count-1);
    do {
        currentCell = [cellEnumerator nextObject];
        randomCell--;
    } while(randomCell > 0);
    self.visited++;
    currentCell.visited = YES;
    // save some allocations
    NSMutableArray *stack = [[NSMutableArray alloc] initWithCapacity:32];
    NSMutableArray *neighbors = [[NSMutableArray alloc] initWithCapacity:4];
    // iterate till every cell has been visited
    while (self.visited < count) {
        // grab each neighbor of our current cell
        [currentCell.neighbors enumerateKeysAndObjectsUsingBlock:
            ^(id key, id neighbor, BOOL *stop) {
                // grab a neighbor and add it to the neighbors array
                if ([neighbor visited] != YES) {
                    [neighbors addObject:neighbor];
                }
            }
        ];
        if (neighbors.count) {
            // if there is a current neighbor that has not been visited, we are switching currentCell to one of them
            [stack addObject:currentCell];
            // get a random neighbor cell
            MazeCell *neighborCell = [neighbors objectAtIndex:arc4random() % neighbors.count];
            neighborCell.visited = YES;
            self.visited++;
            // knock down the walls!
            [neighborCell removeWall:currentCell];
            [currentCell removeWall:neighborCell];
            // update our current cell to be the newly selected cell
            currentCell = neighborCell;
        } else {
            // "pop" the top cell off the stack to resume a previously started trail
            currentCell = [stack objectAtIndex:stack.count - 1];
            [stack removeObjectAtIndex:stack.count - 1];
        }
        // cleanup
        [neighbors removeAllObjects];
    }

    // final cleanup
    [neighbors release];
    [stack release];
}

- (void)searchUsingAStar:(CGPoint)start endingAt:(CGPoint)end movingEntity:(CCSprite *)entity
{

}

- (void)searchUsingDepthFirstSearch:(CGPoint)start endingAt:(CGPoint)end movingEntity:(CCSprite *)entity
{
    __block float distance = INFINITY;
    __block NSNumber *index = nil;
    __block float endDistance = INFINITY;
    __block NSNumber *endIndex = nil;
    [self.grid enumerateKeysAndObjectsUsingBlock:
        ^(id key, id cell, BOOL *stop) {
            MazeCell *mazeCell = (MazeCell *)cell;
            mazeCell.visited = NO;
            float curDistance = ccpDistance(start, mazeCell.position);
            if (curDistance < distance) {
                distance = curDistance;
                index = [cell index];
            }

            float curEndDistance = ccpDistance(end, mazeCell.position);
            if (curEndDistance < endDistance) {
                endDistance = curEndDistance;
                endIndex = [cell index];
            }
        }
    ];

    MazeCell *currentCell = [self.grid objectForKey:index];
    if (currentCell == nil) {
        return;
    }
    MazeCell *endCell = [self.grid objectForKey:endIndex];
    if (endCell == nil) {
        return;
    }
    NSMutableArray *actions = [NSMutableArray arrayWithCapacity:10];
    BOOL found = NO;
    BOOL impossible = NO;
    NSMutableArray *stack = [[NSMutableArray alloc] initWithCapacity:10];
    NSMutableArray *neighbors = [[NSMutableArray alloc] initWithCapacity:4];
    BOOL stackPopped = NO;
    while (!found && !impossible) {
        __block MazeCell *neighborCell = nil;
        // grab each neighbor of our current cell
        [currentCell.neighbors enumerateKeysAndObjectsUsingBlock:
                ^(id key, id neighbor, BOOL *stop) {
                    // grab a neighbor and add it to the neighbors array
                    if ([neighbor visited] != YES && [currentCell wallForNeighbor:neighbor] == nil) {
                        neighborCell = neighbor;
                        *stop = YES;
                    }
                }
        ];
        if (neighborCell) {
            // if there is a current neighbor that has not been visited, we are switching currentCell to one of them
            [stack addObject:currentCell];
            neighborCell.visited = YES;
            // move to neighbor
            if (stackPopped == NO) {
                [actions addObject:[CCMoveTo actionWithDuration:0.2f position:neighborCell.position]];
            } else {
                [actions addObject:[CCFadeOut actionWithDuration:0.1f]];
                [actions addObject:[CCMoveTo actionWithDuration:0.f position:currentCell.position]];
                [actions addObject:[CCFadeIn actionWithDuration:0.1f]];
                [actions addObject:[CCMoveTo actionWithDuration:0.2f position:neighborCell.position]];
            }
            if (CGPointEqualToPoint(neighborCell.position, endCell.position)) {
                found = YES;
                break;
            }
            // update our current cell to be the newly selected cell
            currentCell = neighborCell;
            stackPopped = NO;
        } else {
            stackPopped = YES;
            if (stack.count == 0) {
                impossible = YES;
                break;
            }
            // "pop" the top cell off the stack to resume a previously started trail
            currentCell = [stack objectAtIndex:stack.count - 1];
            [stack removeObjectAtIndex:stack.count - 1];
        }
    }
    [neighbors release];
    [stack release];
    if (found) {
        id sequence = [CCSequence actionsWithArray:actions];
        [entity runAction:sequence];
    }
}

- (void)dealloc
{
    [_grid release];
    [super dealloc];
}
@end