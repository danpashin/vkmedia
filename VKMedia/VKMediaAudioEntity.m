//
//  VKMediaAudioEntity.m
//  VKMedia
//
//  Created by Даниил on 06.09.17.
//
//

#import "VKMediaAudioEntity.h"

@implementation VKMediaAudioEntity

+ (NSFetchRequest<VKMediaAudioEntity *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"VKMediaAudioEntity"];
}

@dynamic access_key;
@dynamic duration;
@dynamic genre_id;
@dynamic iid;
@dynamic is_hq;
@dynamic lyrics_id;
@dynamic owner_id;
@dynamic performer;
@dynamic title;
@dynamic playlist;

@end
