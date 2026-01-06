#import "RnSimiSelector.h"
#import "UIView+LCToast.h"
#import <Photos/Photos.h>
//#import <React/RCTConvert.h>
//#import <React/RCTEventDispatcher.h>
#import <ZLPhotoBrowser/ZLPhotoBrowser-Swift.h>
#import <AVFoundation/AVFoundation.h>

#define DEFAULT_IS_SINGLE NO
#define DEFAULT_CROP NO
#define DEFAULT_MUST_CROP NO
#define DEFAULT_MAX_IMAGE_NUM 6
#define DEFAULT_MAX_VIDEO_NUM 1
#define DEFAULT_SELECT_MIME_TYPE 0
#define DEFAULT_LANGUAGE ZLLanguageTypeChineseSimplified
#define DEFAULT_MIX_SELECT NO
#define DEFAULT_IMAGE_SIZE_LIMIT 0
#define DEFAULT_VIDEO_SIZE_LIMIT 0

@implementation RnSimiSelector
RCT_EXPORT_MODULE()

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeRnSimiSelectorSpecJSI>(params);
}


- (void)openSelector:(NSDictionary *)options
              resolve:(RCTPromiseResolveBlock)resolve
               reject:(RCTPromiseRejectBlock)reject
{
  // 默认值
  BOOL isSingle = DEFAULT_IS_SINGLE;
  BOOL isCrop = DEFAULT_CROP;
  BOOL mustCrop = DEFAULT_MUST_CROP;
  int maxImageNum = DEFAULT_MAX_IMAGE_NUM;
  int maxVideoNum = DEFAULT_MAX_VIDEO_NUM;
  int selectMimeType = DEFAULT_SELECT_MIME_TYPE;
  int selectLanguage = DEFAULT_LANGUAGE;
  BOOL isMixSelect = DEFAULT_MIX_SELECT;
  int imageSizeLimit = DEFAULT_IMAGE_SIZE_LIMIT;
  int videoSizeLimit = DEFAULT_VIDEO_SIZE_LIMIT;
  
  if (options != nil && [options isKindOfClass:[NSDictionary class]]) {
    if (options[@"isSingle"]) {
      isSingle = [options[@"isSingle"] boolValue];
    }
    if (options[@"maxImageNum"]) {
      maxImageNum = [options[@"maxImageNum"] intValue];
    }
    if (options[@"maxVideoNum"]) {
      maxVideoNum = [options[@"maxVideoNum"] intValue];
    }
    if (options[@"selectMimeType"]) {
      selectMimeType = [options[@"selectMimeType"]
                        intValue]; // 0: all , 1: image , 2: video , 3: audio
    }
    if (options[@"selectLanguage"]) {
      NSString *lang = [options[@"selectLanguage"] lowercaseString];
      if ([lang containsString:@"en"]) {
        selectLanguage = ZLLanguageTypeEnglish;
      }else if ([lang containsString:@"hk"]) {
        selectLanguage = ZLLanguageTypeChineseTraditional;
      }else if ([lang containsString:@"ru"]) {
        selectLanguage = ZLLanguageTypeRussian;
      }else {
        selectLanguage = ZLLanguageTypeChineseSimplified;
      }
    }
    if (options[@"isCrop"]) { //是否编辑
      isCrop = [options[@"isCrop"] boolValue];
    }
    if (options[@"mustCrop"]) { //是否直接裁剪
      mustCrop = [options[@"mustCrop"] boolValue];
    }
    if (options[@"isMixSelect"]) {
      isMixSelect = [options[@"isMixSelect"] boolValue];
    }
    if (options[@"imageSizeLimit"]) {
      imageSizeLimit = [options[@"imageSizeLimit"] intValue];
    }
    if (options[@"videoSizeLimit"]) {
      videoSizeLimit = [options[@"videoSizeLimit"] intValue];
    }
  }
  
  int maxCount = maxImageNum + maxVideoNum;
  
  BOOL canSelectVideo = NO;
  if (selectMimeType == 0 || selectMimeType == 2) {
    canSelectVideo = YES;
  }
  
  if (isSingle) {
    maxCount = 1;
    maxImageNum = 1;
  }
  
  if (!isMixSelect) {
    maxCount = maxImageNum;
  }
  
  // 调用封装逻辑
  [self openPhotoPickerAllowMixSelect:isMixSelect
                             isSingle:isSingle
                       canSelectVideo:canSelectVideo
                             maxCount:maxCount
                        maxVideoCount:maxVideoNum
                             language:(ZLLanguageType)selectLanguage
                       allowEditImage:isCrop
                             mustCrop:mustCrop
                       imageSizeLimit:imageSizeLimit
                       videoSizeLimit:videoSizeLimit
                              resolve:resolve
                             rejecter:reject];
}

