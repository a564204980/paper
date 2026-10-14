import matrix4 from '@ohos.matrix4';
import { NotebookItemData } from '../model/NotebookModel';
import { getPaperMatrix, getSpreadFoldAngle, getSpreadFanOffset, getFoldCameraDistanceFactor,
  getSpreadStackScale } from '../utils/NotebookFoldGeometry';

@Component
export struct NotebookOpeningCover {
  @Prop item: NotebookItemData;
  @Prop progress: number = 0;
  @Prop pageWidth: number = 164;
  @Prop pageHeight: number = 226;
  @Prop relative: number = 0;
  @Prop boundToPages: boolean = false;

  private angle(): number {
    return getSpreadFoldAngle(this.relative, true, this.progress);
  }

  @Builder
  CoverSurface() {
    Stack() {
      if (this.boundToPages || this.progress < 0.5) {
        Row() {
          Column().width(12).height('100%').backgroundColor(this.item.spineColor)
          Stack() {
            if (this.item.coverImage) {
              Image(this.item.coverImage).width('100%').height('100%').objectFit(ImageFit.Cover)
            }
          }.height('100%').layoutWeight(1).backgroundColor(this.item.coverBgColor)
        }.width('100%').height('100%')
          .scale({ x: this.boundToPages ? -1 : 1, y: 1 })
      } else {
        Column().width('100%').height('100%').backgroundColor('#E6E6E6')
      }
    }
    .width(this.pageWidth).height(this.pageHeight)
    .borderRadius({
      topLeft: this.boundToPages ? 16 : 0, bottomLeft: this.boundToPages ? 16 : 0,
      topRight: this.boundToPages ? 1.5 : 14, bottomRight: this.boundToPages ? 1.5 : 14
    }).clip(true)
    .hitTestBehavior(HitTestMode.None)
  }

  build() {
    if (this.boundToPages) {
      Row() {
        Stack() { this.CoverSurface(); }
          .width(this.pageWidth).height(this.pageHeight)
          .rotate({ y: 1, angle: this.angle(), centerX: '100%', centerY: '50%',
            perspective: -this.getUIContext().vp2px(this.pageWidth * 6) / 72 *
              getFoldCameraDistanceFactor(this.angle()) })
        Column().width(this.pageWidth).height(this.pageHeight)
      }
        .width(this.pageWidth * 2).height(this.pageHeight)
        .scale({ x: 1, y: getSpreadStackScale(this.relative, this.progress) })
        .translate({ x: getSpreadFanOffset(this.relative, this.pageWidth, this.progress) })
        .opacity(this.angle() <= 90 ? 0 : 1)
        .zIndex(200)
    } else {
      Stack() { this.CoverSurface(); }
        .width(this.pageWidth).height(this.pageHeight)
        .transform(matrix4.init(getPaperMatrix(this.getUIContext().vp2px(this.pageWidth),
          this.getUIContext().vp2px(this.pageHeight), -170 * this.progress, false)))
        .translate({ x: this.pageWidth / 2 })
        .zIndex(this.progress < 0.5 ? 200 : 0)
    }
  }
}
