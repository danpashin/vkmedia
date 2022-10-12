//
//  VKMMUserEntity.m
//  VKMedia
//
//  Created by Даниил on 09.09.17.
//
//

#import "VKMMUserEntity.h"

@implementation VKMMUserEntity

+ (NSFetchRequest<VKMMUserEntity *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"VKMMUserEntity"];
}

@dynamic first_name;
@dynamic iid;
@dynamic last_name;

@end
