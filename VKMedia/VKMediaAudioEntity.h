//
//  VKMediaAudioEntity.h
//  VKMedia
//
//  Created by Даниил on 09.09.17.
//
//
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "VKMMUserEntity.h"


NS_ASSUME_NONNULL_BEGIN

@class VKMMPlaylistEntity;

@interface VKMediaAudioEntity : NSManagedObject

+ (NSFetchRequest<VKMediaAudioEntity *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *access_key;
@property (nullable, nonatomic, copy) NSDecimalNumber *duration;
@property (nullable, nonatomic, copy) NSDecimalNumber *genre_id;
@property (nullable, nonatomic, copy) NSDecimalNumber *iid;
@property (nonatomic) BOOL is_hq;
@property (nullable, nonatomic, copy) NSDecimalNumber *lyrics_id;
@property (nullable, nonatomic, copy) NSDecimalNumber *owner_id;
@property (nullable, nonatomic, copy) NSString *performer;
@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, retain) VKMMPlaylistEntity *playlist;

@end

NS_ASSUME_NONNULL_END
