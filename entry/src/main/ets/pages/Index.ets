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
          .fontSize(15)
          .margin({ bottom: 10 })

        ArcList() {

          ArcListItem() {
            Button(indexTexts[this.lang].start)
              .width(130)
              .height(32)
              .fontSize(11)
              .margin({ bottom: 8 })
              .onClick(() => {
                this.pathStack.pushPathByName('selectGamePage', null)
              });
          }

          ArcListItem() {
            Button(indexTexts[this.lang].language)
              .width(130)
              .height(32)
              .fontSize(11)
              .margin({ bottom: 8 })
              .onClick(() => {
                this.pathStack.pushPathByName('languagePage', null)
              });
          }

        }
        .space(LengthMetrics.px(12))
        .margin({ bottom: 8 })
        .scrollBar(BarState.Off)

      }
      .padding(12)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
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
