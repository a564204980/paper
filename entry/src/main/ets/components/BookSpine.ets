import { alphaHex, darkenHex, lightenHex } from '../utils/ColorUtils';

/**
 * BookSpine.ets
 * 拟物装订书脊组件 (Moleskine Book Spine)
 * 严格按照原版图 2 像素采样 (x=11..33) 1:1 复刻：
 * - 整个书脊以不透明的 spineColor 为统一基底，绝不透出底层封面颜色
 * - 左侧折压凹槽动态跟随装订布条 spineColor 同色系加深
 * - 右侧为纯净平整的装订带主体
 */
@Component
export struct BookSpine {
  @Prop spineColor: string = '#FFFFFF';
  @Prop tapeWidth: number = 12;

  build() {
    // 整个书脊为一体成型的不透明装订带，由 GPU 线性渐变连续着色
    // 最左侧带同色系亚像素平滑羽化带，彻底消除倾斜时的左边缘硬锯齿与黑边
    Row()
      .width(1.2 + 1.8 + 1.4 + 0.9 + 1.1 + this.tapeWidth + 0.6)
      .height('100%')
      .borderRadius({
        topLeft: 2.5,
        bottomLeft: 2.5
      })
      .linearGradient({
        angle: 90,
        colors: [
          // 最左边缘同色系亚像素抗锯齿羽化带（绝不混入黑色或底层封面色）
          [alphaHex(this.spineColor, 0.0), 0.0],
          [alphaHex(this.spineColor, 0.55), 0.03],
          [this.spineColor, 0.07],
          [this.spineColor, 0.16],
          // 第一道主折压凹槽
          [darkenHex(this.spineColor, 0.12), 0.18],
          [darkenHex(this.spineColor, 0.12), 0.24],
          // 凹槽间微凸亮棱
          [lightenHex(this.spineColor, 0.05), 0.26],
          [lightenHex(this.spineColor, 0.05), 0.29],
          // 第二道次折压微槽
          [darkenHex(this.spineColor, 0.08), 0.31],
          [darkenHex(this.spineColor, 0.35 ? 0.08 : 0.08), 0.35],
          // 纯净装订带主体
          [this.spineColor, 0.38],
          [this.spineColor, 0.96],
          // 右缘交界极细微深线
          [darkenHex(this.spineColor, 0.06), 0.98],
          [darkenHex(this.spineColor, 0.06), 1.0]
        ]
      })
      .hitTestBehavior(HitTestMode.Transparent)
  }
}
