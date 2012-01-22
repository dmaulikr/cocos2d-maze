//
// @author Jonny Brannum <jonny.brannum@gmail.com> 
//         1/21/12
//

#import "MazeGenerator.h"
#import "CGPointExtension.h"

@implementation MazeCell
@synthesize index     = _index;
@synthesize point     = _point;
@synthesize visited   = _visited;
@synthesize neighbors = _neighbors;
@synthesize walls      = _walls;

- (id)initWithIndex:(NSNumber *)index
{
    self = [super init];
    self.index = index;
    self.visited = NO;
    self.neighbors = [[[NSMutableDictionary alloc] initWithCapacity:4] autorelease];
    self.walls = [[[NSMutableDictionary alloc] initWithCapacity:4] autorelease];
    return self;
}

- (void)addNeighbor:(MazeCell *)neighbor
{
    [self.neighbors setObject:neighbor forKey:neighbor.index];
    // by default all neighbors have walls in DFS
    // TODO: Determine if we are doing DFS before adding walls
    [self.walls setObject:neighbor forKey:neighbor.index];
}

- (void)removeWall:(MazeCell *)neighbor
{
    [self.walls removeObjectForKey:neighbor.index];
    [neighbor.walls removeObjectForKey:self.index];
}

- (void)dealloc
{
    [_neighbors release];
    [_walls release];
    [_index release];
    [super dealloc];
}
@end

@interface MazeGenerator ()
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) float complexity;
@property (nonatomic, assign) float density;
@property (nonatomic, assign) CGPoint start;
@property (nonatomic, assign) CGPoint end;
@property (nonatomic, retain) NSMutableDictionary *grid;
@property (nonatomic, assign) NSUInteger visited;
@end

@implementation MazeGenerator
@synthesize size       = _size;
@synthesize complexity = _complexity;
@synthesize density    = _density;
@synthesize start      = _start;
@synthesize end        = _end;
@synthesize grid       = _grid;
@synthesize visited    = _visited;


- (id)init
{
    self = [super init];
    self.size = CGSizeMake(768 * 0.1f, 1024 * 0.1f);
    self.complexity = 0.5f;
    self.density = 0.5f;
    self.visited = 0;
    [self generate];
    return self;
}

- (NSNumber *)createIndex:(CGPoint)point
{
    return [NSNumber numberWithFloat:point.x + point.y * self.size.width];
}

- (void)generate
{
    self.grid = [[[NSMutableDictionary alloc] initWithCapacity:(NSUInteger) (self.size.width * self.size.height)] autorelease];
    for (NSUInteger x = 0; x < self.size.width; x++) {
        for (NSUInteger y = 0; y < self.size.height; y++) {
            MazeCell *cell = [[[MazeCell alloc] initWithIndex:[self createIndex:ccp(x, y)]] autorelease];
            cell.point = ccp(x, y);
            [self addToNeighbors:cell];
            [self.grid setObject:cell forKey:cell.index];
        }
    }
    [self depthFirstSearch];
}

- (void)addToNeighbors:(MazeCell *)cell
{
    for (int x = -1; x < 2; x++) {
        for (int y = -1; y < 2; y++) {
            // don't add ourselves as a neighbor
            if (y == 0 && x == 0) {
                continue;
            }
            // get the neighbor from the grid
            MazeCell *neighbor = [self.grid objectForKey:[self createIndex:ccpAdd(cell.point, ccp(x, y))]];
            if (neighbor == nil) {
                continue;
            }
            // add the cell as a neighbor of the neighbor
            [neighbor addNeighbor:cell];
        }        
    }
}

- (void)depthFirstSearch
{
    // we are going to iterate till every cell has been visited
    NSUInteger count = [self.grid count];
    // get a random cell in the grid
    MazeCell *currentCell = [self.grid objectForKey:[self createIndex:ccp(arc4random() % (int)self.size.width, arc4random() % (int)self.size.height)]];
    self.visited++;
    currentCell.visited = YES;
    // save some allocations
    NSInteger x = 0, y = 0;
    // over allocating a bit here - 50% of the grid is unlikely to end up in the stack
    NSMutableArray *stack = [[NSMutableArray alloc] initWithCapacity:(NSUInteger)((self.size.width * self.size.height) * 0.5)];
    NSMutableArray *neighbors = [[NSMutableArray alloc] initWithCapacity:8];
    // iterate till every cell has been visited
    while (self.visited < count) {
        // grab each neighbor of our current cell
        for (x = -1; x < 2; x++) {
            for (y = -1; y < 2; y++) {
                // skip our self
                if (y == 0 && x == 0) {
                    continue;
                }
                // grab a neighbor and add it to the neighbors array
                MazeCell *neighbor = [self.grid objectForKey:[self createIndex:ccpAdd(currentCell.point, ccp(x, y))]];
                if (neighbor == nil || neighbor.visited == YES) {
                    continue;
                }
                [neighbors addObject:neighbor];
            }
        }
        if (neighbors.count) {
            // if there is a current neighbor that has not been visited, we are switching currentCell to one of them
            [stack addObject:currentCell];
            // get a random neighbor
            NSUInteger newCell = arc4random() % neighbors.count;
            currentCell = [neighbors objectAtIndex:newCell];
            // we've visited it
            currentCell.visited = YES;
            // knock down the walls!
            [currentCell removeWall:[stack objectAtIndex:stack.count - 1]];
            self.visited++;
        } else {
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

- (void)dealloc
{
    [_grid release];
    [super dealloc];
}
@end