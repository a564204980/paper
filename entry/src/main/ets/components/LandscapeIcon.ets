/**
 * LandscapeIcon.ets
 * 极简横屏 / 屏幕旋转矢量图标组件
 * 纯矢量绘制，契合 Paper 拟物极简审美
 */
@Component
export struct LandscapeIcon {
  @Prop isLandscape: boolean = false;
  onToggle?: () => void;

  @State private isPressed: boolean = false;

  build() {
    Stack({ alignContent: Alignment.Center }) {
      // 核心图标：横置圆角屏幕线框
      Row() {
        // 内部屏幕显示区（左侧画板内容区）
        Blank()

        // 右侧极简窄边 / 边栏指示微标
        Column()
          .width(2)
          .height(7)
          .borderRadius(1)
          .backgroundColor('rgba(255, 255, 255, 0.55)')
          .margin({ right: 2 })
      }
      .width(21)
      .height(14)
      .borderRadius(3)
      .borderWidth(1.5)
      .borderColor('rgba(255, 255, 255, 0.80)')
      .padding({ right: 1 })
      .alignItems(VerticalAlign.Center)
    }
    .width(36)
    .height(36)
    .borderRadius(18)
    .backgroundColor(this.isPressed ? 'rgba(255, 255, 255, 0.12)' : 'transparent')
    .opacity(this.isPressed ? 0.7 : 1.0)
    .animation({ duration: 150, curve: Curve.EaseOut })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.isPressed = true;
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.isPressed = false;
      }
    })
    .onClick(() => {
      if (this.onToggle) {
        this.onToggle();
      }
    })
  }
}
