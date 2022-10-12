//
//  VKMedia.m
//  VKMedia
//
//  Created by Даниил on 06.09.17.
//
//

#import <Foundation/Foundation.h>
#import "CaptainHook.h"
#import "VKMethods.h"
#import "PrefixHeader.h"
#import <dlfcn.h>

#import "VKMMDownloadController.h"
#import "VKMMAudioModel.h"


static VKMMDownloadController *downloadController;
static VKMMAudioModel *audioModel;



CHDeclareClass(AudioCell);
CHDeclareMethod(0, void, AudioCell, layoutSubviews)
{
    CHSuper(0, AudioCell, layoutSubviews);
    
    VKMMDownloadButton *downloadButton = [downloadController buttonForAudio:self.audio];
    
    if (!downloadButton) {
        downloadButton = [[VKMMDownloadButton alloc] init];
        downloadButton.audio = self.audio;
        downloadButton.downloadController = downloadController;
        downloadButton.delegate = downloadController;
    }
    
    downloadButton.audioDownloaded = [audioModel isAudioDownloaded:self.audio];
    [downloadButton addToCell:self];
}

CHDeclareMethod(0, void, AudioCell, prepareForReuse)
{
    CHSuper(0, AudioCell, prepareForReuse);
    
    for (UIView *subview in self.contentView.subviews) {
        if ([subview isKindOfClass:[VKMMDownloadButton class]]) {
            [subview removeFromSuperview];
            break;
        }
    }
}


CHDeclareClass(AFJSONRequestOperation);
CHDeclareMethod(0, id, AFJSONRequestOperation, responseJSON)
{
    NSDictionary *responseJSON = CHSuper(0, AFJSONRequestOperation, responseJSON);
    
    NSString *patternString = [NSString stringWithFormat:@"playlist_id=%@", audioModel.playlist_id];
    if ([self.request.URL.absoluteString containsString:patternString]) {
        responseJSON = audioModel.objects_json;
    }
    else if ([self.request.URL.absoluteString containsString:@"playlists%3AAPI.audio.getPlaylists"]) {
        
        if (responseJSON && responseJSON[@"response"]) {
            NSMutableDictionary *newResponse = [responseJSON[@"response"] mutableCopy];
            
            if (newResponse[@"playlists"]) {
                NSMutableDictionary *playlists = [newResponse[@"playlists"] mutableCopy];
                
                playlists[@"count"] = @([playlists[@"count"] integerValue] + 1);            
                
                NSMutableArray *items = playlists[@"items"] ? [playlists[@"items"] mutableCopy] : [NSMutableArray array];
                [items addObject:audioModel.playlist_json];
                
                playlists[@"items"] = [items copy];
                newResponse[@"playlists"] = [playlists copy];
                
                responseJSON = @{@"response":newResponse};
            }
        } else {
            responseJSON = @{@"response": @{
                                     @"audios":@{@"count":@0, @"items":@{}}, 
                                     @"playlists": @{
                                             @"count":@1, 
                                             @"items": @[audioModel.playlist_json], 
                                             @"profiles":@[ @{ 
                                                                @"id": audioModel.user_id,
                                                                @"first_name": @"",
                                                                @"last_name": @"",
                                                                @"online": @0
                                                                }
                                                     ]
                                             }
                                     }};
        }
    }
    
    return responseJSON;
}

CHDeclareMethod(0, NSHTTPURLResponse *, AFJSONRequestOperation, response)
{
    NSHTTPURLResponse *response = CHSuper(0, AFJSONRequestOperation, response);
    
    NSString *patternString = [NSString stringWithFormat:@"playlist_id=%@", audioModel.playlist_id];
    if (!response && ([self.request.URL.absoluteString containsString:patternString]|| [self.request.URL.absoluteString containsString:@"audio.getPlaylists"])) {
        VKMLog(@"Return fake NSHTTPURLResponse");
        
        NSDictionary *headers = @{@"Cache-Control": @"no-store", @"Connection": @"keep-alive", @"Content-Encoding": @"gzip", @"Content-Length": @"0",
                                  @"Date": @"Sun, 10 Sep 2017 08:07:22 GMT", @"Pragma": @"no-cache", @"Server": @"ngix", 
                                  @"X-Powered-By": @"PHP/3.13596", @"Content-Type": @"application/json; charset=utf-8"};
        response = [[NSHTTPURLResponse alloc] initWithURL:self.request.URL statusCode:200 HTTPVersion:@"" headerFields:headers];
    }
    
    return response;
}

CHDeclareMethod(0, NSError *, AFJSONRequestOperation, error)
{
    NSError *error = CHSuper(0, AFJSONRequestOperation, error);
    
    NSString *patternString = [NSString stringWithFormat:@"playlist_id=%@", audioModel.playlist_id];
    if (error && ([self.request.URL.absoluteString containsString:patternString] || [self.request.URL.absoluteString containsString:@"audio.getPlaylists"])) {
        VKMLog(@"Return nil error for AFJSONRequestOperation");
        error = nil;
    }
    
    return error;
}

CHDeclareClass(VKSession);
CHDeclareMethod(0, NSNumber *, VKSession, userId)
{
    NSNumber *userId = CHSuper(0, VKSession, userId);
    if (audioModel.user_id != userId)
        audioModel.user_id = userId;
    
    return userId;
}

//CHDeclareClass(NSHTTPURLResponse);
//CHDeclareMethod(0, NSInteger, NSHTTPURLResponse, statusCode)
//{
//    NSInteger statusCode = CHSuper(0, NSHTTPURLResponse, statusCode);
//    
//    VKMLog(@"%@", self.allHeaderFields);
//    
//    return statusCode;
//}


CHConstructor
{
    @autoreleasepool {
        audioModel = [[VKMMAudioModel alloc] init];
        
        downloadController = [[VKMMDownloadController alloc] init];
        downloadController.audioModel = audioModel;
        
//        dlopen([[NSBundle mainBundle] pathForResource:@"FLEXDylib" ofType:@"dylib"].UTF8String, RTLD_NOW);        

    }
}
