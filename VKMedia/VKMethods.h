//
//  VKMethods.h
//  VKMedia
//
//  Created by Даниил on 06.09.17.
//  
//
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@class VKAudio;
@interface VKAudioQueuePlayer : NSObject
@property(retain, nonatomic) NSURLSessionDataTask *coverDownloadTask;
@property(retain, nonatomic) NSMutableDictionary *nowPlayingInfo;
@property(nonatomic) BOOL wantToPlay;
@property(nonatomic) BOOL active;
@property(nonatomic) BOOL needResume;
@property(nonatomic) int state;
//@property(retain, nonatomic) VKAudioQueuePlayerItem *currentPlayerItem;
@property(retain, nonatomic) AVQueuePlayer *avPlayer;
@property (nonatomic, readonly, strong) VKAudio *currentAudio;
@property (nonatomic, readonly, strong) NSString * currentPlayer;
@property (nonatomic, readonly, strong) NSString * title;
@property (nonatomic, readonly, strong) NSString *performer;
@property (nonatomic, readonly) BOOL showCover;
@property (nonatomic, readonly) BOOL canSkip;
@property (nonatomic, readonly) BOOL canSeek;
@property (nonatomic, getter=isPlayingAd, readonly) BOOL playingAd;
@property (nonatomic, getter=isPlayingOrPausedAd, readonly) BOOL playingOrPausedAd;
@property (nonatomic, getter=isPlayingOrPaused, readonly) BOOL playingOrPaused;
@property (nonatomic, getter=isPlaying, readonly) BOOL playing;
- (BOOL)isCurrentItem:(id)arg1;
- (BOOL)isPlayingItem:(id)arg1;
- (BOOL)isCurrentAudio:(id)arg1;
- (BOOL)isPlayingAudio:(id)arg1;
@end


@interface VKIdentity : NSObject
@property(retain, nonatomic) NSString *access_key;
@property(retain, nonatomic) NSNumber *iid;
@property(retain, nonatomic) NSNumber *oid;
@end


@interface VKRenderable : NSObject
@end
@interface VKDomain : VKRenderable
@property(retain, nonatomic) VKIdentity *iden;
@end
@interface VKAudio : VKDomain
@property(nonatomic) BOOL added;
@property(nonatomic, getter=isHQ) BOOL hq;
//@property(retain, nonatomic) VKAudioPlaylistAlbum *album;
@property(retain, nonatomic) NSNumber *track_genre_id;
@property(retain, nonatomic) NSString *content_restricted_url;
@property(retain, nonatomic) NSString *content_restricted_message;
@property(nonatomic) BOOL content_restricted;
@property(retain, nonatomic) NSNumber *lyrics_id;
@property(retain, nonatomic) NSString *url;
@property(nonatomic) int duration;
@property(retain, nonatomic) NSString *title;
@property(retain, nonatomic) NSString *performer;
@end


@interface VKMCell : UITableViewCell
@end
@interface AudioCellBase : VKMCell
@end
@interface AudioCellPlayableBase : AudioCellBase
@end
@interface AudioCellPlayableExtraBase : AudioCellPlayableBase
@property(retain, nonatomic) UILabel *durationLabel;
@end
@interface AudioCell : AudioCellPlayableExtraBase
@property (readonly, nonatomic) VKAudio *audio;
@end


@interface AFURLConnectionOperation : NSOperation
@property(retain, nonatomic) NSURLRequest *request;
@end
@interface AFHTTPRequestOperation : AFURLConnectionOperation
@property(readonly, retain, nonatomic) NSHTTPURLResponse *response;
@end
@interface AFJSONRequestOperation : AFHTTPRequestOperation
@end
