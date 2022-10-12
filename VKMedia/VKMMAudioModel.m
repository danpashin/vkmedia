//
//  VKMMMainModel.m
//  VKMedia
//
//  Created by Даниил on 06.09.17.
//
//

#import "VKMMAudioModel.h"

#import "PrefixHeader.h"
#import "VKMMPlaylistEntity.h"

#import <GCDWebServer.h>
#import <GCDWebServerDataResponse.h>
#import <GCDWebServerFileResponse.h>
#import <GCDWebServerErrorResponse.h>
#import "AFNetworkReachabilityManager.h"

@interface VKMMAudioModel ()
@property (strong, nonatomic) VKMMPlaylistEntity *playlist;
@end


@implementation VKMMAudioModel

- (void)setupServer
{
    [super setupServer];
    
    [self.webServer addDefaultHandlerForMethod:@"GET" requestClass:[GCDWebServerRequest class] processBlock:^GCDWebServerResponse * _Nullable(__kindof GCDWebServerRequest * _Nonnull request) {
        
        NSString *filePath = [NSString stringWithFormat:@"%@/Documents/VKMedia%@", NSHomeDirectory(), request.path];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            VKMLog(@"File not found. Path: '%@'", filePath);
            return [GCDWebServerErrorResponse responseWithClientError:kGCDWebServerHTTPStatusCode_NotFound message:@"%@", [NSHTTPURLResponse localizedStringForStatusCode:404]];
        }
        
        GCDWebServerFileResponse *response = [GCDWebServerFileResponse responseWithFile:filePath isAttachment:YES];
        
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        if (attributes.count > 0) {
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"E, d MMM yyyy HH:mm:ss zzz";
            dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en-US"];
            
            NSDate *fileModificationDate = attributes[NSFileModificationDate];
            NSString *fileModificationString = [dateFormatter stringFromDate:fileModificationDate];
            
            NSMutableString *hexModString = [NSMutableString stringWithFormat:@"%@", @(fileModificationDate.timeIntervalSince1970)];
            while (hexModString.length != 16) {
                [hexModString appendString:@"0"];
            }
            NSString *etag = [NSString stringWithFormat:@"\"0x%@X-0x%@X\"", @(response.contentLength), @(hexModString.integerValue)].lowercaseString;
            etag = [etag stringByReplacingOccurrencesOfString:@"0x" withString:@""];
            
            [response setValue:etag forAdditionalHeader:@"ETag"];
            [response setValue:fileModificationString forAdditionalHeader:@"Last-Modified"];
        }
        
        [response setValue:@"bytes" forAdditionalHeader:@"Accept-Ranges"];
        [response setValue:@"keep-alive" forAdditionalHeader:@"Connection"];
        [response setValue:@"VKMedia/0.2-alpha GCDWebServer/3.4.1" forAdditionalHeader:@"Server"];
        [response setValue:@"timeout=30" forAdditionalHeader:@"Keep-Alive"];
        response.cacheControlMaxAge = 10000;
        
        return response;
    }];
    
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager startMonitoring];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        [self updateObjects];
    }];
}


- (void)addAudio:(VKAudio *)audio
{
    NSFetchRequest *request = [VKMediaAudioEntity fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"iid == %@", audio.iden.iid];
    
    NSArray *resultArray = [self.context executeFetchRequest:request error:nil];
    if (resultArray.count > 0)
        return;
    
    self.playlist.update_date = [NSDate date];
    
    VKMediaAudioEntity *audioEntity = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([VKMediaAudioEntity class]) 
                                                                    inManagedObjectContext:self.context];
    audioEntity.access_key = audio.iden.access_key;
    audioEntity.owner_id = [NSDecimalNumber decimalNumberWithDecimal:audio.iden.oid.decimalValue];
    audioEntity.iid = [NSDecimalNumber decimalNumberWithDecimal:audio.iden.iid.decimalValue];
    audioEntity.lyrics_id = [NSDecimalNumber decimalNumberWithDecimal:audio.lyrics_id.decimalValue];
    audioEntity.genre_id = [NSDecimalNumber decimalNumberWithDecimal:audio.track_genre_id.decimalValue];
    audioEntity.duration = [NSDecimalNumber decimalNumberWithDecimal:@(audio.duration).decimalValue];
    audioEntity.is_hq = audio.hq;
    audioEntity.title = audio.title;
    audioEntity.performer = audio.performer;
    audioEntity.playlist = self.playlist;
    
    [self save];
}

