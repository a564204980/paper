/** 动效时钟独立于组件：每帧同步两页的角度、位移和页叠，离开页面时统一停止。 */
export class NotebookMotionController {
  private timer: number = -1;

  stop(): void {
    if (this.timer !== -1) {
      clearInterval(this.timer);
      this.timer = -1;
    }
  }

  run(from: number, to: number, duration: number,
    onFrame: (value: number) => void, onFinish: () => void): void {
    this.stop();
    const started = Date.now();
    this.timer = setInterval(() => {
      const progress = Math.min(1, (Date.now() - started) / duration);
      const eased = 1 - Math.pow(1 - progress, 3);
      onFrame(from + (to - from) * eased);
      if (progress >= 1) {
        this.stop();
        onFinish();
      }
    }, 16);
  }
}
