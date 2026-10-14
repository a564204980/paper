import { NotebookItemData } from '../model/NotebookModel';
import { getTurningPaperPoint } from '../utils/NotebookFoldGeometry';

/** 正反面共用硬纸平面，底页和页叠由容器独立绘制。 */
@Component
export struct NotebookTurningLeaf {
  @Prop item: NotebookItemData;
  @Prop @Watch('draw') spreadPosition: number = 0;
  @Prop pageWidth: number = 164;
  @Prop pageHeight: number = 226;
  @Prop canvasWidth: number = 458;
  @Prop canvasHeight: number = 258;
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(new RenderingContextSettings(true));
  private ready: boolean = false;
  private uploaded?: ImageBitmap;
  private imageSource: string = '';

  private progress(): number { return this.spreadPosition - Math.floor(this.spreadPosition); }
  private isBack(): boolean { return this.progress() >= 0.5; }
  private pageNumber(): number {
    return Math.floor(this.spreadPosition) * 2 + (this.isBack() ? 3 : 2);
  }

  aboutToDisappear(): void { this.uploaded?.close(); }

  private point(x: number, y: number): number[] {
    const point = getTurningPaperPoint(this.pageWidth, this.pageHeight, x, y,
      -24 - 132 * this.progress() + (this.isBack() ? 180 : 0), this.isBack());
    return [point[0] + this.context.width / 2, point[1] + this.context.height / 2];
  }

  private surface(): void {
    const ctx = this.context;
    const w = this.pageWidth;
    const h = this.pageHeight;
    const lr = this.isBack() ? 16 : 1.5;
    const rr = this.isBack() ? 1.5 : 16;
    let point = this.point(lr, 0);
    ctx.beginPath();
    ctx.moveTo(point[0], point[1]);
    for (let index = 1; index <= 32; index++) {
      point = this.point(lr + (w - rr - lr) * index / 32, 0);
      ctx.lineTo(point[0], point[1]);
    }
    let corner = this.point(w, 0);
    point = this.point(w, rr);
    ctx.quadraticCurveTo(corner[0], corner[1], point[0], point[1]);
    point = this.point(w, h - rr);
    ctx.lineTo(point[0], point[1]);
    corner = this.point(w, h);
    point = this.point(w - rr, h);
    ctx.quadraticCurveTo(corner[0], corner[1], point[0], point[1]);
    for (let index = 1; index <= 32; index++) {
      point = this.point(w - rr - (w - rr - lr) * index / 32, h);
      ctx.lineTo(point[0], point[1]);
    }
    corner = this.point(0, h);
    point = this.point(0, h - lr);
    ctx.quadraticCurveTo(corner[0], corner[1], point[0], point[1]);
    point = this.point(0, lr);
    ctx.lineTo(point[0], point[1]);
    corner = this.point(0, 0);
    point = this.point(lr, 0);
    ctx.quadraticCurveTo(corner[0], corner[1], point[0], point[1]);
    ctx.closePath();
  }

  private triangle(points: number[][], a: number, b: number, c: number, d: number,
    e: number, f: number): void {
    if (!this.uploaded || this.uploaded.width <= 0 || Math.abs(a * d - b * c) < 0.04) { return; }
    const ctx = this.context;
    ctx.save();
    ctx.beginPath();
    ctx.moveTo(points[0][0], points[0][1]);
    ctx.lineTo(points[1][0], points[1][1]);
    ctx.lineTo(points[2][0], points[2][1]);
    ctx.closePath();
    ctx.clip();
    ctx.transform(a, b, c, d, e, f);
    const scale = Math.min(this.pageWidth / this.uploaded.width, this.pageHeight / this.uploaded.height);
    const w = this.uploaded.width * scale;
    const h = this.uploaded.height * scale;
    ctx.drawImage(this.uploaded, (this.pageWidth - w) / 2, (this.pageHeight - h) / 2, w, h);
    ctx.restore();
  }

  private drawImage(): void {
    const source = this.item.pages?.[this.pageNumber() - 1] || '';
    if (source !== this.imageSource) {
      this.uploaded?.close();
      this.uploaded = source !== '' ? new ImageBitmap(source) : undefined;
      this.imageSource = source;
    }
    if (!this.uploaded) { return; }
    const h = this.pageHeight;
    for (let index = 0; index < 16; index++) {
      const x0 = index * this.pageWidth / 16;
      const x1 = (index + 1) * this.pageWidth / 16;
      const tl = this.point(x0, 0);
      const tr = this.point(x1, 0);
      const br = this.point(x1, h);
      const bl = this.point(x0, h);
      const a = (tr[0] - tl[0]) / (x1 - x0);
      const b = (tr[1] - tl[1]) / (x1 - x0);
      this.triangle([tl, tr, br], a, b, (br[0] - tr[0]) / h, (br[1] - tr[1]) / h,
        tl[0] - a * x0, tl[1] - b * x0);
      const a2 = (br[0] - bl[0]) / (x1 - x0);
      const b2 = (br[1] - bl[1]) / (x1 - x0);
      this.triangle([tl, br, bl], a2, b2, (bl[0] - tl[0]) / h, (bl[1] - tl[1]) / h,
        tl[0] - a2 * x0, tl[1] - b2 * x0);
    }
  }

  private draw(): void {
    if (!this.ready) { return; }
    const ctx = this.context;
    ctx.reset();
    this.surface();
    ctx.fillStyle = '#E6E6E6';
    ctx.fill();
    ctx.save();
    ctx.clip();
    this.drawImage();
    const center = this.context.width / 2;
    const gradient = ctx.createLinearGradient(center, 0, center + (this.isBack() ? -24 : 24), 0);
    gradient.addColorStop(0, 'rgba(0,0,0,0.12)');
    gradient.addColorStop(1, 'rgba(0,0,0,0)');
    ctx.fillStyle = gradient;
    ctx.fillRect(0, 0, this.context.width, this.context.height);
    const point = this.point(this.pageWidth / 2, this.pageHeight - 9);
    const dx = this.point(this.pageWidth / 2 + 1, this.pageHeight - 9);
    const dy = this.point(this.pageWidth / 2, this.pageHeight - 8);
    const determinant = (dx[0] - point[0]) * (dy[1] - point[1]) -
      (dx[1] - point[1]) * (dy[0] - point[0]);
    if (Math.abs(determinant) > 0.04) {
      ctx.transform(dx[0] - point[0], dx[1] - point[1], dy[0] - point[0], dy[1] - point[1], point[0], point[1]);
      ctx.font = '9px sans-serif';
      ctx.textAlign = 'center';
      ctx.fillStyle = 'rgba(60,55,65,0.30)';
      ctx.fillText(`${this.pageNumber()}`, 0, 0);
    }
    ctx.restore();
  }

  build() {
    Canvas(this.context)
      .width(this.canvasWidth).height(this.canvasHeight)
      .onReady(() => { this.ready = true; this.draw(); })
      .zIndex(300).hitTestBehavior(HitTestMode.None)
  }
}
