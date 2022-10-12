//
//  VKMMPlaylistEntity.m
//  VKMedia
//
//  Created by Даниил on 09.09.17.
//
//

#import "VKMMPlaylistEntity.h"

@implementation VKMMPlaylistEntity

+ (NSFetchRequest<VKMMPlaylistEntity *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"VKMMPlaylistEntity"];
}

@dynamic iid;
@dynamic owner_id;
@dynamic update_date;
@dynamic create_date;
@dynamic audios;
@dynamic type;

- (NSNumber *)createTime
{
    return @(self.create_date.timeIntervalSince1970);
}

- (NSNumber *)updateTime
{
    return @(self.update_date.timeIntervalSince1970);
}

- (NSNumber *)count
{
    return @(self.audios.count);
}

@end
