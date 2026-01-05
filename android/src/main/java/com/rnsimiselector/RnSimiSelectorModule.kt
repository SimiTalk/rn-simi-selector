package com.rnsimiselector

import android.util.Log
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.module.annotations.ReactModule

@ReactModule(name = RnSimiSelectorModule.NAME)
class RnSimiSelectorModule(private val reactContext: ReactApplicationContext) :
  NativeRnSimiSelectorSpec(reactContext) {

  private val simiSelectorModule: SimiSelectorModule by lazy {
    SimiSelectorModule(reactContext)
  }

  init {
    Log.i("GGG", "RnSimiSelectorModule 构造函数被调用")
  }

  override fun getName(): String {
    return NAME
  }

  @ReactMethod
  override fun openSelectorDefault(promise: Promise) {
    Log.i("GGG", "openSelectorDefault called")
    simiSelectorModule.openSelector(promise)
  }

  @ReactMethod
  override fun openSelector(options: ReadableMap?, promise: Promise) {
    Log.i("GGG", "openSelector called")
    simiSelectorModule.openSelector(options, promise)
  }

  companion object {
    const val NAME = "RnSimiSelector"
  }
}
