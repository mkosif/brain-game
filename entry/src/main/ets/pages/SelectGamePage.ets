import { getLang, resolveLang, subscribeLang } from '../viewModel/langStore';
import { selectGameTexts } from '../viewModel/translations';
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
  private unsubLang: (() => void) | null = null;

  build() {
    NavDestination() {
      Column() {
        Text(selectGameTexts[this.lang].title)
          .fontSize(14)
          .margin({ bottom: 8 });
        ArcList() {
          ArcListItem() {
            Button(selectGameTexts[this.lang].colorFocus)
              .width(118)
              .height(30)
              .fontSize(11)
              .margin({ bottom: 6 })
              .onClick(() => {
                this.pathStack.pushPathByName('gameColorFocus', null);
              });
          }

          ArcListItem() {
            Button(selectGameTexts[this.lang].numberFlash)
              .width(118)
              .height(30)
              .fontSize(11)
              .margin({ bottom: 6 })
              .onClick(() => {
                this.pathStack.pushPathByName('gameNumberFlash', null);
              });
          }

          ArcListItem() {
            Button(selectGameTexts[this.lang].memoryBlock)
              .width(118)
              .height(30)
              .margin({ bottom: 6 })
              .fontSize(11)
              .onClick(() => {
                this.pathStack.pushPathByName('gameMemoryBlock', null);
              });
          }
        }
        .space(LengthMetrics.px(10))
        .margin({ bottom: 8 })
        .scrollBar(BarState.Off)
      }
      .padding(12)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .width('100%')
      .height('100%')
    }
    .onShown(() => {
      this.unsubLang = subscribeLang((newLang: string) => {
        this.lang = resolveLang(selectGameTexts, newLang);
      });
    })
    .onHidden(() => {
      if (this.unsubLang) {
        this.unsubLang();
        this.unsubLang = null;
      }
    })
    .hideBackButton(true)
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
    })
  }
}
