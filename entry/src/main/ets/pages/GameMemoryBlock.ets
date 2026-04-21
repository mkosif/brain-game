import { PromptAction } from '@kit.ArkUI';
import { getLang, resolveLang, subscribeLang } from '../viewModel/langStore';
import { memoryGridTexts } from '../viewModel/translations';
import { secureRandomNumber } from '../utils/SecureRandom';

const STATE_CLOSED  = 0;
const STATE_OPENED  = 1;
const STATE_MATCHED = 2;

function encodeCard(pos: number, cardId: number, state: number): number {
  return pos * 100 + cardId * 10 + state;
}

function decodePos(data: number): number {
  return Math.floor(data / 100);
}

function decodeCardId(data: number): number {
  return Math.floor((data % 100) / 10);
}

function decodeState(data: number): number {
  return data % 10;
}

@Builder
export function GameMemoryBlockPageBuilder() {
  GameMemoryBlock()
}

@Component
export struct GameMemoryBlock {
  @State cardData: number[] = [];
  @State timer: number = 0;
  @State moves: number = 0;
  @State gameOver: boolean = false;
  @State lang: string = getLang();

  private uiContext: UIContext = this.getUIContext();
  private promptAction: PromptAction = this.uiContext.getPromptAction();
  timerId: number | null = null;
  pathStack: NavPathStack = new NavPathStack();
  private unsubLang: (() => void) | null = null;
  private pendingTurnTimerId: number | null = null;
  private openedPos: number[] = [];

  onDestroy(): void {
    this.clearGameTimers();
  }

  private clearGameTimers(): void {
    if (this.timerId !== null) {
      clearInterval(this.timerId);
      this.timerId = null;
    }
    if (this.pendingTurnTimerId !== null) {
      clearTimeout(this.pendingTurnTimerId);
      this.pendingTurnTimerId = null;
    }
  }

  private showToast(message: string, duration: number): void {
    try {
      this.promptAction.showToast({ message: message, duration: duration });
    } catch (e) {
      console.error('GameMemoryBlock: failed to show toast', e);
    }
  }

  private getCardSymbol(cardId: number): string {
    switch (cardId) {
      case 0: return '⭐';
      case 1: return '⭕';
      case 2: return '🔥';
      case 3: return '🌟';
      default: return '❓';
    }
  }

  private setOneCardState(pos: number, state: number): void {
    const next: number[] = [...this.cardData];
    next[pos] = encodeCard(pos, decodeCardId(next[pos]), state);
    this.cardData = next;
  }

  private setTwoCardStates(pos1: number, state1: number, pos2: number, state2: number): void {
    const next: number[] = [...this.cardData];
    next[pos1] = encodeCard(pos1, decodeCardId(next[pos1]), state1);
    next[pos2] = encodeCard(pos2, decodeCardId(next[pos2]), state2);
    this.cardData = next;
  }

  private countMatched(): number {
    let n = 0;
    for (let i = 0; i < this.cardData.length; i++) {
      if (decodeState(this.cardData[i]) === STATE_MATCHED) {
        n++;
      }
    }
    return n;
  }

  startGame(): void {
    this.clearGameTimers();
    this.openedPos = [];
    this.timer = 0;
    this.moves = 0;
    this.gameOver = false;
    this.cardData = this.buildShuffledDeck();
    this.timerId = setInterval(() => { this.timer += 1; }, 1000);
  }

  private buildShuffledDeck(): number[] {
    const ids: number[] = [0, 1, 2, 3, 0, 1, 2, 3];
    for (let i = ids.length - 1; i > 0; i--) {
      const j = Math.floor(secureRandomNumber() * (i + 1));
      const tmp = ids[i];
      ids[i] = ids[j];
      ids[j] = tmp;
    }
    const deck: number[] = [];
    for (let i = 0; i < ids.length; i++) {
      deck.push(encodeCard(i, ids[i], STATE_CLOSED));
    }
    return deck;
  }

  checkMatch(pos: number): void {
    if (this.openedPos.length === 2 || this.pendingTurnTimerId !== null || this.gameOver) {
      return;
    }
    const currentState = decodeState(this.cardData[pos]);
    if (currentState === STATE_OPENED || currentState === STATE_MATCHED) {
      return;
    }

    this.setOneCardState(pos, STATE_OPENED);
    this.openedPos = [...this.openedPos, pos];

    if (this.openedPos.length < 2) {
      return;
    }

    this.moves += 1;
    const first = this.openedPos[0];
    const second = this.openedPos[1];
    const firstCardId = decodeCardId(this.cardData[first]);
    const secondCardId = decodeCardId(this.cardData[second]);

    if (firstCardId === secondCardId) {
      this.openedPos = [];
      this.setTwoCardStates(first, STATE_MATCHED, second, STATE_MATCHED);

      if (this.countMatched() === this.cardData.length) {
        this.gameOver = true;
        if (this.timerId !== null) {
          clearInterval(this.timerId);
          this.timerId = null;
        }
        const msg = memoryGridTexts[this.lang].completed
          .replace('{time}', this.timer.toString())
          .replace('{moves}', this.moves.toString());
        this.showToast(msg, 30);
      }
    } else {
      this.pendingTurnTimerId = setTimeout(() => {
        this.setTwoCardStates(first, STATE_CLOSED, second, STATE_CLOSED);
        this.openedPos = [];
        this.pendingTurnTimerId = null;
      }, 600);
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
          ForEach(this.cardData, (data: number) => {
            GridItem() {
              Button(
                decodeState(data) !== STATE_CLOSED
                  ? this.getCardSymbol(decodeCardId(data))
                  : '❓'
              )
                .width(45)
                .height(45)
                .fontSize(10)
                .fontColor($r('app.color.card_font_color'))
                .backgroundColor(
                  decodeState(data) === STATE_MATCHED ? $r('app.color.card_bg_matched') :
                  decodeState(data) === STATE_OPENED  ? $r('app.color.card_bg_opened') :
                  $r('app.color.card_bg_closed')
                )
                .alignSelf(ItemAlign.Center)
                .onClick(() => this.checkMatch(decodePos(data)));
            }
          }, (data: number) => data.toString())
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
        this.lang = resolveLang(memoryGridTexts, newLang);
      });
    })
    .onHidden(() => {
      this.clearGameTimers();
      this.openedPos = [];
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
