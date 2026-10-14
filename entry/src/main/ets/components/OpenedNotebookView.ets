import { NotebookItemData } from '../model/NotebookModel';
import { OpenBookSpread } from './OpenBookSpread';
import { LandscapeIcon } from './LandscapeIcon';
import { getNotebookPageCount, getNotebookSpreadCount } from '../utils/NotebookPageUtils';

/**
 * OpenedNotebookView.ets
 * 拟物手账翻开视图组件 (Opened Notebook View)
 * 严格按照图 1 像素级 1:1 复刻：
 * 1. 纯净莫兰迪灰紫沉浸背景（完全隔离书架背底杂物）
 * 2. 顶部居中显示手账标题（如 '111'）与当前页数（如 '6 页'）
 * 3. 中间展示 3D V 形双页大对折手账与右侧扇形展开纸页
 * 4. 底部居中排布 4 个白色正圆形拟物操作快捷按钮（更多、导出/分享、删除、添加新页），绝对不遮挡书本
 */
@Component
export struct OpenedNotebookView {
  @Prop item: NotebookItemData;
  @Prop isLandscape: boolean = false;
  onClose?: () => void;
  onPageClick?: () => void;
  onMore?: () => void;
  onShare?: () => void;
  onDelete?: () => void;
  onAddPage?: () => void;
  onToggleOrientation?: () => void;

  @State private pressedBtn: string = '';
  @State private pageIndex: number = 0;
  @State private bookAreaWidth: number = 500;
  @State private bookAreaHeight: number = 300;
  @State private closing: boolean = false;

