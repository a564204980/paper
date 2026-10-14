import { NotebookItemData } from '../model/NotebookModel';
import { getSpreadFoldAngle, getSpreadFanOffset, getFoldCameraDistanceFactor, getSpreadStackScale } from '../utils/NotebookFoldGeometry';
import { NotebookPaperPage } from './NotebookPaperPage';

/** 每组跨页独立展开和位移，左右硬纸页绕该组自己的折线旋转。 */
@Component
export struct NotebookSpreadSheet {
  @Prop item: NotebookItemData;
  @Prop spreadIndex: number = 0;
  @Prop relative: number = 0;
  @Prop openingProgress: number = 1;
  @Prop pageWidth: number = 164;
  @Prop pageHeight: number = 226;
  onSelect?: (index: number) => void;
  onTurn?: (direction: number) => void;

  private angle(left: boolean): number {
    return getSpreadFoldAngle(this.relative, left, this.openingProgress);
  }

  private cameraDistance(left: boolean): number {
    // ArkUI 的旋转相机以英寸为单位，1 英寸对应 72 px。
    return -this.getUIContext().vp2px(this.pageWidth * 6) / 72 *
      getFoldCameraDistanceFactor(this.angle(left));
  }

  private hingeBleed(): number {
    // 照片在中缝多覆盖一个物理像素，填补两侧独立裁切后的抗锯齿亮线。
    // 封面翻过书脊前收回补边，避免合拢时照片越过封面左缘。
    const exposed = Math.min(1, Math.max(0, (this.openingProgress - 0.5) * 2));
    return this.item.pages?.[this.spreadIndex] ? this.getUIContext().px2vp(1) * exposed : 0;
  }

  private click(left: boolean): void {
    if (Math.abs(this.relative) < 0.05 && this.onTurn) {
      this.onTurn(left ? -1 : 1);
    } else if (this.onSelect) {
      this.onSelect(this.spreadIndex);
    }
  }

  build() {
    Row() {
      Stack({ alignContent: Alignment.TopStart }) {
        NotebookPaperPage({
        pageWidth: this.pageWidth, pageHeight: this.pageHeight,
        pageNumber: this.spreadIndex + 1, isLeft: true,
        imageSource: this.item.pages?.[this.spreadIndex] || '',
        isBlankBack: Math.abs(this.angle(true)) > 90, hingeBleed: this.hingeBleed()
        })
      }
        .width(this.pageWidth).height(this.pageHeight)
        .rotate({ y: 1, angle: this.angle(true), centerX: '100%', centerY: '50%',
          perspective: this.cameraDistance(true) })
        .opacity(Math.abs(this.angle(true)) > 90 ? 0 : 1)
        .zIndex(this.relative < 0 ? 2 : 1)
        .onClick(() => { this.click(true); })
      Stack({ alignContent: Alignment.TopStart }) {
        NotebookPaperPage({
        pageWidth: this.pageWidth, pageHeight: this.pageHeight,
        pageNumber: this.spreadIndex + 1, isLeft: false,
        imageSource: this.item.pages?.[this.spreadIndex] || '',
        isBlankBack: Math.abs(this.angle(false)) > 90, hingeBleed: this.hingeBleed()
        })
          .position({ x: -this.hingeBleed(), y: 0 })
      }
        .width(this.pageWidth).height(this.pageHeight)
        .rotate({ y: 1, angle: this.angle(false), centerX: '0%', centerY: '50%',
          perspective: this.cameraDistance(false) })
        .opacity(Math.abs(this.angle(false)) > 90 ? 0 : 1)
        .zIndex(this.relative < 0 ? 1 : 2)
        .onClick(() => { this.click(false); })
    }
    .width(this.pageWidth * 2).height(this.pageHeight)
    .scale({ x: 1, y: getSpreadStackScale(this.relative, this.openingProgress) })
    .translate({ x: getSpreadFanOffset(this.relative, this.pageWidth, this.openingProgress) })
    .zIndex(100 - Math.abs(this.relative) * 10)
    .hitTestBehavior(HitTestMode.Transparent)
  }
}
