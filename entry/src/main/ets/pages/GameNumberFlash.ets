import { numberFlashTexts } from '../viewModel/translations';
import { getLang, subscribeLang } from '../viewModel/langStore';
import { PromptAction } from '@kit.ArkUI';

@Builder
export function NumberFlashPageBuilder() {
  NumberFlashPage();
}

@Component
export struct NumberFlashPage {
  pathStack: NavPathStack = new NavPathStack();
  @State lang: string = getLang();
  @State number: string = '';
  @State showNumber: boolean = true;
  @State level: number = 1;
  @State score: number = 0;
  @State userInput: string = '';
  private uiContext: UIContext = this.getUIContext();
  private promptAction: PromptAction = this.uiContext.getPromptAction();
  private hideTimer: number | null = null;

  onPageHide() {
    if (this.hideTimer) {
      clearTimeout(this.hideTimer);
    }
  }

  generate(): void {
    const digits = this.level + 1;
    this.number = this.randomDigits(digits);
    this.showNumber = true;
    this.userInput = '';

    if (this.hideTimer) {
      clearTimeout(this.hideTimer);
    }

    this.hideTimer = setTimeout(() => {
      this.showNumber = false;
    }, 1200);
  }

  randomDigits(len: number): string {
    let n = '';
    for (let i = 0; i < len; i++) {
      n += Math.floor(Date.now() % 10).toString();
    }
    return n;
  }

  check(): void {
    if (this.userInput === this.number) {
      this.score += 10;
      this.level += 1;

      this.promptAction.showToast({
        message: numberFlashTexts[this.lang].correct,
        duration: 20
      });
    } else {
      this.score -= 5;

      this.promptAction.showToast({
        message: numberFlashTexts[this.lang].wrong,
        duration: 20
      });
    }

    this.generate();
  }

  build() {
    NavDestination() {
      Column() {
        Text(numberFlashTexts[this.lang].title)
          .fontSize(16)
          .margin({ bottom: 5 });
        Row({ space: 5 }) {
          Text(`${numberFlashTexts[this.lang].level}: ${this.level}`)
            .fontSize(12)
            .margin({ bottom: 5 });
          Text(`${numberFlashTexts[this.lang].score}: ${this.score}`)
            .fontSize(12)
            .margin({ bottom: 5 });
        }

        if (this.showNumber) {
          Text(this.number)
            .fontSize(16)
            .margin({ bottom: 5 });
        } else {
          Text(numberFlashTexts[this.lang].hidden)
            .fontSize(16)
            .margin({ bottom: 5 });
        }

        TextInput({
          placeholder: numberFlashTexts[this.lang].inputPlaceholder,
          text: this.userInput
        })
          .onChange((v: string) => this.userInput = v)
          .width(180)
          .margin({ bottom: 5 });

        Button(numberFlashTexts[this.lang].enter)
          .fontSize(12)
          .onClick(() => this.check())
          .margin({ bottom: 5 });

        Button(numberFlashTexts[this.lang].next)
          .fontSize(12)
          .onClick(() => this.generate())
          .margin({ bottom: 5 });

      }
      .padding(20)
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .height('100%')
    }
    .onShown(() => {
      this.generate();
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
