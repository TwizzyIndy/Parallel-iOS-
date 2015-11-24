#include <UIKit/UIKit.h>
#include <Foundation/Foundation.h>
#include "Parallel.h"
#include "Zg-Uni-Identifier.h"

#define kPrefPath @"/private/var/mobile/Library/Preferences/com.twizzyindy.parallel.settings.plist"

@implementation Parallel

+(instancetype) sharedInstance {
    
    static Parallel* __sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        __sharedInstance = [[self alloc] init];
        
    });
    
    return __sharedInstance;
    
}

@end



static NSString* strGetText;

static Zg_Uni_Identifier* zg;

static BOOL bTweakOn;

static CGFloat fFontSize;

// load preference value on startup

static void initPrefs() {
    
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] initWithContentsOfFile:kPrefPath];
    BOOL isEnabled = [[dict objectForKey:@"isEnabled"] boolValue];
    fFontSize = [[dict objectForKey:@"sliderFontSize"] doubleValue];
    bTweakOn = isEnabled;
    
}

// Update static variables

static void UpdateFontSize(CFNotificationCenterRef center, void* observer, CFStringRef name, const void* object,
                           CFDictionaryRef userInfo) {
    
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] initWithContentsOfFile:kPrefPath];
    BOOL isEnabled = [[dict objectForKey:@"isEnabled"] boolValue];
    fFontSize = [[dict objectForKey:@"sliderFontSize"] doubleValue];
    bTweakOn = isEnabled;
    
}

// Hook for facebook app

%group HookForFacebook

%hook FBRichTextView

- (void)layoutSubviews {

    
    NSLog(@"attributedString : %@ ", [self.attributedString string]);
    
    strGetText = [[NSString alloc]init];
    strGetText = [self.attributedString string];
    
    if ([strGetText isEqual:NULL] ||[strGetText isEqual:@""] || ! bTweakOn ) {
        %orig;
        return;
    }
    
    NSArray* lines = [strGetText componentsSeparatedByString:@"\n"];
    
    zg = [[Zg_Uni_Identifier alloc]init];
    
    UIFont* fontZg = [UIFont fontWithName:@"Zawgyi-One" size:fFontSize];
    UIFont* fontUni= [UIFont fontWithName:@"Myanmar3-Regular" size:fFontSize];
    
    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc]initWithString:strGetText];
    
    BOOL nonBurmeseChars = YES;
    
    if( [lines count] > 0)
        
    {
        
        for (int x=0; x < [lines count]; x++)
        {
            
            NSLog(@"\nParallel Lines (%d) : %@ ", x, [lines objectAtIndex:x]);
            
            NSString* strWordsInALine = [lines objectAtIndex:x];
            
            if([strWordsInALine length] > 6)
            {
                
                NSString* strFirstSevenWordsOfALine = [strWordsInALine substringWithRange:NSMakeRange(0, 7)];
                
                @try {
                    
                    if ( [zg isUni:strFirstSevenWordsOfALine]) {
                        
                        
                        NSLog(@"\nParallel Lines (%d) : %@ is Unicode.", x, [lines objectAtIndex:x]);
                        
                        NSRange rangeOfWordsFromTotal = [strGetText rangeOfString:strWordsInALine];
                        
                        [attrString setAttributes:@{ NSFontAttributeName: fontUni } range:rangeOfWordsFromTotal];
                        
                        nonBurmeseChars = NO;
                        
                    } else if( [zg isZawgyi: strFirstSevenWordsOfALine]) {
                        
                        NSLog(@"\nParallel Lines (%d) : %@ is Zawgyi.", x, [lines objectAtIndex:x]);
                        
                        NSRange rangeOfWordsFromTotal = [strGetText rangeOfString:strWordsInALine];
                        
                        [attrString setAttributes:@{NSFontAttributeName: fontZg } range:rangeOfWordsFromTotal];
                        
                        nonBurmeseChars = NO;
                        
                    } else {
                        
                        nonBurmeseChars = YES;
                    }
                    
                    
                } @catch (NSException* ex){
                    
                    NSLog(@"%@", ex );
                    
                }
            }
        }
        
    }
    
    if( nonBurmeseChars )
    {
        %orig; // dont change
        
    } else {
        
        %orig;
        self.attributedString = attrString;
        
    }


}

%end

%end

%ctor {
    
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    NULL, (CFNotificationCallback)UpdateFontSize, CFSTR("com.twizzyindy.parallel.settingsChanged"),
                                    NULL, CFNotificationSuspensionBehaviorCoalesce);
    
    initPrefs();
    
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc]init];
    
    NSMutableDictionary* pref = [[NSMutableDictionary alloc] initWithContentsOfFile:kPrefPath];
    
    if( [[pref objectForKey:@"isEnabled"] boolValue] ) {
        
        NSString* identifier = [[NSBundle mainBundle] bundleIdentifier];
    
        if( [[pref objectForKey:[NSString stringWithFormat:@"ParallelEnabled-%@",identifier]] boolValue])
        
        {
        
            //TODO: Just for facebook now
            %init(HookForFacebook);
        }
        
    }
    
    [pool drain];
    
}
