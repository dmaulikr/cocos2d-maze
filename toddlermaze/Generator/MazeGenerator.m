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
    self.size = CGSizeMake(30, 20);
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

// create the grid and assign the grid neighbors
- (void)generate
{
    self.grid = [[[NSMutableDictionary alloc] initWithCapacity:(NSUInteger) (self.size.width * self.size.height)] autorelease];
    for (NSUInteger x = 0; x < self.size.width; x++) {
        for (NSUInteger y = 0; y < self.size.height; y++) {
            MazeCell *cell = [[[MazeCell alloc] initWithIndex:[self createIndex:ccp(x, y)]] autorelease];
            cell.point = ccp(x, y);
            [self.grid setObject:cell forKey:cell.index];
        }
    }
    for (NSUInteger x = 0; x < self.size.width; x++) {
        for (NSUInteger y = 0; y < self.size.height; y++) {
            [self addToNeighbors:[self.grid objectForKey:[self createIndex:ccp(x, y)]]];
        }
    }
    [self depthFirstSearch];
}

- (void)addToNeighbors:(MazeCell *)cell
{
    [[self.grid objectForKey:[self createIndex:ccpAdd(cell.point, kNorth)]] addNeighbor:cell];
    [[self.grid objectForKey:[self createIndex:ccpAdd(cell.point, kSouth)]] addNeighbor:cell];
    [[self.grid objectForKey:[self createIndex:ccpAdd(cell.point, kWest)]] addNeighbor:cell];
    [[self.grid objectForKey:[self createIndex:ccpAdd(cell.point, kEast)]] addNeighbor:cell];
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
    // over allocating a bit here - 50% of the grid is unlikely to end up in the stack
    NSMutableArray *stack = [[NSMutableArray alloc] initWithCapacity:(NSUInteger)((self.size.width * self.size.height) * 0.5)];
    NSMutableArray *neighbors = [[NSMutableArray alloc] initWithCapacity:8];
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

- (void)dealloc
{
    [_grid release];
    [super dealloc];
}
@end