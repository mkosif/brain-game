import { PromptAction } from '@kit.ArkUI';
import { getLang, subscribeLang } from '../viewModel/langStore';
import { memoryGridTexts } from '../viewModel/translations';

@Builder
export function GameMemoryBlockPageBuilder() {
  GameMemoryBlock()
}

@Component
export struct GameMemoryBlock {
  @State openedIndices: number[] = [];
  @State matchedList: number[] = [];
  @State icons: string[] = ['⭐', '⭕', '🔥', '🌟', '⭐', '⭕', '🔥', '🌟'];
  @State timer: number = 0;
  @State moves: number = 0;
  @State gameOver: boolean = false;
  @State lang: string = getLang();
  private uiContext: UIContext = this.getUIContext();
  private promptAction: PromptAction = this.uiContext.getPromptAction();
  timerId: number | null = null;
  pathStack: NavPathStack = new NavPathStack()
  private unsubLang: (() => void) | null = null;

  startGame(): void {
    this.prepareIcons();
    this.timer = 0;
    this.moves = 0;
    this.gameOver = false;

    if (this.timerId !== null) {
      clearInterval(this.timerId);
    }
    this.timerId = setInterval(() => {
      this.timer = this.timer + 1;
    }, 1000);
  }

  prepareIcons(): void {
    const baseIcons = ['⭐', '⭕', '🔥', '🌟'];
    this.icons = [...baseIcons, ...baseIcons];
    this.shuffle();
  }

  shuffle(): void {
    const newIcons = [...this.icons];
    for (let i = newIcons.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      let temp = newIcons[i];
      newIcons[i] = newIcons[j];
      newIcons[j] = temp;
    }
    this.icons = newIcons;
    this.openedIndices = [];
    this.matchedList = [];
  }

  checkMatch(i: number): void {
    if (this.openedIndices.length === 2) {
      return;
    }
    if (this.openedIndices.includes(i) || this.matchedList.includes(i) || this.gameOver) {
      return;
    }

    this.openedIndices = [...this.openedIndices, i];

    if (this.openedIndices.length === 2) {
      this.moves = this.moves + 1;
      const firstIndex = this.openedIndices[0];
      const secondIndex = this.openedIndices[1];

      if (this.icons[firstIndex] === this.icons[secondIndex]) {
        setTimeout(() => {
          this.matchedList = [...this.matchedList, firstIndex, secondIndex];
          this.openedIndices = [];
          if (this.matchedList.length === this.icons.length) {
            this.gameOver = true;
            if (this.timerId !== null) {
              clearInterval(this.timerId);
            }
            const msg = `${memoryGridTexts[this.lang].completed.replace('{time}', this.timer.toString())
              .replace('{moves}', this.moves.toString())}`;
            this.promptAction.showToast({ message: msg, duration: 30 });
          }
        }, 300);
      } else {
        setTimeout(() => {
          this.openedIndices = [];
        }, 600);
      }
    }
  }

  build() {
    NavDestination() {
      Column() {
        Text(memoryGridTexts[this.lang].title)
          .fontSize(16)
          .margin({ top: 8 })
        Text(`${memoryGridTexts[this.lang].time}: ${this.timer}s | ${memoryGridTexts[this.lang].moves}: ${this.moves}`)
          .fontSize(12)
          .margin({ top: 8 })
        Grid() {
          ForEach(this.icons.length > 0 ? this.icons : ['❓'], (item: string, index: number) => {
            GridItem() {
              Button(
                (this.openedIndices.includes(index) || this.matchedList.includes(index))
                  ? item
                  : '❓'
              )
                .width(45)
                .height(45)
                .fontSize(10)
                .alignSelf(ItemAlign.Center)
                .onClick(() => this.checkMatch(index));
            }
          }, (item: string, index: number) => index.toString())
        }
        .height('50%')
        .columnsTemplate('repeat(4, 0.9fr)')
        .rowsTemplate('repeat(2, 0.5fr)');

        Button(memoryGridTexts[this.lang].restart)
          .fontSize(12)
          .onClick(() => this.startGame())
          .margin({ top: 8 })
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .height('100%')
      .padding(20);
    }
    .onShown(() => {
      this.startGame();
      this.unsubLang = subscribeLang((newLang: string) => {
        if (memoryGridTexts[newLang]) {
          this.lang = newLang;
        } else {
          this.lang = 'en';
        }
      });
    })
    .onHidden(() => {
      if (this.timerId !== null) {
        clearInterval(this.timerId);
        this.timerId = null;
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