// 在 RnSimiSelector.mm 中需要补齐
- (void)openSelectorDefault:(RCTPromiseResolveBlock)resolve
                     reject:(RCTPromiseRejectBlock)reject {
  BOOL isSingle = DEFAULT_IS_SINGLE;
  BOOL isCrop = DEFAULT_CROP;
  BOOL mustCrop = DEFAULT_MUST_CROP;
  int maxImageNum = DEFAULT_MAX_IMAGE_NUM;
  int maxVideoNum = DEFAULT_MAX_VIDEO_NUM;
  int selectMimeType = DEFAULT_SELECT_MIME_TYPE;
  int selectLanguage = DEFAULT_LANGUAGE;
  BOOL isMixSelect = DEFAULT_MIX_SELECT;
  int imageSizeLimit = DEFAULT_IMAGE_SIZE_LIMIT;
  int videoSizeLimit = DEFAULT_VIDEO_SIZE_LIMIT;

  
  int maxCount = maxImageNum + maxVideoNum;
  
  BOOL canSelectVideo = NO;
  if (selectMimeType == 0 || selectMimeType == 2) {
    canSelectVideo = YES;
  }
  
  if (isSingle) {
    maxCount = 1;
    maxImageNum = 1;
  }
  
  if (!isMixSelect) {
    maxCount = maxImageNum;
  }

  
  [self openPhotoPickerAllowMixSelect:isMixSelect
                             isSingle:isSingle
                       canSelectVideo:canSelectVideo
                             maxCount:maxCount
                        maxVideoCount:maxVideoNum
                             language:(ZLLanguageType)selectLanguage
                       allowEditImage:isCrop
                             mustCrop:mustCrop
                       imageSizeLimit:imageSizeLimit
                       videoSizeLimit:videoSizeLimit
                              resolve:resolve
                             rejecter:reject];

}

