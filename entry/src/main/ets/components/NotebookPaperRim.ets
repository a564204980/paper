/** 外侧纸芯切面与亮边，随纸面一起投影，不占用额外布局空间。 */
@Component
export struct NotebookPaperRim {
  @Prop @Watch('draw') pageWidth: number = 164;
  @Prop @Watch('draw') pageHeight: number = 226;
  @Prop @Watch('draw') isLeft: boolean = false;
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(new RenderingContextSettings(true));
  private ready: boolean = false;

  private edge(inset: number): void {
    const ctx = this.context;
    const radius = 16;
    const outer = this.isLeft ? inset : this.pageWidth - inset;
    const inner = outer + (this.isLeft ? radius : -radius);
    ctx.beginPath();
    ctx.moveTo(inner, inset);
    ctx.quadraticCurveTo(outer, inset, outer, radius);
    ctx.lineTo(outer, this.pageHeight - radius);
    ctx.quadraticCurveTo(outer, this.pageHeight - inset, inner, this.pageHeight - inset);
    ctx.stroke();
  }

  private draw(): void {
    if (!this.ready) { return; }
    const ctx = this.context;
    ctx.reset();
    ctx.lineCap = 'round';
    ctx.strokeStyle = '#E4E1D8';
    ctx.lineWidth = 1.6;
    this.edge(1);
    ctx.strokeStyle = '#FFFFFF';
    ctx.lineWidth = 0.7;
    this.edge(0.55);
  }

  build() {
    Canvas(this.context)
      .width(this.pageWidth).height(this.pageHeight)
      .onReady(() => { this.ready = true; this.draw(); })
      .hitTestBehavior(HitTestMode.None)
  }
}
