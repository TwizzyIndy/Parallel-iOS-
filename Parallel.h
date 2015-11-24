//
//  Parallel.h
//  Parallel
//
//  Created by TwizzyIndy on 10/9/15.
//
//

#ifndef Parallel_Parallel_h
#define Parallel_Parallel_h


#endif

@interface FBRichTextView : UIControl

@property(copy, nonatomic) NSAttributedString *attributedString; // @synthesize attributedString=_attributedString;

- (void)layoutSubviews;

@end


@interface Parallel : NSObject

+(id)sharedInstance;

@end