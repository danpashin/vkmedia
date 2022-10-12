//
//  VKMMMainModel.m
//  VKMedia
//
//  Created by Даниил on 06.09.17.
//
//

#import "VKMMMainModel.h"
#import "PrefixHeader.h"

@interface VKMMMainModel ()
@end

@implementation VKMMMainModel

+ (instancetype)sharedModel
{
    static id instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _user_id = @0;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"VKMedia" withExtension:@"momd"];
            NSManagedObjectModel *objectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
            
            NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:objectModel];
            
            NSURL *databaseURL = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].lastObject;
            databaseURL = [databaseURL URLByAppendingPathComponent:@"VKMedia"];
            
            if (![databaseURL checkResourceIsReachableAndReturnError:nil]) {
                NSError *creatingError = nil;
                [[NSFileManager defaultManager] createDirectoryAtURL:databaseURL withIntermediateDirectories:NO attributes:nil error:&creatingError];
                VKMLog(@"Creating directories error: %@", creatingError);
            }
            databaseURL = [databaseURL URLByAppendingPathComponent:@"VKMedia.db"];
            
            NSError *databaseError = nil;
            [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:databaseURL options:nil error:&databaseError];
            
            if (databaseError) {
                VKMLog(@"Error while creating context: %@", databaseError.userInfo);
                [[NSFileManager defaultManager] removeItemAtURL:databaseURL error:nil];
//                abort();
            }
            
            _context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            self.context.persistentStoreCoordinator = coordinator;
            
            [self setupServer];
            [self updateObjects];
        });
    }
    return self;
}

- (void)setupServer
{    
    _webServer = [[GCDWebServer alloc] init];
    
    [self.webServer start];
}

- (void)save
{
    if (self.context.hasChanges) {
        [self.context performBlockAndWait:^{
            NSError *saveError = nil;
            [self.context save:&saveError];
            [self updateObjects];
            
            if (saveError) {
                VKMLog(@"error while saving: %@", saveError.userInfo);
            }
        }];
    }
}

- (void)updateObjects
{
    
}

- (void)setUser_id:(NSNumber *)user_id
{
    _user_id = user_id;
    
    [self updateObjects];
}

@end