- (BOOL)isAudioDownloaded:(VKAudio *)audio
{
    NSSet *audiosSet = [self.playlist.audios filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"iid == %@", audio.iden.iid]];
    
    return (audiosSet.count > 0);
}

- (void)updateObjects
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self updatePlaylist];
        
        NSMutableArray *allAudios = [NSMutableArray array];
        for (VKMediaAudioEntity *entity in self.playlist.audios.allObjects) {
            [allAudios addObject:[self parseAudioEntity:entity]];
        }
        
        NSDictionary *userInfo = @{@"first_name":@"", @"id":self.user_id, @"last_name":@""};
        
        _playlist_json = @{@"count":self.playlist.count, @"create_time":self.playlist.createTime, @"owner_id":self.user_id, 
                           @"title": @"Загруженные", @"id": self.playlist_id, @"type": @0, @"update_time": self.playlist.updateTime,
                           @"plays": @0, @"genres":@[], @"followers":@0, @"description":@"", @"artists":@[], @"photo": @{
                               @"height": @600,
                               @"photo_600": @"https://pp.userapi.com/c836133/v836133037/4b35e/daaVPhMe_l4.jpg",
                               @"width": @600
                           }
                           };
        
        _objects_json = @{@"response":@{@"audios":@{@"count":self.playlist.count, @"items":allAudios}, @"playlist":self.playlist_json, @"user":userInfo}};
        
        VKMLog(@"audios updated");
    });
}

- (void)updatePlaylist
{        
    NSFetchRequest *playlistRequest = [VKMMPlaylistEntity fetchRequest];
    playlistRequest.predicate = [NSPredicate predicateWithFormat:@"type == %@", @"audio"];
    
    NSArray <VKMMPlaylistEntity *> *playlistArray = [self.context executeFetchRequest:playlistRequest error:nil];
    
    if (playlistArray.count > 0) {
        if (self.playlist)
            [self.context refreshObject:self.playlist mergeChanges:YES];
        else
            self.playlist = playlistArray.firstObject;
    } else {
        self.playlist = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([VKMMPlaylistEntity class]) 
                                                      inManagedObjectContext:self.context];
        self.playlist.iid = [NSDecimalNumber decimalNumberWithDecimal:@(NSIntegerMax).decimalValue];
        self.playlist.type = @"audio";
        self.playlist.create_date = [NSDate date];
        self.playlist.update_date = self.playlist.create_date;
    }
}

- (NSDictionary *)parseAudioEntity:(VKMediaAudioEntity *)entity
{
    NSMutableDictionary *audio = [NSMutableDictionary dictionary];
    audio[@"access_key"] = entity.access_key;
    audio[@"artist"] = entity.performer;
    audio[@"date"] = @2000000000;
    audio[@"duration"] = entity.duration;
    audio[@"genre_id"] = entity.genre_id;
    audio[@"id"] = entity.iid;
    audio[@"is_hq"] = @(entity.is_hq);
    audio[@"is_licensed"] = @1;
    audio[@"lyrics_id"] = entity.lyrics_id;
    audio[@"owner_id"] = entity.owner_id;
    audio[@"title"] = entity.title;
    audio[@"album_id"] = self.playlist.iid;
    
    NSURL *serverURL = self.webServer.serverURL ? self.webServer.serverURL : [NSURL URLWithString:[NSString stringWithFormat:@"http://127.0.0.1:%@/", @(self.webServer.port)]];
    audio[@"url"] = [NSString stringWithFormat:@"%@%@.mp3", serverURL, entity.iid];
    
//    audio[@"url"] = @"https://cs9-19v4.userapi.com/p2/5e8f5e554ded9b.mp3?extra=hUM0dqkBWG8xbxnfuql7okEMLoMlkvBk5AJcGHsXHdJfW9mAxtFXCslYrMEAsVOycTuqukWTNKttK7mJYZn7o6JXPZ9KMJvg3OFXf9ERUBxab9BIdRxvwciQeCPRRAFcB5fl2GSXI5Jz0w";
    
//    audio[@"url"] = @"http://danpashin.ru/456239825.mp3";
//    audio[@"url"] = @"http://192.168.31.42/456239825.mp3";
    
    return audio;
}

- (void)setUser_id:(NSNumber *)user_id
{
    [super setUser_id:user_id];
    
    self.playlist.owner_id = [NSDecimalNumber decimalNumberWithDecimal:user_id.decimalValue];
}

- (NSNumber *)playlist_id
{
    return self.playlist.iid;
}

@end
