import { numberFlashTexts } from '../viewModel/translations';
import { getLang, resolveLang, subscribeLang } from '../viewModel/langStore';
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
  private unsubLang: (() => void) | null = null;

  private showToast(message: string, duration: number): void {
    try {
      this.promptAction.showToast({
        message: message,
        duration: duration
      });
    } catch (e) {
      console.error('NumberFlashPage: failed to show toast', e);
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
      n += Math.floor(Math.random() * 10).toString();
    }
    return n;
  }

  check(): void {
    if (this.userInput === this.number) {
      this.score += 10;
      this.level += 1;
      this.showToast(numberFlashTexts[this.lang].correct, 20);
    } else {
      this.score -= 5;
      this.showToast(numberFlashTexts[this.lang].wrong, 20);
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
      this.unsubLang = subscribeLang((newLang: string) => {
        this.lang = resolveLang(numberFlashTexts, newLang);
      });
    })
    .onHidden(() => {
      if (this.hideTimer) {
        clearTimeout(this.hideTimer);
        this.hideTimer = null;
      }
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
