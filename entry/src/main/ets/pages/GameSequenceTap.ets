import { PromptAction } from '@kit.ArkUI';
import { getLang, resolveLang, subscribeLang } from '../viewModel/langStore';
import { sequenceTapTexts } from '../viewModel/translations';

type SequenceTapMessageKey = 'start' | 'watch' | 'repeat' | 'correct' | 'wrong';
type SequenceTapFeedbackKey = 'correct' | 'wrong' | '';

@Builder
export function GameSequenceTapBuilder() {
  GameSequenceTap()
}

@Component
export struct GameSequenceTap {
  private colors: string[] = ['red', 'green', 'blue', 'yellow'];
  private readonly correctToastDuration: number = 15;
  private readonly nextRoundDelayMs: number = 2200;
  private uiContext: UIContext = this.getUIContext();
  private promptAction: PromptAction = this.uiContext.getPromptAction();
  pathStack: NavPathStack = new NavPathStack();

  @State lang: string = getLang();
  @State sequence: string[] = [];
  @State inputIndex: number = 0;
  @State level: number = 1;
  @State score: number = 0;
  @State flashColor: string = '';
  @State isShowing: boolean = false;
  @State messageKey: SequenceTapMessageKey = 'start';
  @State tapColor: string = '';
  @State tapFeedbackKey: SequenceTapFeedbackKey = '';

  private sequenceTimerId: number | null = null;
  private tapFeedbackTimerId: number | null = null;
  private unsubLang: (() => void) | null = null;

  onDestroy(): void {
    this.clearSequenceTimer();
    this.clearTapFeedbackTimer();
    if (this.unsubLang) {
      this.unsubLang();
      this.unsubLang = null;
    }
  }

  private clearSequenceTimer(): void {
    if (this.sequenceTimerId !== null) {
      clearTimeout(this.sequenceTimerId);
      this.sequenceTimerId = null;
    }
  }

  private clearTapFeedbackTimer(): void {
    if (this.tapFeedbackTimerId !== null) {
      clearTimeout(this.tapFeedbackTimerId);
      this.tapFeedbackTimerId = null;
    }
  }

  private clearTapFeedback(): void {
    this.clearTapFeedbackTimer();
    this.tapColor = '';
    this.tapFeedbackKey = '';
  }

  private showToast(message: string, duration: number, backgroundColor: string): void {
    try {
      this.promptAction.showToast({
        message: message,
        duration: duration,
        backgroundColor: backgroundColor,
        textColor: '#ffffff',
        backgroundBlurStyle: BlurStyle.NONE
      });
    } catch (e) {
      console.error('GameSequenceTap: failed to show toast', e);
    }
  }

  private getButtonBackgroundColor(color: string): string {
    if (this.flashColor === color) {
      return this.getDisplayColor(color);
    }
    if (this.tapColor === color && this.tapFeedbackKey === 'correct') {
      return '#2e7d32';
    }
    if (this.tapColor === color && this.tapFeedbackKey === 'wrong') {
      return '#c62828';
    }
    return '#2f2f2f';
  }

  private getButtonScale(color: string): number {
    if (this.flashColor === color) {
      return 1.08;
    }
    if (this.tapColor === color) {
      return 1.04;
    }
    return 1;
  }

  private showTapFeedback(color: string, feedbackKey: SequenceTapFeedbackKey): void {
    this.clearTapFeedbackTimer();
    this.tapColor = color;
    this.tapFeedbackKey = feedbackKey;
    this.tapFeedbackTimerId = setTimeout(() => {
      this.tapColor = '';
      this.tapFeedbackKey = '';
      this.tapFeedbackTimerId = null;
    }, 160);
  }

