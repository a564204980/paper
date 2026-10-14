import { NotebookPaperRim } from './NotebookPaperRim';

/** 跨页纸张的一侧：裁切完整照片的对应半幅，旋转由容器负责。 */
@Component
export struct NotebookPaperPage {
  @Prop pageWidth: number = 164;
  @Prop pageHeight: number = 226;
  @Prop pageNumber: number = 1;
  @Prop imageSource: string = '';
  @Prop isLeft: boolean = false;
  @Prop isBlankBack: boolean = false;
  @Prop hingeBleed: number = 0;

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#E6E6E6')
      // 正反面切换时保留照片节点，避免转到正面后才开始解码而闪出白底。
      if (this.imageSource !== '') {
        Image(this.imageSource)
          .width(this.pageWidth * 2)
          .height(this.pageHeight)
          .objectFit(ImageFit.Cover)
          .position({ x: this.isLeft ? 0 : -this.pageWidth + this.hingeBleed, y: 0 })
          .opacity(this.isBlankBack ? 0 : 1)
      }
      if (!this.isBlankBack && !this.isLeft) {
        Text(`${this.pageNumber}`)
          .fontSize(9)
          .fontColor('rgba(60, 55, 65, 0.30)')
          .margin({ bottom: 9 })
      }
      if (this.imageSource === '' || this.isBlankBack) {
        NotebookPaperRim({
          pageWidth: this.pageWidth, pageHeight: this.pageHeight, isLeft: this.isLeft
        })
      }
    }
    .width(this.pageWidth + this.hingeBleed)
    .height(this.pageHeight)
    .borderRadius({
      topLeft: this.isLeft ? 16 : 1.5,
      bottomLeft: this.isLeft ? 16 : 1.5,
      topRight: this.isLeft ? 1.5 : 16,
      bottomRight: this.isLeft ? 1.5 : 16
    })
    .clip(true)
    .renderGroup(true)
  }
}