- (void)openPhotoPickerAllowMixSelect:(BOOL)allowMixSelect
                             isSingle:(BOOL)isSingle
                       canSelectVideo:(BOOL)canSelectVideo
                             maxCount:(int)maxCount
                        maxVideoCount:(int)maxVideoCount
                             language:(ZLLanguageType)language
                       allowEditImage:(BOOL)allowEditImage
                             mustCrop:(BOOL)mustCrop
                       imageSizeLimit:(int)imageSizeLimit
                       videoSizeLimit:(int)videoSizeLimit
                              resolve:(RCTPromiseResolveBlock)resolve
                             rejecter:(RCTPromiseRejectBlock)reject {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.images = [NSMutableArray array];
        self.assets = [NSMutableArray array];
        [self.selectedMedias removeAllObjects];
        // 获取viewController
        UIViewController *rootVC =
        [UIApplication sharedApplication].delegate.window.rootViewController;
        
        ZLPhotoUIConfiguration *uiConfig = [ZLPhotoUIConfiguration default];
        uiConfig.languageType = language;
        uiConfig.minimumLineSpacing = 6;
        uiConfig.minimumInteritemSpacing = 6;
        uiConfig.columnCount = 3;
        uiConfig.cellCornerRadio = 16;
        uiConfig.themeColor = [UIColor colorWithRed:16.0 / 255.0
                                              green:175.0 / 255.0
                                               blue:255.0 / 255.0
                                              alpha:1];
        
        ZLPhotoConfiguration *config = [ZLPhotoConfiguration default];
        
        if (isSingle && mustCrop && !canSelectVideo) {
            config.allowSelectImage = YES;
            config.allowSelectGif = NO;
            config.allowSelectLivePhoto = NO;
            config.allowSelectOriginal = YES;
            config.editImageConfiguration.tools_objc = @[ @(1) ];
            config.editImageConfiguration.clipRatios = @[ ZLImageClipRatio.wh1x1 ];
            config.editImageConfiguration.showClipDirectlyIfOnlyHasClipTool = YES;
            config.maxSelectCount = 1;
            config.editAfterSelectThumbnailImage = YES;
            config.allowSelectVideo = canSelectVideo;
            config.saveNewImageAfterEdit = NO;
          } else {
            config.allowSelectImage = YES;
            config.allowSelectVideo =
                canSelectVideo ? (self.images.count == 0 ? YES : NO) : NO;
            config.allowSelectGif = NO;
            config.allowSelectLivePhoto = NO;
            config.allowSelectOriginal = YES;
            config.allowMixSelect = allowMixSelect;
            config.maxSelectCount = maxCount;
            config.maxVideoSelectCount = maxVideoCount;
            config.allowTakePhotoInLibrary = NO;
            config.allowEditImage = allowEditImage;
            config.showSelectBtnWhenSingleSelect = YES;
            config.maxSelectVideoDuration = 10800;
          }

          // 捕获外部变量到 block 中
          BOOL capturedIsSingle = isSingle;
          BOOL capturedMustCrop = mustCrop;
          BOOL capturedCanSelectVideo = canSelectVideo;
          ZLLanguageType capturedLanguage = language;

          config.canSelectAsset = ^BOOL(PHAsset *_Nonnull asset) {
            NSNumber *sizeStr = [RnSimiSelector fetchFormattedAssetSize:asset];

            NSString *imageSizeLimitStr = [NSString
                stringWithFormat:@"%.2f", (float)imageSizeLimit / 1024 / 1024];
            NSString *videoSizeLimitStr = [NSString
                stringWithFormat:@"%.2f", (float)videoSizeLimit / 1024 / 1024];

            if (asset.mediaType == PHAssetMediaTypeImage) {
              NSLog(@"检查图片尺寸: %lux%lu, 条件: isSingle=%d, mustCrop=%d, "
                    @"canSelectVideo=%d",
                    (unsigned long)asset.pixelWidth, (unsigned long)asset.pixelHeight,
                    capturedIsSingle, capturedMustCrop, capturedCanSelectVideo);

              // 检查图片尺寸是否小于128px，只在单选且必须裁剪且不能选择视频时才限制
              if ((capturedIsSingle && capturedMustCrop && !capturedCanSelectVideo) &&
                  (asset.pixelWidth < 128 || asset.pixelHeight < 128)) {
                NSString *tip = @"图片尺寸不能小于 128x128 像素";
                if (capturedLanguage == ZLLanguageTypeChineseTraditional) {
                  tip = @"圖片尺寸不能小於 128x128 像素";
                } else if (capturedLanguage == ZLLanguageTypeEnglish) {
                  tip = @"Image size cannot be smaller than 128x128 pixels";
                } else if (capturedLanguage == ZLLanguageTypeRussian) {
                  tip = @"Размер изображения не может быть меньше 128x128 пикселей";
                } else {
                  tip = @"图片尺寸不能小于 128x128 像素";
                }

                dispatch_async(dispatch_get_main_queue(), ^{
                  [[UIApplication sharedApplication].delegate.window
                      lc_showToast:tip];
                });

                return NO;
              }

              // 检查文件大小限制
              NSString *tip = [NSString
                  stringWithFormat:@"选择图片不能大于 %@ MB", imageSizeLimitStr];
              if (capturedLanguage == ZLLanguageTypeChineseTraditional) {
                tip = [NSString
                    stringWithFormat:@"選擇圖片不能大於 %@ MB", imageSizeLimitStr];
              } else if (capturedLanguage == ZLLanguageTypeEnglish) {
                tip =
                    [NSString stringWithFormat:
                                  @"Select an image that cannot be lager than %@ MB",
                                  imageSizeLimitStr];
              } else if (capturedLanguage == ZLLanguageTypeRussian) {
                tip =
                    [NSString stringWithFormat:@"Выбрать изображение не больше %@ MB",
                                               imageSizeLimitStr];
              } else {
                tip = [NSString
                    stringWithFormat:@"选择图片不能大于%@ MB", imageSizeLimitStr];
              }
              if (imageSizeLimit > 0 && sizeStr.intValue > imageSizeLimit) {

                dispatch_async(dispatch_get_main_queue(), ^{
                  [[UIApplication sharedApplication].delegate.window
                      lc_showToast:tip];
                });

                return NO;
              }
              return YES;
            } else if (asset.mediaType == PHAssetMediaTypeVideo) {
              NSString *tip = [NSString
                  stringWithFormat:@"选择视频不能大于 %@ MB", videoSizeLimitStr];
              if (capturedLanguage == ZLLanguageTypeChineseTraditional) {
                tip = [NSString
                    stringWithFormat:@"選擇視頻不能大於 %@ MB", videoSizeLimitStr];
              } else if (capturedLanguage == ZLLanguageTypeEnglish) {
                tip =
                    [NSString stringWithFormat:
                                  @"Select an video that cannot be lager than %@ MB",
                                  videoSizeLimitStr];
              } else if (capturedLanguage == ZLLanguageTypeRussian) {
                tip = [NSString stringWithFormat:@"Выбрать видео не больше %@ MB",
                                                 videoSizeLimitStr];
              } else {
                tip = [NSString
                    stringWithFormat:@"选择视频不能大于 %@ MB", videoSizeLimitStr];
              }
              if (videoSizeLimit > 0 && sizeStr.intValue > videoSizeLimit) {

                dispatch_async(dispatch_get_main_queue(), ^{
                  [[UIApplication sharedApplication].delegate.window
                      lc_showToast:tip];
                });
                return NO;
              }

              // 拿到资源的文件名
              PHAssetResource *res =
                  [PHAssetResource assetResourcesForAsset:asset].firstObject;
              NSString *ext = res.originalFilename.pathExtension.lowercaseString;
              if (!([ext isEqualToString:@"mp4"] || [ext isEqualToString:@"mov"])) {
                NSString *msg = @"只能选择 MP4 或 MOV 格式的视频";
                if (capturedLanguage == ZLLanguageTypeChineseTraditional) {
                  msg = @"只能選擇MP4或MOV格式的視頻";
                } else if (capturedLanguage == ZLLanguageTypeEnglish) {
                  msg = @"Only MP4 or MOV videos are allowed";
                } else if (capturedLanguage == ZLLanguageTypeRussian) {
                  msg = @"Выберите видео только в формате MP4 или MOV";
                } else {
                  msg = @"只能选择 MP4 或 MOV 格式的视频";
                }
                [UIApplication.sharedApplication.delegate.window lc_showToast:msg];
                return NO;
              }

              return YES;
            } else {
              return YES;
            }
            return YES;
          };
        
        ZLPhotoPicker *picker = [[ZLPhotoPicker alloc] init];
        __weak RnSimiSelector *weakSelf = self;
        
        picker.selectImageBlock = ^(NSArray<ZLResultModel *> *_Nonnull results, BOOL isOriginal) {
            [weakSelf handlePickedResults:results
                                 isSingle:isSingle
                               completion:^(id result) {
                resolve(result);
            }];
            
            NSError *err = nil;
            AVAudioSession *session = [AVAudioSession sharedInstance];

            [session setCategory:AVAudioSessionCategoryPlayAndRecord
                     withOptions:AVAudioSessionCategoryOptionAllowBluetooth |
                                  AVAudioSessionCategoryOptionMixWithOthers
                           error:&err];

            [session setMode:AVAudioSessionModeVoiceChat error:&err];
            [session setActive:YES error:&err];
        };
        
        picker.cancelBlock = ^{
            reject(@"-1", @"cancelAction", nil);
        };
        
        [picker showPhotoLibraryWithSender:rootVC];
    });
}

