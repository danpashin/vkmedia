//
//  VKMMDownloadButton.m
//  VKMedia
//
//  Created by Даниил on 06.09.17.
//
//

#import "VKMMDownloadButton.h"
#import "PrefixHeader.h"


@interface MDSOfferView ()
- (void)updateForState;
@end


@implementation VKMMDownloadButton

- (instancetype)init
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.tag = 2345;
        self.tintColor = kVKMediaTintColor;
        
        [self setTitle:@"" forState:MDSOfferViewStateNormal];
        UIImage *image = [UIImage imageNamed:@"downloadIcon" inBundle:[NSBundle mainBundle] compatibleWithTraitCollection:nil];
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.actionButton setImage:image forState:UIControlStateNormal];
        self.actionButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.actionButton.layer.borderWidth = 0.0f;
        self.actionButton.contentEdgeInsets = UIEdgeInsetsMake(0, 14, 0, 0);
    });
}


- (void)addToCell:(AudioCell *)audioCell
{
    if (![audioCell isKindOfClass:[UITableViewCell class]])
        return;
    
    if ([audioCell.contentView.subviews containsObject:[audioCell.contentView viewWithTag:self.tag]])
        return;
    
    CGFloat width = 52;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [audioCell.contentView addSubview:self];
        [self updateForState];
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [audioCell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeRight 
                                                                          relatedBy:0 toItem:audioCell.durationLabel attribute:NSLayoutAttributeRight 
                                                                         multiplier:1.0f constant:-42.0f]];
        [audioCell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:0 toItem:nil attribute:0 multiplier:1.0f constant:width]];
        [audioCell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[button]-|" options:0 metrics:nil views:@{@"button":self}]];
    });
}

- (void)setAudioDownloaded:(BOOL)audioDownloaded
{
    _audioDownloaded = audioDownloaded;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.hidden = audioDownloaded;
    });
}

- (void)setState:(MDSOfferViewState)state
{
    super.state = state;
    
    self.actionButton.hidden = (state != MDSOfferViewStateNormal);
}

- (void)buttonTapped:(UIButton *)sender
{
    self.state = MDSOfferViewStatePendingDownload;
    
    if ([self.delegate respondsToSelector:@selector(buttonBeginDownload:)])
        [self.delegate buttonBeginDownload:self];
}

@end
