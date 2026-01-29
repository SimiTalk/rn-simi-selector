package com.rnsimiselector.immersive;

import android.app.Activity;
import android.graphics.Color;
import android.os.Build;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.FrameLayout;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.core.view.WindowInsetsControllerCompat;

import com.rnsimiselector.utils.DensityUtil;

/**
 * 沉浸式管理器 - 兼容魅族等国产ROM
 */
public class ImmersiveManager {

    private final static String TAG_FAKE_STATUS_BAR_VIEW = "TAG_FAKE_STATUS_BAR_VIEW";
    private final static String TAG_MARGIN_ADDED = "TAG_MARGIN_ADDED";
    private final static String TAG_NAVIGATION_BAR_VIEW = "TAG_NAVIGATION_BAR_VIEW";

    /**
     * @param baseActivity        这个会留出来状态栏和底栏的空白
     * @param statusBarColor      状态栏的颜色
     * @param navigationBarColor  导航栏的颜色
     * @param isDarkStatusBarIcon 状态栏图标颜色是否是深（黑）色  false状态栏图标颜色为白色
     */
    public static void immersiveAboveAPI23(AppCompatActivity baseActivity, int statusBarColor, int navigationBarColor, boolean isDarkStatusBarIcon) {
        immersiveAboveAPI23(baseActivity, false, false, statusBarColor, navigationBarColor, isDarkStatusBarIcon);
    }

    /**
     * @param baseActivity
     * @param statusBarColor     状态栏的颜色
     * @param navigationBarColor 导航栏的颜色
     */
    public static void immersiveAboveAPI23(AppCompatActivity baseActivity, boolean isMarginStatusBar,
                                           boolean isMarginNavigationBar, int statusBarColor,
                                           int navigationBarColor, boolean isDarkStatusBarIcon) {
        try {
            Window window = baseActivity.getWindow();

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT && Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
                // 4.4版本及以上 5.0版本及以下
                if (isDarkStatusBarIcon) {
                    initBarBelowLOLLIPOP(baseActivity);
                } else {
                    window.setFlags(
                            WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS,
                            WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
                }
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                if (isMarginStatusBar && isMarginNavigationBar) {
                    // 5.0版本及以上
                    window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS
                            | WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION);

                    setLightStatusBarCompat(baseActivity, true, true,
                            statusBarColor == Color.TRANSPARENT, isDarkStatusBarIcon);

                    window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
                } else if (!isMarginStatusBar && !isMarginNavigationBar) {
                    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M && isDarkStatusBarIcon) {
                        initBarBelowLOLLIPOP(baseActivity);
                    } else {
                        window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS
                                | WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION);

                        setLightStatusBarCompat(baseActivity, false, false,
                                statusBarColor == Color.TRANSPARENT, isDarkStatusBarIcon);

                        window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
                    }
                } else if (!isMarginStatusBar) {
                    window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS
                            | WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION);

                    setLightStatusBarCompat(baseActivity, false, true,
                            statusBarColor == Color.TRANSPARENT, isDarkStatusBarIcon);

