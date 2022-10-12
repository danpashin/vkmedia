//
//  VKMMMainModel.h
//  VKMedia
//
//  Created by Даниил on 06.09.17.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "VKMethods.h"
#import <GCDWebServer.h>
#import <GCDWebServerDataResponse.h>

@interface VKMMMainModel : NSObject

+ (instancetype)sharedModel;

@property (strong, nonatomic) NSNumber *user_id;
@property (strong, nonatomic, readonly) GCDWebServer *webServer;
@property (strong, nonatomic, readonly) NSManagedObjectContext *context;

- (void)setupServer;
- (void)updateObjects;
- (void)save;

@end
