import { supportedLangs, getLang, setLang, subscribeLang, Lang } from '../viewModel/langStore';
import { ArcList, ArcListItem, ArcListAttribute } from '@ohos.arkui.ArcList';
import { LengthMetrics } from '@kit.ArkUI';

import { languagePageTexts } from '../viewModel/translations';

@Builder
export function LanguagePageBuilder() {
  LanguagePage()
}

@Component
export struct LanguagePage {
  pathStack: NavPathStack = new NavPathStack()
  @State selected: string = getLang();
  @State lang: string = getLang();

  build() {
    NavDestination() {
      Column() {
        Text(languagePageTexts[this.lang].title)
          .fontSize(16)
          .margin({ bottom: 10 });

        ArcList() {
          ForEach(supportedLangs, (item: Lang) => {
            ArcListItem() {
              Button(item.label)
                .fontSize(12)
                .margin({ bottom: 12 })
                .backgroundColor(this.selected === item.code ? '#3c3cff' : '#333333')
                .onClick(() => {
                  this.selected = item.code;
                  setLang(item.code);
                });
            }
          }, (item: Lang) => JSON.stringify(item));
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
        if (languagePageTexts[newLang]) {
          this.lang = newLang;
        } else {
          this.lang = 'en';
        }
      });
    })
    .hideBackButton(true)
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
    })
  }
}
