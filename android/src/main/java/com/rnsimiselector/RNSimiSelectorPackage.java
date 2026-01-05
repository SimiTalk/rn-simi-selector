// package com.rnsimiselector;
//
// import androidx.annotation.NonNull;
// import androidx.annotation.Nullable;
//
// import com.facebook.react.BaseReactPackage;
// import com.facebook.react.bridge.NativeModule;
// import com.facebook.react.bridge.ReactApplicationContext;
// import com.facebook.react.module.model.ReactModuleInfo;
// import com.facebook.react.module.model.ReactModuleInfoProvider;
//
// import java.util.Collections;
// import java.util.HashMap;
// import java.util.List;
// import java.util.Map;
//
// public class RNSimiSelectorPackage extends BaseReactPackage {
//
//     @Nullable
//     @Override
//     public NativeModule getModule(@NonNull String name, @NonNull ReactApplicationContext reactContext) {
//         if (name.equals("RNSimiSelector")) {
//             return new RNSimiSelectorModule(reactContext);
//         }
//         return null;
//     }
//
//     @NonNull
//     @Override
//     public ReactModuleInfoProvider getReactModuleInfoProvider() {
//         return () -> {
//             final Map<String, ReactModuleInfo> moduleInfos = new HashMap<>();
//             boolean isTurboModule = BuildConfig.IS_NEW_ARCHITECTURE_ENABLED;
//
//             moduleInfos.put(
//                 "RNSimiSelector",
//                 new ReactModuleInfo(
//                     "RNSimiSelector",
//                     "RNSimiSelector",
//                     false, // canOverrideExistingModule
//                     false, // needsEagerInit
//                     false, // isCxxModule
//                     isTurboModule   // isTurboModule
//                 )
//             );
//             return moduleInfos;
//         };
//     }
//
// }
