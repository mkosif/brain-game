// xxx.ets
import { webview } from '@kit.ArkWeb';

webview.once('webInited', () => {
  console.log('configCookieSync');
  webview.WebCookieManager.configCookieSync('https://www.google.com', 'a=b');
})

@Component
export struct Home {
  controller: webview.WebviewController = new webview.WebviewController();
  @Link currentBreakpoint: string;
  @Link bottomTabIndex: number;
  build() {
    Column() {
      Web({ src: 'www.google.com', controller: this.controller })
    }
  }
}