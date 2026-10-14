import { NotebookItemData } from '../model/NotebookModel';
import { alphaHex } from '../utils/ColorUtils';
import { BookSpine } from './BookSpine';
import { getNotebookPageCount } from '../utils/NotebookPageUtils';

/**
 * NotebookCard.ets
 * 拟物手账本卡片组件
 * 严格按照 FiftyThree Paper 原版像素级还原：
 * - 整书边缘严丝合缝平齐，无任何错位杂边
 * - 左侧 2vp 微圆角，右侧 14vp 经典圆润倒角
 * - 阴影与书本圆角完全贴合，消除直角残影
 */
@Component
export struct NotebookCard {
  @Prop item: NotebookItemData;
  @Prop isFocused: boolean = false;
  @Prop isOpen: boolean = false;
  onCardClick?: () => void;

  // 经典 Paper 手账比例
  private readonly cardWidth: number = 144;
  private readonly cardHeight: number = 228;

  build() {
    // 最外层透明安全缓冲容器：确保 3D 旋转时的硬件 Quad 几何硬边完全落在完全透明的空白区
    // 内部书本边缘完整享有 GPU 双线性插值抗锯齿，彻底消除倾斜边缘的阶梯狗牙
    Stack({ alignContent: Alignment.Center }) {
      // -------------------------------------------------------------
      // 0. 独立圆角阴影投射层 (不进入 renderGroup，避免阴影被离屏纹理截成直角；
      //    四周内缩 2vp 完全藏于书本内部，绝不外露或叠加硬化书本边缘抗锯齿)
      // -------------------------------------------------------------
      Column()
        .width(this.cardWidth - 4)
        .height(this.cardHeight - 4)
        .backgroundColor(this.isOpen ? '#E6E6E6' : this.item.coverBgColor)
        .borderRadius({
          topLeft: 2,
          bottomLeft: 2,
          topRight: 13,
          bottomRight: 13
        })
        .shadow({
          radius: this.isFocused ? 26 : 20,
          color: this.isFocused ? 'rgba(20, 16, 34, 0.42)' : 'rgba(22, 18, 36, 0.32)',
          offsetX: this.isFocused ? 6 : 4,
          offsetY: this.isFocused ? 10 : 8
        })

      // -------------------------------------------------------------
      // 书本本体离屏抗锯齿纹理层：四周保留纯净 4vp 全透明像素带并开启 renderGroup(true)，
      // 在 3D 透视旋转时完整触发 GPU 双线性插值抗锯齿
      // -------------------------------------------------------------
      Stack({ alignContent: Alignment.Center }) {
        Stack({ alignContent: Alignment.TopStart }) {
          // 1. 底层：翻开后展示的内页纸张基底 (仅翻开时显现，避免合上时边缘漏白)
          if (this.isOpen && getNotebookPageCount(this.item) > 0) {
            Stack({ alignContent: Alignment.Center }) {
              Column()
                .width('100%')
                .height('100%')
                .backgroundColor('#E6E6E6')
                .borderRadius({
                  topLeft: 2,
                  bottomLeft: 2,
                  topRight: 14,
                  bottomRight: 14
                })

              // 展开后的中缝折痕微暗影
              Row()
                .width(16)
                .height('100%')
                .position({ x: 0, y: 0 })
                .linearGradient({
                  angle: 90,
                  colors: [
                    ['rgba(0, 0, 0, 0.12)', 0.0],
                    ['rgba(0, 0, 0, 0.02)', 0.5],
                    ['rgba(0, 0, 0, 0.0)', 1.0]
                  ]
                })

              Text('空白纸页')
                .fontSize(11)
                .fontColor('rgba(60, 55, 65, 0.35)')
            }
            .width(this.cardWidth)
            .height(this.cardHeight)
          }

          // 2. 拟物封面层：一体化精装封面 (纯正 Paper 质感)
          Stack({ alignContent: Alignment.TopStart }) {
            // 封面与书脊横向拼接，书脊下方不垫封面色，彻底杜绝左缘漏色
            Row() {
              // 左侧原版物理装订书脊 (带同色系边缘羽化与浅浮雕折压凹槽)
              BookSpine({
                spineColor: this.item.spineColor,
                tapeWidth: 12
              })

              // 封面主体（右侧边缘采用 GPU 浮点 UV 同色羽化渐变，彻底消除 86° 近垂直斜线阶梯锯齿）
              Stack({ alignContent: Alignment.Center }) {
                if (this.item.coverImage) {
                  Image(this.item.coverImage)
                    .width('100%')
                    .height('100%')
                    .objectFit(ImageFit.Cover)
                }
              }
              .layoutWeight(1)
              .height('100%')
              .borderRadius({
                topRight: 14,
                bottomRight: 14
              })
              .linearGradient({
                angle: 90,
                colors: [
                  [this.item.coverBgColor, 0.0],
                  [this.item.coverBgColor, 0.98],
                  [alphaHex(this.item.coverBgColor, 0.55), 0.99],
                  [alphaHex(this.item.coverBgColor, 0.0), 1.0]
                ]
              })
            }
            .width('100%')
            .height('100%')
          }
          .width(this.cardWidth)
          .height(this.cardHeight)
          // 3D 翻开动效
          .rotate({
            x: 0,
            y: this.isOpen ? -180 : 0,
            z: 0,
            centerX: '0%',
            centerY: '50%'
          })
          .opacity(this.isOpen ? 0 : 1)
          .animation({
            duration: 450,
            curve: Curve.FastOutSlowIn
          })
        }
        .width(this.cardWidth)
        .height(this.cardHeight)
      }
      .width(this.cardWidth + 8)
      .height(this.cardHeight + 8)
      .renderGroup(true)
    }
    .width(this.cardWidth + 8)
    .height(this.cardHeight + 8)
    .onClick(() => {
      if (this.onCardClick) {
        this.onCardClick();
      }
    })
  }
}
