package com.ttdyce.concept_nhv;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import android.webkit.CookieManager;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "samples.flutter.dev/cookies";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("readCloudflareCookies")) {
                                String cookies = readCloudflareCookies();

                                if (!cookies.isEmpty()) {
                                    result.success(cookies);
                                } else {
                                    result.error("UNAVAILABLE", "readCloudflareCookies error", null);
                                }
                            } else {
                                result.notImplemented();
                            }
                        });
    }

    private String readCloudflareCookies() {
        return CookieManager.getInstance().getCookie("https://nhentai.net");
    }
}
