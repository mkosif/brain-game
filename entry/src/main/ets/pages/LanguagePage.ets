import { supportedLangs, getLang, setLang, resolveLang, subscribeLang, Lang } from '../viewModel/langStore';
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
  private unsubLang: (() => void) | null = null;

  build() {
    NavDestination() {
      Column() {
        Text(languagePageTexts[this.lang].title)
          .fontSize(14)
          .margin({ bottom: 6 });

        ArcList() {
          ForEach(supportedLangs, (item: Lang) => {
            ArcListItem() {
              Button(item.label)
                .width(118)
                .height(28)
                .fontSize(11)
                .margin({ bottom: 5 })
                .backgroundColor(this.selected === item.code ? '#3c3cff' : '#333333')
                .onClick(() => {
                  this.selected = item.code;
                  setLang(item.code);
                });
            }
          }, (item: Lang) => JSON.stringify(item));
        }
        .space(LengthMetrics.px(8))
        .margin({ bottom: 6 })
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
        const resolvedLang = resolveLang(languagePageTexts, newLang);
        this.lang = resolvedLang;
        this.selected = resolvedLang;
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
