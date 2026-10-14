import { NotebookItemData } from '../model/NotebookModel';
import { clampSpreadIndex, getNotebookSpreadCount, getVisibleSpreadIndices } from '../utils/NotebookPageUtils';
import { NotebookMotionController } from '../utils/NotebookMotionController';
import { NotebookSpreadSheet } from './NotebookSpreadSheet';
import { NotebookOpeningCover } from './NotebookOpeningCover';
import { NotebookCoverSpread } from './NotebookCoverSpread';

/** 调度各组跨页的展开与页叠位移，每组保留独立的折线及内容。 */
@Component
export struct OpenBookSpread {
  @Prop item: NotebookItemData;
  @Prop pageIndex: number = 0;
  @Prop isLandscape: boolean = false;
  @Prop availableWidth: number = 500;
  @Prop availableHeight: number = 300;
  @Prop @Watch('handleClosing') isClosing: boolean = false;
  onPageChange?: (index: number) => void;
  onClosed?: () => void;
  @State private spreadPosition: number = 0;
  @State private openingProgress: number = 0;
  @State private opening: boolean = true;
  private dragStart: number = 0;
  private motion: NotebookMotionController = new NotebookMotionController();

  aboutToAppear(): void {
    this.spreadPosition = clampSpreadIndex(this.pageIndex, this.item);
    this.motion.run(0, 1, 450, (value: number) => {
      this.openingProgress = value;
    }, () => { this.opening = false; });
  }

  aboutToDisappear(): void { this.motion.stop(); }

  private handleClosing(): void {
    if (!this.isClosing) { return; }
    this.opening = true;
    this.motion.run(this.openingProgress, 0, 400, (value: number) => {
      this.openingProgress = value;
    }, () => { if (this.onClosed) { this.onClosed(); } });
  }

  private getFitScale(): number {
    const width = this.isLandscape ? 458 : 430;
    const height = this.isLandscape ? 258 : 268;
    return Math.max(0.2, Math.min(1, (this.availableWidth - 24) / width,
      (this.availableHeight - 24) / height));
  }
  private getPageWidth(): number { return (this.isLandscape ? 164 : 150) * this.getFitScale(); }
  private getPageHeight(): number { return (this.isLandscape ? 226 : 236) * this.getFitScale(); }

  private coverRelative(left: boolean): number {
    const indices = getVisibleSpreadIndices(this.spreadPosition, getNotebookSpreadCount(this.item));
    return indices.length === 0 ? 0 :
      indices[left ? 0 : indices.length - 1] - this.spreadPosition;
  }

  private settleTo(index: number): void {
    if (this.opening || this.isClosing || getNotebookSpreadCount(this.item) === 0) { return; }
    const target = clampSpreadIndex(index, this.item);
    this.motion.run(this.spreadPosition, target, 320, (value: number) => {
      this.spreadPosition = value;
    }, () => { if (this.onPageChange) { this.onPageChange(target); } });
  }

  private updateDrag(offset: number): void {
    if (this.opening || this.isClosing || getNotebookSpreadCount(this.item) === 0) { return; }
    const proposed = this.dragStart - offset / (this.getPageWidth() * 1.3);
    const bounded = Math.max(this.pageIndex - 1, Math.min(this.pageIndex + 1, proposed));
    const last = getNotebookSpreadCount(this.item) - 1;
    this.spreadPosition = bounded < 0 ? bounded * 0.12 :
      (bounded > last ? last + (bounded - last) * 0.12 : bounded);
  }

  private releaseDrag(velocity: number): void {
    const delta = this.spreadPosition - this.pageIndex;
    const direction = Math.abs(velocity) > 500 ? (velocity < 0 ? 1 : -1) :
      (Math.abs(delta) > 0.18 ? (delta > 0 ? 1 : -1) : 0);
    this.settleTo(this.pageIndex + direction);
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      NotebookCoverSpread({
        item: this.item, openingProgress: this.openingProgress,
        pageWidth: this.getPageWidth(), pageHeight: this.getPageHeight(),
        leftRelative: this.coverRelative(true), rightRelative: this.coverRelative(false),
        boundToPages: getNotebookSpreadCount(this.item) > 0
      })
        .zIndex(0)
      ForEach(getVisibleSpreadIndices(this.spreadPosition, getNotebookSpreadCount(this.item)), (index: number) => {
        NotebookSpreadSheet({
          item: this.item, spreadIndex: index, relative: index - this.spreadPosition,
          openingProgress: this.openingProgress,
          pageWidth: this.getPageWidth(), pageHeight: this.getPageHeight(),
          onSelect: (target: number) => { this.settleTo(target); },
          onTurn: (direction: number) => { this.settleTo(this.pageIndex + direction); }
        })
          .opacity(index === this.pageIndex ? 1 : this.openingProgress)
          .zIndex(100 - Math.abs(index - this.spreadPosition) * 10)
      }, (index: number) => `${index}`)

      if (this.opening) {
        NotebookOpeningCover({
          item: this.item, progress: this.openingProgress,
          pageWidth: this.getPageWidth(), pageHeight: this.getPageHeight(),
          relative: this.coverRelative(true), boundToPages: getNotebookSpreadCount(this.item) > 0
        })
      }
    }
    .width(this.getPageWidth() * 2 + 130 * this.getFitScale())
    .height(this.getPageHeight() + 32 * this.getFitScale())
    .translate({ x: -this.getPageWidth() / 2 * (1 - this.openingProgress) })
    .gesture(
      PanGesture({ direction: PanDirection.Horizontal, distance: 8 })
        .onActionStart(() => {
          if (!this.opening && !this.isClosing) {
            this.motion.stop();
            this.dragStart = this.spreadPosition;
          }
        })
        .onActionUpdate((event: GestureEvent) => { this.updateDrag(event.offsetX); })
        .onActionEnd((event: GestureEvent) => { this.releaseDrag(event.velocityX); })
        .onActionCancel(() => { this.settleTo(this.pageIndex); })
    )
  }
}
