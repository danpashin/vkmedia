//
//  VKMMDownloadButton.h
//  VKMedia
//
//  Created by Даниил on 06.09.17.
//
//

#import <MDSOfferView.h>
#import "VKMethods.h"

@class VKMMDownloadController;
@class VKMMDownloadButton;

@protocol VKMMDownloadButtonDelegate <NSObject>

- (void)buttonBeginDownload:(VKMMDownloadButton *)button;

@end


@interface VKMMDownloadButton : MDSOfferView

- (void)addToCell:(AudioCell *)audioCell;

@property (strong, nonatomic) VKAudio *audio;
@property (weak, nonatomic) VKMMDownloadController *downloadController;
@property (weak, nonatomic) id <VKMMDownloadButtonDelegate> delegate;
@property (assign, nonatomic) BOOL audioDownloaded;

@end