- (void)handlePickedResults:(NSArray<ZLResultModel *> *)results
                   isSingle:(BOOL)isSingle
                 completion:(void (^)(id result))completion {
    
    // 1. 准备等长占位数组
    NSUInteger count = results.count;
    NSMutableArray *orderedMedias = [NSMutableArray arrayWithCapacity:count];
    for (NSUInteger i = 0; i < count; i++) {
        [orderedMedias addObject:[NSNull null]];
    }
    
    NSMutableArray<UIImage *> *selectedImages = [NSMutableArray array];
    NSMutableArray<PHAsset *> *selectedAssets = [NSMutableArray array];
    //  NSMutableArray<NSDictionary *> *tempMedias = [NSMutableArray
    //  arrayWithCapacity:results.count];
    
    dispatch_group_t group = dispatch_group_create();
    
    for (NSUInteger idx = 0; idx < count; idx++) {
        ZLResultModel *result = results[idx];
        
        if (result.image) {
            [selectedImages addObject:result.image];
        }
        
        if (result.asset) {
            [selectedAssets addObject:result.asset];
        }
        
        // 2. 按原索引异步处理并写回占位数组
        UIImage *image = result.image;
        PHAsset *asset = result.asset;
        if (asset) {
            [self processAsset:asset
                 originalImage:image
                         group:group
                    completion:^(NSDictionary *media) {
                if (media) {
                    orderedMedias[idx] = media;
                }
            }];
        }
    }
    
    __weak RnSimiSelector *weakSelf = self;
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // 3. 过滤掉 NSNull，保留按选中顺序的结果
        NSMutableArray<NSDictionary *> *tempMedias = [NSMutableArray array];
        for (id obj in orderedMedias) {
            if (![obj isEqual:[NSNull null]]) {
                [tempMedias addObject:obj];
            }
        }
        
        [weakSelf.images addObjectsFromArray:selectedImages];
        [weakSelf.assets addObjectsFromArray:selectedAssets];
        weakSelf.hasSelectVideo =
        selectedAssets.firstObject.mediaType == PHAssetMediaTypeVideo;
        [weakSelf.selectedMedias
         addObjectsFromArray:[NSMutableArray arrayWithArray:tempMedias]];
        
        if (isSingle) {
            if (tempMedias.count == 1) {
                completion(weakSelf.selectedMedias);
            } else {
                completion(@[]);
            }
        } else {
            if (tempMedias.count >= 1) {
                completion(weakSelf.selectedMedias);
            } else {
                completion(@[]);
            }
        }
    });
}

