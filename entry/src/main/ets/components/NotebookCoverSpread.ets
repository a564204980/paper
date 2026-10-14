import { NotebookItemData } from '../model/NotebookModel';
import { getSpreadFoldAngle, getSpreadFanOffset, getFoldCameraDistanceFactor, getSpreadStackScale } from '../utils/NotebookFoldGeometry';

/** 前后硬纸壳始终作为书本基底，不计入照片页数。 */
@Component
export struct NotebookCoverSpread {
  @Prop item: NotebookItemData;
  @Prop openingProgress: number = 1;
  @Prop pageWidth: number = 164;
  @Prop pageHeight: number = 226;
  @Prop leftRelative: number = 0;
  @Prop rightRelative: number = 0;
  @Prop boundToPages: boolean = false;

  private relative(left: boolean): number {
    return left ? this.leftRelative : this.rightRelative;
  }

  private angle(left: boolean): number {
    return getSpreadFoldAngle(this.relative(left), left, this.openingProgress);
  }

  @Builder
  CoverInside(left: boolean) {
    Stack() {
    Column()
      .width(this.pageWidth)
      .height(this.pageHeight)
      .backgroundColor('#E6E6E6')
      .border({ width: this.boundToPages ? 0 : 2, color: this.item.coverBgColor })
      .borderRadius({
        topLeft: left ? 16 : 1.5,
        bottomLeft: left ? 16 : 1.5,
        topRight: left ? 1.5 : 16,
        bottomRight: left ? 1.5 : 16
      })
      .rotate({
        y: 1, angle: this.angle(left),
        centerX: left ? '100%' : '0%', centerY: '50%',
        perspective: -this.getUIContext().vp2px(this.pageWidth * 6) / 72 *
          (this.boundToPages ? getFoldCameraDistanceFactor(this.angle(left)) : 1)
      })
      .opacity(Math.abs(this.angle(left)) > 90 ? 0 : 1)
    }
      .width(this.pageWidth).height(this.pageHeight)
      .scale({ x: 1, y: getSpreadStackScale(this.relative(left), this.openingProgress) })
      .translate({ x: getSpreadFanOffset(this.relative(left), this.pageWidth, this.openingProgress) })
  }

  build() {
    Row() {
      this.CoverInside(true);
      this.CoverInside(false);
    }
    .width(this.pageWidth * 2)
    .height(this.pageHeight)
    .hitTestBehavior(HitTestMode.None)
  }
}
