import { colorFocusTexts } from '../viewModel/translations';
import { getLang, subscribeLang } from '../viewModel/langStore';
import { PromptAction } from '@kit.ArkUI';


@Builder
export function GameColorFocusBuilder() {
  GameColorFocus();
}
@Component
export struct GameColorFocus {
  private colors: string[] = ['red', 'green', 'blue', 'yellow'];
  private uiContext: UIContext = this.getUIContext();
  private promptAction: PromptAction = this.uiContext.getPromptAction();
  pathStack: NavPathStack = new NavPathStack()
  @State lang: string = getLang();
  @State word: string = '';
  @State displayColor: string = 'black';
  @State score: number = 0;
  @State timeLeft: number = 20;

  private timerId: number | null = null;


  onDestroy(): void {
    if (this.timerId) {
      clearInterval(this.timerId);
    }
  }

  private pickRandomWord(): void {
    const wIndex = Math.floor(Date.now() % this.colors.length);
    let cIndex = Math.floor(Date.now() % this.colors.length);

    if ((Date.now() % 100) / 100 > 0.4) {
      while (cIndex === wIndex) {
        cIndex = Math.floor(Date.now() % this.colors.length);
      }
    }

    this.word = this.colors[wIndex];
    this.displayColor = this.colors[cIndex];
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
        this.promptAction.showToast({
          message: `${colorFocusTexts[this.lang].score}: ${this.score}`,
          duration: 30
        });
        this.score = 0;
        this.startTimer();
      }
    }, 1000);
  }

  onChoose(choice: string): void {
    if (choice === this.word) {
      this.score += 10;
      this.promptAction.showToast({
        message: colorFocusTexts[this.lang].correct,
        duration: 10
      });
    } else {
      this.score -= 5;
      this.promptAction.showToast({
        message: colorFocusTexts[this.lang].wrong,
        duration: 10
      });
    }

    this.pickRandomWord();
  }

  build(): void {
    NavDestination(){
    Column() {

      Text(colorFocusTexts[this.lang].title)
        .fontSize(16)
        .margin({ bottom: 8 });


      Text(`${colorFocusTexts[this.lang].time}: ${this.timeLeft}s`)
        .fontSize(12)
        .margin({ bottom: 8 });


      Text(colorFocusTexts[this.lang][this.word])
        .fontSize(18)
        .fontColor(this.displayColor)
        .margin({ bottom: 12 });


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


      Text(`${colorFocusTexts[this.lang].score}: ${this.score}`)
        .fontSize(14)
        .margin({ top: 8 });
    }
    .padding(20)
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height('100%')
  }
    .onShown(() => {
      this.pickRandomWord();
      this.startTimer();

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
