import lottie, { AnimationItem } from '@ohos/lottie';

@Entry
@Component
struct SplashScreen {
  private renderingSettings: RenderingContextSettings = new RenderingContextSettings(true)
  private canvasRenderingContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.renderingSettings)
  private animateItem: AnimationItem | null = null;
  private animateName: string = 'animation'; // name

  async aboutToAppear(): Promise<void> {
    setTimeout(() => {
      this.getUIContext().getRouter().pushUrl(
        {
          url: 'pages/Index'
        }
      ).catch(() => {
        // TODO: Implement error handling.
      })

    }, 2000)
  }

  build() {
    Column() {
      Canvas(this.canvasRenderingContext)
        .width(200)
        .height(200)
        .backgroundColor(Color.White)
        .onReady(() => {
          // Load the animation.
          if (this.animateItem != null) {
            // Load animations during canvas onReady, ensure that the animation size is correct.
            this.animateItem?.resize();
          } else {
            // Anti-aliasing settings.
            this.canvasRenderingContext.imageSmoothingEnabled = true;
            this.canvasRenderingContext.imageSmoothingQuality = 'medium'
            //this.loadAnimation();
          }
        })
    }
    .height('100%')
    .width('100%').justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
  }

  // loadAnimation() {
  //   this.animateItem = lottie.loadAnimation({
  //     container: this.canvasRenderingContext,
  //     renderer: 'canvas', // canvas renderer
  //     loop: true,
  //     autoplay: false,
  //     name: this.animateName,
  //     contentMode: 'Contain',
  //     path: 'common/animation.json'
  //   })
  //   // Animations are loaded asynchronously
  //   this.animateItem.addEventListener('DOMLoaded', (args: Object): void => {
  //     this.animateItem!.changeColor([225, 25, 100, 1]);
  //     this.animateItem!.play()
  //   });
  // }
}