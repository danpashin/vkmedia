//
//  VKMMUserEntity.h
//  VKMedia
//
//  Created by Даниил on 09.09.17.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


NS_ASSUME_NONNULL_BEGIN

@interface VKMMUserEntity : NSManagedObject

+ (NSFetchRequest<VKMMUserEntity *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *first_name;
@property (nullable, nonatomic, copy) NSDecimalNumber *iid;
@property (nullable, nonatomic, copy) NSString *last_name;

@end

NS_ASSUME_NONNULL_END
