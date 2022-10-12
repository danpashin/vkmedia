//
//  VKMMDownloadController.h
//  VKMedia
//
//  Created by Даниил on 06.09.17.
//
//

#import <Foundation/Foundation.h>
#import "VKMethods.h"
#import "VKMMDownloadButton.h"
#import "VKMMAudioModel.h"

@interface VKMMDownloadController : NSObject <VKMMDownloadButtonDelegate>

- (VKMMDownloadButton *)buttonForAudio:(VKAudio *)audio;
@property (weak, nonatomic) VKMMAudioModel *audioModel;

@end
