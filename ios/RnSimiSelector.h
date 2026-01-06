#import <RnSimiSelectorSpec/RnSimiSelectorSpec.h>

@interface RnSimiSelector : NSObject <NativeRnSimiSelectorSpec>

@property (nonatomic, strong) NSMutableArray *images;

@property (nonatomic, strong) NSMutableArray *assets;

@property (nonatomic, assign) BOOL hasSelectVideo;

@property (nonatomic, strong) NSMutableArray <NSMutableDictionary *>*selectedMedias;

@end
