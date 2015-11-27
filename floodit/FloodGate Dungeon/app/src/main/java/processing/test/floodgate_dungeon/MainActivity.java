package processing.test.floodgate_dungeon;
import android.app.Activity;
import android.os.Bundle;
import android.view.Window;
import android.view.WindowManager;
import android.widget.FrameLayout;
import android.view.ViewGroup.LayoutParams;
import android.app.FragmentTransaction;
import processing.core.PApplet;

import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.AdView;
public class MainActivity extends Activity {
    private AdView mAdView;
    PApplet fragment;
    private static final String MAIN_FRAGMENT_TAG = "main_fragment";
    int viewId = 0x1000;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Window window = getWindow();
        requestWindowFeature(Window.FEATURE_NO_TITLE);
window.setFlags(WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN, WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN);
window.setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        FrameLayout frame = new FrameLayout(this);
        frame.setId(viewId);
        setContentView(frame, new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT));
        if (savedInstanceState == null) {
            fragment = new FloodGate_Dungeon();
            FragmentTransaction ft = getFragmentManager().beginTransaction();
            ft.add(frame.getId(), fragment, MAIN_FRAGMENT_TAG).commit();
        } else {
            fragment = (PApplet) getFragmentManager().findFragmentByTag(MAIN_FRAGMENT_TAG);
        }
        //AdView mAdView = (AdView) findViewById(R.id.adView);
        mAdView = new AdView(this);
        mAdView.setAdUnitId("@string/banner_ad_unit_id");
        mAdView.setAdSize(com.google.android.gms.ads.AdSize.SMART_BANNER);
        AdRequest adRequest = new AdRequest.Builder().build(); //.addTestDevice("7122F4CF0D8FFB06C3424AEF78FEE12B")
        mAdView.loadAd(adRequest);
    }
    @Override
    public void onBackPressed() {
        fragment.onBackPressed();
        super.onBackPressed();
    }
}
