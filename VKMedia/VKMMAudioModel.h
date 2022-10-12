//
//  VKMMMainModel.h
//  VKMedia
//
//  Created by Даниил on 06.09.17.
//
//

#import "VKMMMainModel.h"

@interface VKMMAudioModel : VKMMMainModel

@property (strong, nonatomic, readonly) NSDictionary *objects_json;
@property (strong, nonatomic, readonly) NSDictionary *playlist_json;
@property (strong, nonatomic, readonly) NSNumber *playlist_id;

- (void)addAudio:(VKAudio *)audio;
- (BOOL)isAudioDownloaded:(VKAudio *)audio;

@end
