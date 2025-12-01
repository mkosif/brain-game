import { getLang, subscribeLang } from '../viewmodel/langStore';
import { selectGameTexts } from '../viewmodel/translations';
import { ArcList, ArcListItem, ArcListAttribute } from '@ohos.arkui.ArcList';
import { LengthMetrics } from '@kit.ArkUI';

@Builder
export function SelectGamePageBuilder() {
  SelectGamePage()
}

@Component
export struct SelectGamePage {
  pathStack: NavPathStack = new NavPathStack()
  @State lang: string = getLang();

  build() {
    NavDestination() {
      Column() {
        Text(selectGameTexts[this.lang].title)
          .fontSize(16)
          .margin({ bottom: 20 });
        ArcList() {
          ArcListItem() {
            Button(selectGameTexts[this.lang].colorFocus)
              .fontSize(12)
              .margin({ bottom: 20 })
              .onClick(() => {
                this.pathStack.pushPathByName('gameColorFocus', null);
              });
          }

          ArcListItem() {
            Button(selectGameTexts[this.lang].numberFlash)
              .fontSize(12)
              .margin({ bottom: 20 })
              .onClick(() => {
                this.pathStack.pushPathByName('gameNumberFlash', null);
              });
          }

          ArcListItem() {
            Button(selectGameTexts[this.lang].memoryBlock)
              .margin({ bottom: 20 })
              .fontSize(12)
              .onClick(() => {
                this.pathStack.pushPathByName('gameMemoryBlock', null);
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
    .onShown(() => {
      subscribeLang((newLang: string) => {
        this.lang = newLang;
      });
    })
    .hideBackButton(true)
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
    })
  }
}