- (void)processAsset:(PHAsset *)asset
       originalImage:(nullable UIImage *)image
               group:(dispatch_group_t)group
          completion:(void (^)(NSDictionary *media))completion {
    
    NSString *mediaType = @"";
    if (asset.mediaType == PHAssetMediaTypeImage) {
        mediaType = @"image";
    } else if (asset.mediaType == PHAssetMediaTypeVideo) {
        mediaType = @"video";
    } else if (asset.mediaType == PHAssetMediaTypeAudio) {
        mediaType = @"audio";
    } else {
        mediaType = @"unknown";
    }
    
    __block NSMutableDictionary *media = [@{
        @"mediaType" : mediaType,
        @"width" : @(asset.pixelWidth),
        @"height" : @(asset.pixelHeight)
    } mutableCopy];
    
    // 获取路径、名称、大小
    dispatch_group_enter(group);
    [ZLPhotoManager
     fetchAssetFilePathFor:asset
     completion:^(NSString *path) {
        if (path)
            media[@"uri"] = path;
        PHAssetResource *res =
        [PHAssetResource assetResourcesForAsset:asset]
            .firstObject;
        if (res) {
            media[@"fileName"] = res.originalFilename;
            media[@"size"] = [res valueForKey:@"fileSize"];
        }
        // 按类型处理
        if (asset.mediaType == PHAssetMediaTypeImage) {
            [self compressImage:image
                     completion:^(NSString *uri, NSNumber *size) {
                if (uri) {
                    media[@"uri"] = uri;
                    media[@"fileName"] = [uri lastPathComponent];
                    media[@"size"] = size;
                }
                completion(media);
                dispatch_group_leave(group);
            }];
        } else if (asset.mediaType == PHAssetMediaTypeVideo) {
            [self
             generateVideoThumbnailForAsset:asset
             completion:^(
                          NSString
                          *_Nullable thumbnailPath) {
                              if (thumbnailPath)
                                  media[@"videoImage"] =
                                  thumbnailPath;
                              completion(media);
                              dispatch_group_leave(group);
                          }];
        } else {
            completion(media);
            dispatch_group_leave(group);
        }
    }];
}

