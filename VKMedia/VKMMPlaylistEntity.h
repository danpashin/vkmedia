//
//  VKMMPlaylistEntity+CoreDataProperties.h
//  VKMedia
//
//  Created by Даниил on 09.09.17.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "VKMediaAudioEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface VKMMPlaylistEntity : NSManagedObject

+ (NSFetchRequest<VKMMPlaylistEntity *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDecimalNumber *iid;
@property (nullable, nonatomic, copy) NSDecimalNumber *owner_id;
@property (nullable, nonatomic, copy) NSDate *update_date;
@property (nullable, nonatomic, copy) NSDate *create_date;
@property (nullable, nonatomic, retain) NSSet<VKMediaAudioEntity *> *audios;
@property (nullable, nonatomic, copy) NSString *type;

@property (assign, nonatomic, readonly) NSNumber *createTime;
@property (assign, nonatomic, readonly) NSNumber *updateTime;
@property (strong, nonatomic, readonly) NSNumber *count;

@end

NS_ASSUME_NONNULL_END
