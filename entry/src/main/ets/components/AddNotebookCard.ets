/**
 * AddNotebookCard.ets
 * 新建手账卡片组件 (等高同比例虚线框)
 */
@Component
export struct AddNotebookCard {
  @Prop isFocused: boolean = false;
  onAddClick?: () => void;

  private readonly cardWidth: number = 144;
  private readonly cardHeight: number = 234;

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column({ space: 12 }) {
        Stack({ alignContent: Alignment.Center }) {
          Circle()
            .width(40)
            .height(40)
            .fill('rgba(255, 255, 255, 0.12)')

          Text('+')
            .fontSize(24)
            .fontWeight(FontWeight.Normal)
            .fontColor('rgba(255, 255, 255, 0.85)')
        }

        Text('新建手账')
          .fontSize(12)
          .fontColor('rgba(255, 255, 255, 0.65)')
      }
    }
    .width(this.cardWidth)
    .height(this.cardHeight)
    .borderRadius({
      topLeft: 3,
      bottomLeft: 3,
      topRight: 16,
      bottomRight: 16
    })
    .border({
      width: 1.2,
      style: BorderStyle.Dashed,
      color: 'rgba(255, 255, 255, 0.28)'
    })
    .backgroundColor('rgba(255, 255, 255, 0.05)')
    .onClick(() => {
      if (this.onAddClick) {
        this.onAddClick();
      }
    })
  }
}