+ (nullable NSNumber *)fetchFormattedAssetSize:(PHAsset *)asset {
    PHAssetResource *resource =
    [PHAssetResource assetResourcesForAsset:asset].firstObject;
    if (!resource)
        return nil;
    
    @try {
        NSNumber *fileSize = [resource valueForKey:@"fileSize"];
        if ([fileSize isKindOfClass:[NSNumber class]]) {
            
            return fileSize;
        }
    } @catch (NSException *exception) {
        NSLog(@"❌ Failed to get fileSize : %@", exception);
    }
    return nil;
}

- (void)compressImage:(UIImage *)image
           completion:(void (^)(NSString *uri, NSNumber *size))done {
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        NSData *data = UIImageJPEGRepresentation(image, 0.8);
        if (!data) {
            done(nil, nil);
            return;
        }
        NSString *tmp = [NSTemporaryDirectory()
                         stringByAppendingPathComponent:
                             [NSUUID.UUID.UUIDString stringByAppendingPathExtension:@"jpg"]];
        BOOL ok = [data writeToFile:tmp atomically:YES];
        NSNumber *sz =
        ok ? @([NSFileManager.defaultManager attributesOfItemAtPath:tmp
                                                              error:nil]
            .fileSize)
        : nil;
        done(ok ? tmp : nil, sz);
    });
}

- (void)generateVideoThumbnailForAsset:(PHAsset *)asset
                            completion:
(void (^)(NSString *_Nullable thumbnailPath))
completion {
    
    CGSize thumbnailSize = CGSizeMake(asset.pixelWidth, asset.pixelHeight);
    
    __block BOOL didCallback = NO;
    [ZLPhotoManager fetchImageFor:asset
                             size:thumbnailSize
                         progress:nil
                       completion:^(UIImage *_Nullable image, BOOL isDegraded) {
        // 如果已经回调过或者是降质图，直接跳过
        if (didCallback || isDegraded)
            return;
        
        if (image) {
            didCallback = YES;
            NSString *path = [RnSimiSelector saveThumbnailToTemporaryDirectory:image];
            completion(path);
        }
    }];
}

+ (NSString *)saveThumbnailToTemporaryDirectory:(UIImage *)image {
    if (!image)
        return nil;
    
    // 将 UIImage 压缩为 JPEG 格式的数据
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    if (!imageData)
        return nil;
    
    // 创建临时文件路径
    NSString *tempDirectory = NSTemporaryDirectory();
    NSString *fileName =
    [[NSUUID UUID].UUIDString stringByAppendingString:@".jpg"];
    NSString *filePath = [tempDirectory stringByAppendingPathComponent:fileName];
    
    // 写入数据到文件
    NSError *error = nil;
    BOOL success = [imageData writeToFile:filePath
                                  options:NSDataWritingAtomic
                                    error:&error];
    
    if (success) {
        return filePath;
    } else {
        NSLog(@"❌ 保存缩略图失败: %@", error);
        return nil;
    }
}


- (NSMutableArray *)selectedMedias {
    if (_selectedMedias == nil) {
        _selectedMedias = [NSMutableArray array];
    }
    return _selectedMedias;
}

@end
