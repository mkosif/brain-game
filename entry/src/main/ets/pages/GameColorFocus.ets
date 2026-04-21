import { colorFocusTexts } from '../viewModel/translations';
import { getLang, resolveLang, subscribeLang } from '../viewModel/langStore';
import { PromptAction } from '@kit.ArkUI';
import { secureRandomNumber } from '../utils/SecureRandom';

@Builder
export function GameColorFocusBuilder() {
  GameColorFocus();
}
@Component
export struct GameColorFocus {
  private colors: string[] = ['red', 'green', 'blue', 'yellow'];
  private readonly feedbackDurationMs: number = 900;
  private uiContext: UIContext = this.getUIContext();
  private promptAction: PromptAction = this.uiContext.getPromptAction();
  pathStack: NavPathStack = new NavPathStack()
  @State lang: string = getLang();
  @State word: string = '';
  @State displayColor: string = 'black';
  @State score: number = 0;
  @State timeLeft: number = 20;
  @State feedbackKey: 'correct' | 'wrong' | '' = '';

  private timerId: number | null = null;
  private unsubLang: (() => void) | null = null;
  private feedbackTimerId: number | null = null;

  onDestroy(): void {
    if (this.timerId) {
      clearInterval(this.timerId);
    }
    this.clearFeedbackTimer();
  }

  private getDisplayColor(color: string): string {
    switch (color) {
      case 'red':
        return '#d32f2f';
      case 'green':
        return '#2e7d32';
      case 'blue':
        return '#1565c0';
      case 'yellow':
        return '#c49000';
      default:
        return 'black';
    }
  }

  private showToast(message: string, duration: number): void {
    try {
      this.promptAction.showToast({
        message: message,
        duration: duration
      });
    } catch (e) {
      console.error('GameColorFocus: failed to show toast', e);
    }
  }

  private pickRandomWord(): void {
    const wIndex = Math.floor(secureRandomNumber() * this.colors.length);
    let cIndex = Math.floor(secureRandomNumber() * this.colors.length);

    if (secureRandomNumber() > 0.4) {
      while (cIndex === wIndex) {
        cIndex = Math.floor(secureRandomNumber() * this.colors.length);
      }
    }

    this.word = this.colors[wIndex];
    this.displayColor = this.getDisplayColor(this.colors[cIndex]);
  }

  private startTimer(): void {
    if (this.timerId) {
      clearInterval(this.timerId);
    }
    this.timeLeft = 20;
    this.timerId = setInterval(() => {
      this.timeLeft -= 1;

      if (this.timeLeft <= 0) {
        clearInterval(this.timerId!);
        this.timerId = null;
        this.showToast(`${colorFocusTexts[this.lang].score}: ${this.score}`, 30);
        this.score = 0;
        this.pickRandomWord();
        this.startTimer();
      }
    }, 1000);
  }

  private clearFeedbackTimer(): void {
    if (this.feedbackTimerId) {
      clearTimeout(this.feedbackTimerId);
      this.feedbackTimerId = null;
    }
  }

  private showFeedback(result: 'correct' | 'wrong'): void {
    this.feedbackKey = result;
    this.clearFeedbackTimer();
    this.feedbackTimerId = setTimeout(() => {
      this.feedbackKey = '';
      this.feedbackTimerId = null;
    }, this.feedbackDurationMs);
  }

  onChoose(choice: string): void {
    if (choice === this.word) {
      this.score += 10;
      this.showFeedback('correct');
    } else {
      this.score -= 5;
      this.showFeedback('wrong');
    }

    this.pickRandomWord();
  }

  build(): void {
    NavDestination(){
    Column() {
      Column({ space: 4 }) {
        Text(`${colorFocusTexts[this.lang].time}: ${this.timeLeft}s`)
          .fontSize(12);
        Text(`${colorFocusTexts[this.lang].score}: ${this.score}`)
          .fontSize(14);
      }
      .margin({ bottom: 12 });

      Column() {
        Text(colorFocusTexts[this.lang][this.word])
          .fontSize(20)
          .fontColor(this.displayColor);
      }
      .margin({ bottom: 14 });

      Row({space: 10}) {
        Button(colorFocusTexts[this.lang].red)
          .fontSize(12)
          .width(70)
          .height(30)
          .onClick(() => this.onChoose('red'));

        Button(colorFocusTexts[this.lang].green)
          .fontSize(12)
          .width(70)
          .height(30)
          .onClick(() => this.onChoose('green'));
      }.margin({ bottom: 8 });

      Row({space: 10}) {
        Button(colorFocusTexts[this.lang].blue)
          .fontSize(12)
          .width(70)
          .height(30)
          .onClick(() => this.onChoose('blue'));

        Button(colorFocusTexts[this.lang].yellow)
          .fontSize(12)
          .width(70)
          .height(30)
          .onClick(() => this.onChoose('yellow'));
      }.margin({ bottom: 12 });
      if (this.feedbackKey) {
        Text(colorFocusTexts[this.lang][this.feedbackKey])
          .fontSize(14)
          .fontColor(this.feedbackKey === 'correct' ? '#2e7d32' : '#c62828')
          .height(20)
          .margin({ top: 6 });
      } else {
        Text(' ')
          .fontSize(14)
          .height(20)
          .opacity(0)
          .margin({ top: 6 });
      }
    }
    .padding(20)
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height('100%')
  }
    .onShown(() => {
      this.pickRandomWord();
      this.startTimer();
      this.unsubLang = subscribeLang((newLang: string) => {
        this.lang = resolveLang(colorFocusTexts, newLang);
      });
    })
    .onHidden(() => {
      if (this.timerId) {
        clearInterval(this.timerId);
        this.timerId = null;
      }
      this.feedbackKey = '';
      this.clearFeedbackTimer();
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