  // 纯矢量绘制白色拟物圆形按钮
  @Builder
  ActionButton(type: string, onClickAction?: () => void) {
    Stack({ alignContent: Alignment.Center }) {
      if (type === 'more') {
        this.MoreIcon();
      } else if (type === 'share') {
        this.ShareTrayIcon();
      } else if (type === 'delete') {
        this.TrashIcon();
      } else if (type === 'add') {
        this.PlusIcon();
      }
    }
    .width(48)
    .height(48)
    .borderRadius(24)
    .backgroundColor('#FFFFFF')
    .scale({
      x: this.pressedBtn === type ? 0.92 : 1.0,
      y: this.pressedBtn === type ? 0.92 : 1.0
    })
    .animation({ duration: 120, curve: Curve.FastOutSlowIn })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.pressedBtn = type;
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.pressedBtn = '';
      }
    })
    .onClick(() => {
      if (onClickAction) {
        onClickAction();
      }
    })
  }

  // 1. 更多图标 (...)
  @Builder
  MoreIcon() {
    Row({ space: 4.5 }) {
      Circle().width(4.5).height(4.5).fill('#34343E')
      Circle().width(4.5).height(4.5).fill('#34343E')
      Circle().width(4.5).height(4.5).fill('#34343E')
    }
    .alignItems(VerticalAlign.Center)
  }

  // 2. 导出/分享托盘图标 (Tray + Up Arrow)
  @Builder
  ShareTrayIcon() {
    Stack({ alignContent: Alignment.Center }) {
      // 底部托盘凹槽
      Row()
        .width(18)
        .height(9)
        .borderWidth({ left: 2, right: 2, bottom: 2 })
        .borderColor('#34343E')
        .borderRadius({ bottomLeft: 3, bottomRight: 3 })
        .margin({ top: 8 })

      // 向上箭头
      Stack({ alignContent: Alignment.Top }) {
        // 竖杆
        Row()
          .width(2)
          .height(11)
          .borderRadius(1)
          .backgroundColor('#34343E')

        // 箭头尖羽 (V 形)
        Row() {
          Row()
            .width(6)
            .height(2)
            .borderRadius(1)
            .backgroundColor('#34343E')
            .rotate({ angle: 45, centerX: '100%', centerY: '50%' })
            .translate({ x: 0.5 })

          Row()
            .width(6)
            .height(2)
            .borderRadius(1)
            .backgroundColor('#34343E')
            .rotate({ angle: -45, centerX: '0%', centerY: '50%' })
            .translate({ x: -0.5 })
        }
      }
      .margin({ bottom: 5 })
    }
    .width(24)
    .height(24)
  }

  // 3. 垃圾桶图标 (Trash Bin)
  @Builder
  TrashIcon() {
    Column({ space: 1.5 }) {
      // 桶盖把手
      Row()
        .width(6)
        .height(1.8)
        .borderRadius(1)
        .backgroundColor('#34343E')

      // 桶盖横条
      Row()
        .width(18)
        .height(2)
        .borderRadius(1)
        .backgroundColor('#34343E')

      // 桶身外框与内条
      Stack({ alignContent: Alignment.Center }) {
        Row()
          .width(14)
          .height(12)
          .borderWidth({ left: 1.8, right: 1.8, bottom: 1.8 })
          .borderColor('#34343E')
          .borderRadius({ bottomLeft: 2.5, bottomRight: 2.5 })

        Row({ space: 3.5 }) {
          Row().width(1.5).height(6.5).borderRadius(0.75).backgroundColor('#34343E')
          Row().width(1.5).height(6.5).borderRadius(0.75).backgroundColor('#34343E')
        }
      }
    }
    .width(24)
    .height(24)
    .justifyContent(FlexAlign.Center)
  }

  // 4. 添加新页图标 (+)
  @Builder
  PlusIcon() {
    Stack({ alignContent: Alignment.Center }) {
      Row()
        .width(17)
        .height(2.4)
        .borderRadius(1.2)
        .backgroundColor('#34343E')

      Column()
        .width(2.4)
        .height(17)
        .borderRadius(1.2)
        .backgroundColor('#34343E')
    }
    .width(24)
    .height(24)
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      // -------------------------------------------------------------
      // 1. 纯净莫兰迪灰紫沉浸背景（完全遮挡画廊，点击空白处合上手账）
      // -------------------------------------------------------------
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 180,
          colors: [
            ['#656379', 0.0],
            ['#5B5970', 0.5],
            ['#504E63', 1.0]
          ]
        })
        .onClick(() => {
          this.closing = true;
        })

      // -------------------------------------------------------------
      // 2. 核心内容纵向流：顶部信息 -> 中间 3D 手账 -> 底部快捷操作栏
      // -------------------------------------------------------------
      Column() {
        // [顶部信息区]
        Stack({ alignContent: Alignment.Center }) {
          Column() {
            Text(this.item.title || '111')
              .fontSize(this.isLandscape ? 22 : 26)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .letterSpacing(1.2)

            Text(getNotebookPageCount(this.item) === 0 ? '0 页' :
              `${getNotebookPageCount(this.item)} 页 · ${this.pageIndex + 1} / ${getNotebookSpreadCount(this.item)}`)
              .fontSize(this.isLandscape ? 13 : 14)
              .fontWeight(FontWeight.Normal)
              .fontColor('rgba(255, 255, 255, 0.72)')
              .margin({ top: 3 })
          }

          // 右上角：横竖屏切换微图标
          Row() {
            Blank()
            LandscapeIcon({
              isLandscape: this.isLandscape,
              onToggle: () => {
                if (this.onToggleOrientation) {
                  this.onToggleOrientation();
                }
              }
            })
          }
          .width('100%')
          .padding({ right: 28 })
        }
        .width('100%')
        .margin({
          top: this.isLandscape ? 12 : 56,
          bottom: this.isLandscape ? 6 : 24
        })

        // [中间展开本区]
        Column() {
          OpenBookSpread({
            item: this.item,
            pageIndex: this.pageIndex,
            onPageChange: (index: number) => {
              this.pageIndex = index;
            },
            isLandscape: this.isLandscape,
            availableWidth: this.bookAreaWidth,
            availableHeight: this.bookAreaHeight,
            isClosing: this.closing,
            onClosed: () => {
              if (this.onClose) { this.onClose(); }
            }
          })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .onAreaChange((oldArea: Area, area: Area) => {
          this.bookAreaWidth = Number(area.width);
          this.bookAreaHeight = Number(area.height);
        })

        // [底部快捷操作按钮栏 - 保证处于书本下方，留出呼吸空间]
        Row({ space: 24 }) {
          // 按钮 1: ...
          this.ActionButton('more', () => {
            if (this.onMore) {
              this.onMore();
            }
          })

          // 按钮 2: 导出/分享
          this.ActionButton('share', () => {
            if (this.onShare) {
              this.onShare();
            }
          })

          // 按钮 3: 垃圾桶删除
          this.ActionButton('delete', () => {
            if (this.onDelete) {
              this.onDelete();
            }
          })

          // 按钮 4: + 添加新页
          this.ActionButton('add', () => {
            if (this.onAddPage) {
              this.onAddPage();
            }
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({
          top: this.isLandscape ? 10 : 20,
          bottom: this.isLandscape ? 18 : 56
        })
      }
      .width('100%')
      .height('100%')
      .hitTestBehavior(HitTestMode.Transparent)
    }
    .width('100%')
    .height('100%')
  }
}