  private randomColor(): string {
    return this.colors[Math.floor(Math.random() * this.colors.length)];
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
        return '#333333';
    }
  }

  private getColorLabel(color: string): string {
    switch (color) {
      case 'red':
        return sequenceTapTexts[this.lang].red;
      case 'green':
        return sequenceTapTexts[this.lang].green;
      case 'blue':
        return sequenceTapTexts[this.lang].blue;
      case 'yellow':
        return sequenceTapTexts[this.lang].yellow;
      default:
        return '';
    }
  }

  private getMessageText(): string {
    switch (this.messageKey) {
      case 'watch':
        return sequenceTapTexts[this.lang].watch;
      case 'repeat':
        return sequenceTapTexts[this.lang].repeat;
      case 'correct':
        return sequenceTapTexts[this.lang].correct;
      case 'wrong':
        return sequenceTapTexts[this.lang].wrong;
      default:
        return sequenceTapTexts[this.lang].start;
    }
  }

  private buildSequence(): string[] {
    const next: string[] = [];
    for (let i = 0; i < this.level + 2; i++) {
      next.push(this.randomColor());
    }
    return next;
  }

  startRound(): void {
    this.clearSequenceTimer();
    this.clearTapFeedback();
    this.sequence = this.buildSequence();
    this.inputIndex = 0;
    this.isShowing = true;
    this.messageKey = 'watch';
    this.playSequence(0);
  }

  private playSequence(index: number): void {
    if (index >= this.sequence.length) {
      this.flashColor = '';
      this.isShowing = false;
      this.messageKey = 'repeat';
      return;
    }

    this.flashColor = this.sequence[index];
    this.sequenceTimerId = setTimeout(() => {
      this.flashColor = '';
      this.sequenceTimerId = setTimeout(() => {
        this.playSequence(index + 1);
      }, 220);
    }, 480);
  }

  onChoose(color: string): void {
    if (this.isShowing || this.sequence.length === 0) {
      return;
    }

    if (color !== this.sequence[this.inputIndex]) {
      this.showTapFeedback(color, 'wrong');
      this.score = Math.max(0, this.score - 5);
      this.level = 1;
      this.sequence = [];
      this.inputIndex = 0;
      this.messageKey = 'wrong';
      this.showToast(sequenceTapTexts[this.lang].wrong, 20, '#c62828');
      return;
    }

    const nextInputIndex = this.inputIndex + 1;
    this.inputIndex = nextInputIndex;

    if (nextInputIndex === this.sequence.length) {
      this.score += 10;
      this.level += 1;
      this.isShowing = true;
      this.messageKey = 'correct';
      this.showToast(sequenceTapTexts[this.lang].correct, this.correctToastDuration, '#2e7d32');
      this.sequenceTimerId = setTimeout(() => {
        this.startRound();
      }, this.nextRoundDelayMs);
    }
  }

  build() {
    NavDestination() {
      Column() {
        Text(sequenceTapTexts[this.lang].title)
          .fontSize(14)
          .margin({ bottom: 4 });

        Row({ space: 10 }) {
          Text(`${sequenceTapTexts[this.lang].level}: ${this.level}`)
            .fontSize(11);
          Text(`${sequenceTapTexts[this.lang].score}: ${this.score}`)
            .fontSize(11);
        }
        .margin({ bottom: 6 });

        Text(this.getMessageText())
          .fontSize(12)
          .height(18)
          .margin({ bottom: 6 });

        Grid() {
          ForEach(this.colors, (color: string, index: number) => {
            GridItem() {
              Button(this.getColorLabel(color))
                .width(64)
                .height(34)
                .fontSize(10)
                .fontColor('#ffffff')
                .backgroundColor(this.getButtonBackgroundColor(color))
                .scale({ x: this.getButtonScale(color), y: this.getButtonScale(color) })
                .animation({ duration: 120, curve: Curve.EaseOut })
                .onClick(() => this.onChoose(color));
            }
          }, (color: string, index: number) => color)
        }
        .width(140)
        .height(76)
        .columnsTemplate('repeat(2, 1fr)')
        .rowsTemplate('repeat(2, 1fr)')
        .columnsGap(6)
        .rowsGap(6)
        .margin({ bottom: 8 });

        Button(sequenceTapTexts[this.lang].start)
          .width(78)
          .height(26)
          .fontSize(10)
          .enabled(!this.isShowing)
          .onClick(() => this.startRound());
      }
      .padding({ top: 12, right: 12, bottom: 10, left: 12 })
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .width('100%')
      .height('100%');
    }
    .onShown(() => {
      this.unsubLang = subscribeLang((newLang: string) => {
        this.lang = resolveLang(sequenceTapTexts, newLang);
      });
    })
    .onHidden(() => {
      this.clearSequenceTimer();
      this.sequence = [];
      this.inputIndex = 0;
      this.flashColor = '';
      this.clearTapFeedback();
      this.isShowing = false;
      this.messageKey = 'start';
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
