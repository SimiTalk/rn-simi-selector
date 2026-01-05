// package com.rnsimiselector;
//
// import androidx.annotation.NonNull;
// import androidx.annotation.Nullable;
// import android.util.Log;
//
// import com.facebook.react.bridge.Promise;
// import com.facebook.react.bridge.ReactApplicationContext;
// import com.facebook.react.bridge.ReactMethod;
// import com.facebook.react.bridge.ReadableMap;
//
// public class RNSimiSelectorModule extends NativeSimiSelectorSpec{
//
//     public static final String NAME = "RNSimiSelector";
//
//     private final SimiSelectorModule simiSelectorModule;
//
//     public RNSimiSelectorModule(@NonNull ReactApplicationContext reactContext) {
//         super(reactContext);
//         Log.i("GGG", "RNSimiSelectorModule 构造函数被调用");
//         simiSelectorModule = new SimiSelectorModule(reactContext);
//     }
//
//     @Override
//     public String getName() {
//        return NAME;
//     }
//
//     @ReactMethod
//     @Override
//     public void openSelectorDefault(Promise promise) {
//         Log.i("GGG", "openSelectorDefault called");
//         simiSelectorModule.openSelector(promise);
//     }
//
//     @ReactMethod
//     @Override
//     public void openSelector(@Nullable ReadableMap options, Promise promise) {
//         Log.i("GGG", "openSelector called");
//         simiSelectorModule.openSelector(options, promise);
//     }
// }