                    window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
                } else {
                    // 留出来状态栏 不留出来导航栏 没找到办法
                    return;
                }

                window.setStatusBarColor(statusBarColor);
                window.setNavigationBarColor(navigationBarColor);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 使用新API设置状态栏样式 - 替代LightStatusBarUtils
     * 兼容魅族等国产ROM
     */
    private static void setLightStatusBarCompat(Activity activity, boolean isMarginStatusBar,
                                                boolean isMarginNavigationBar, boolean isTransparent,
                                                boolean isDarkStatusBarIcon) {
        Window window = activity.getWindow();
        View decorView = window.getDecorView();

        // 关键：让内容延伸到系统栏下方
        WindowCompat.setDecorFitsSystemWindows(window, false);

        // 设置状态栏图标颜色
        WindowInsetsControllerCompat controller = WindowCompat.getInsetsController(window, decorView);
        if (controller != null) {
            controller.setAppearanceLightStatusBars(isDarkStatusBarIcon);
            controller.setAppearanceLightNavigationBars(isDarkStatusBarIcon);
        }

        // 处理底部导航栏的 padding，防止内容被遮挡
        applyNavigationBarInsets(activity, isMarginNavigationBar);
    }

    /**
     * 处理导航栏 insets，只给底部添加 padding
     * 保持顶部状态栏沉浸式效果
     */
    private static void applyNavigationBarInsets(Activity activity, boolean isMarginNavigationBar) {
        ViewGroup contentView = activity.findViewById(android.R.id.content);
        if (contentView == null) return;

        ViewCompat.setOnApplyWindowInsetsListener(contentView, (v, windowInsets) -> {
            Insets systemBars = windowInsets.getInsets(WindowInsetsCompat.Type.systemBars());

            // 只处理底部导航栏，顶部不加 padding（保持沉浸式）
            int bottomPadding = isMarginNavigationBar ? 0 : systemBars.bottom;

            // 给内容区域的子 View 设置底部 padding
            if (v instanceof ViewGroup) {
                ViewGroup parent = (ViewGroup) v;
                if (parent.getChildCount() > 0) {
                    View child = parent.getChildAt(0);
                    child.setPadding(
                            child.getPaddingLeft(),
                            child.getPaddingTop(),  // 保持顶部不变
                            child.getPaddingRight(),
                            bottomPadding
                    );
                }
            }

            return windowInsets;
        });

        ViewCompat.requestApplyInsets(contentView);
    }

    /**
     * 透明状态栏
     */
    public static void translucentStatusBar(Activity activity, boolean isDarkStatusBarBlack) {
        Window window = activity.getWindow();

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
        }
        window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            window.setStatusBarColor(Color.TRANSPARENT);
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            WindowCompat.setDecorFitsSystemWindows(window, false);
            WindowInsetsControllerCompat controller = WindowCompat.getInsetsController(window, window.getDecorView());
            if (controller != null) {
                controller.setAppearanceLightStatusBars(isDarkStatusBarBlack);
            }
        } else {
            if (isDarkStatusBarBlack) {
                initBarBelowLOLLIPOP(activity);
            } else {
                WindowCompat.setDecorFitsSystemWindows(window, false);
            }
        }

        // view不根据系统窗口来调整自己的布局
        ViewGroup mContentView = window.findViewById(Window.ID_ANDROID_CONTENT);
        View mChildView = mContentView.getChildAt(0);
        if (mChildView != null) {
            mChildView.setFitsSystemWindows(false);
            ViewCompat.requestApplyInsets(mChildView);
        }
    }

    private static void initBarBelowLOLLIPOP(Activity activity) {
        Window mWindow = activity.getWindow();
        mWindow.addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
        setupStatusBarView(activity);

        if (DensityUtil.isNavBarVisible(activity)) {
            mWindow.addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION);
            setupNavBarView(activity);
        }
    }

    private static void setupStatusBarView(Activity activity) {
        Window mWindow = activity.getWindow();
        View statusBarView = mWindow.getDecorView().findViewWithTag(TAG_FAKE_STATUS_BAR_VIEW);
        if (statusBarView == null) {
            statusBarView = new View(activity);
            FrameLayout.LayoutParams params = new FrameLayout.LayoutParams(
                    FrameLayout.LayoutParams.MATCH_PARENT,
                    DensityUtil.getStatusBarHeight(activity));
            params.gravity = Gravity.TOP;
            statusBarView.setLayoutParams(params);
            statusBarView.setVisibility(View.VISIBLE);
            statusBarView.setTag(TAG_MARGIN_ADDED);
            ((ViewGroup) mWindow.getDecorView()).addView(statusBarView);
        }
        statusBarView.setBackgroundColor(Color.TRANSPARENT);
    }

    private static void setupNavBarView(Activity activity) {
        Window window = activity.getWindow();
        View navigationBarView = window.getDecorView().findViewWithTag(TAG_NAVIGATION_BAR_VIEW);
        if (navigationBarView == null) {
            navigationBarView = new View(activity);
            navigationBarView.setTag(TAG_NAVIGATION_BAR_VIEW);
            ((ViewGroup) window.getDecorView()).addView(navigationBarView);
        }

        FrameLayout.LayoutParams params;
        if (DensityUtil.isNavigationAtBottom(activity)) {
            params = new FrameLayout.LayoutParams(
                    FrameLayout.LayoutParams.MATCH_PARENT,
                    DensityUtil.getNavigationBarHeight(activity));
            params.gravity = Gravity.BOTTOM;
        } else {
            params = new FrameLayout.LayoutParams(
                    DensityUtil.getNavigationBarWidth(activity),
                    FrameLayout.LayoutParams.MATCH_PARENT);
            params.gravity = Gravity.END;
        }
        navigationBarView.setLayoutParams(params);
        navigationBarView.setBackgroundColor(Color.TRANSPARENT);
        navigationBarView.setVisibility(View.VISIBLE);
    }

    /**
     * 完全沉浸式模式（隐藏状态栏和导航栏）
     */
    public static void enterFullScreen(Activity activity) {
        if (activity == null) return;
        try {
            Window window = activity.getWindow();
            WindowInsetsControllerCompat controller = WindowCompat.getInsetsController(window, window.getDecorView());
            if (controller != null) {
                controller.hide(WindowInsetsCompat.Type.systemBars());
                controller.setSystemBarsBehavior(
                        WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 退出完全沉浸式模式
     */
    public static void exitFullScreen(Activity activity) {
        if (activity == null) return;
        try {
            Window window = activity.getWindow();
            WindowInsetsControllerCompat controller = WindowCompat.getInsetsController(window, window.getDecorView());
            if (controller != null) {
                controller.show(WindowInsetsCompat.Type.systemBars());
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
