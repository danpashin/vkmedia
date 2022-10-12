//
//  VKMediaDownloadController.m
//  VKMedia
//
//  Created by Даниил on 06.09.17.
//
//

#import "VKMMDownloadController.h"
#import "PrefixHeader.h"

@interface VKMMDownloadController () <NSURLSessionDownloadDelegate>

@property (strong, nonatomic) NSMutableDictionary <NSString *, VKMMDownloadButton *> *downloads;
@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSURL *downloadsFolder;

@end

@implementation VKMMDownloadController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.downloads = [[NSMutableDictionary alloc] init];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        self.downloadsFolder = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].lastObject;
        self.downloadsFolder = [self.downloadsFolder URLByAppendingPathComponent:@"VKMedia"];
        
        if (![self.downloadsFolder checkResourceIsReachableAndReturnError:nil]) {
            NSError *creatingError = nil;
            [fileManager createDirectoryAtURL:self.downloadsFolder withIntermediateDirectories:NO attributes:nil error:&creatingError];
            VKMLog(@"Create directories with error: %@", creatingError);
        }
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"ru.danpashin.vkmedia.audio.download"];
        configuration.HTTPMaximumConnectionsPerHost = 3;
        self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
        
    }
    return self;
}

- (VKMMDownloadButton *)buttonForAudio:(VKAudio *)audio
{
    NSString *string_id = [NSString stringWithFormat:@"%@", audio.iden.iid];
    
    return self.downloads[string_id];
}


- (void)buttonBeginDownload:(VKMMDownloadButton *)button
{
    NSString *string_id = [NSString stringWithFormat:@"%@", button.audio.iden.iid];
    
    self.downloads[string_id] = button;
    
    NSURLSessionDownloadTask *downloadTask = [self.session downloadTaskWithURL:[NSURL URLWithString:button.audio.url]];
    downloadTask.accessibilityValue = string_id;
    
    button.state = MDSOfferViewStateDownloading;
    [downloadTask resume];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSString *string_id = downloadTask.accessibilityValue;
    
    VKMMDownloadButton *button = self.downloads[string_id];
    button.audioDownloaded = YES;
    
    NSError *movingError = nil;
    NSURL *fileURL = [self.downloadsFolder URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp3", button.audio.iden.iid]];
    [[NSFileManager defaultManager] moveItemAtURL:location toURL:fileURL error:&movingError];
    
    VKMLog(@"Move downloaded file with error: '%@'", movingError);
    
    [self.audioModel addAudio:button.audio];
    
    [self.downloads removeObjectForKey:string_id];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{    
    float progress = ((float)totalBytesWritten / (float)totalBytesExpectedToWrite);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        VKMMDownloadButton *button = self.downloads[downloadTask.accessibilityValue];
        [button setProgress:progress animated:YES];
    });
}

@end
