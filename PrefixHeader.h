//
//  PrefixHeader.pch
//  VKMedia
//
//  Created by Даниил on 06.09.17.
//
//

#ifdef  COMPILE_FOR_JAIL
#define VKM_PREFS_PATH      @"/var/mobile/Library/Preferences/ru.danpashin.vkmedia.plist"
#else
#define VKM_PREFS_PATH      [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/ru.danpashin.vkmedia.plist"]
#endif

#define kVKMediaVersion @"0.3-alpha"
#define kVKMediaTintColor [UIColor colorWithRed:90/255.0f green:130/255.0f blue:180/255.0f alpha:1.0f]



//#define ENABLE_DEBUG


#ifdef ENABLE_DEBUG
#define VKMLog(args...)			NSLog(@"[VKMEDIA]: %@", [NSString stringWithFormat:args])
#define VKMLogSource(args...)	NSLog(@"[VKMEDIA]: @ " CHStringify(__LINE__) " in %s: %@", __FUNCTION__, [NSString stringWithFormat:args])
#else
#define VKMLog(args...)
#define VKMLogSource(args...)
#endif
