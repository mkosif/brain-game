import { ArcList, ArcListItem, ArcListAttribute } from '@ohos.arkui.ArcList';
import { LengthMetrics } from '@kit.ArkUI';
import { getLang, resolveLang, subscribeLang } from '../viewModel/langStore';
import { indexTexts } from '../viewModel/translations';

@Entry
@Component
struct Index {
  pathStack: NavPathStack = new NavPathStack()
  @State lang: string = getLang();

  build() {
    Navigation(this.pathStack) {
      Column() {
        Text(indexTexts[this.lang].title)
          .fontSize(16)
          .margin({ bottom: 20 })

        ArcList() {

          ArcListItem() {
            Button(indexTexts[this.lang].start)
              .fontSize(12)
              .margin({ bottom: 20 })
              .onClick(() => {
                this.pathStack.pushPathByName('selectGamePage', null)
              });
          }

          ArcListItem() {
            Button(indexTexts[this.lang].language)
              .fontSize(12)
              .margin({ bottom: 20 })
              .onClick(() => {
                this.pathStack.pushPathByName('languagePage', null)
              });
          }

        }
        .space(LengthMetrics.px(30))
        .margin({ bottom: 20 })
        .scrollBar(BarState.Off)

      }
      .padding(20)
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .height('100%')
    }
    .onAppear(() => {
      subscribeLang((newLang: string) => {
        this.lang = resolveLang(indexTexts, newLang);
      });
    })
    .hideTitleBar(true)
    .hideBackButton(true)
    .hideToolBar(true)
    .mode(NavigationMode.Stack)
  }
}
