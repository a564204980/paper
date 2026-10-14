import matrix4 from '@ohos.matrix4';
import window from '@ohos.window';
import common from '@ohos.app.ability.common';
import { INITIAL_NOTEBOOKS, NotebookItemData, NEW_NOTEBOOK_PRESETS } from '../model/NotebookModel';
import { NotebookCard } from '../components/NotebookCard';
import { AddNotebookCard } from '../components/AddNotebookCard';
import { LandscapeIcon } from '../components/LandscapeIcon';
import { OpenedNotebookView } from '../components/OpenedNotebookView';
import { importNotebookPhotos } from '../utils/NotebookPhotoImport';
import { appendNotebookPhotos } from '../utils/NotebookPageUtils';
import { loadNotebooks, saveNotebooks } from '../utils/NotebookStorage';

/**
 * Index.ets
 * Paper 画廊主页
 * 纯正 FiftyThree Paper 原版极简沉浸画廊
 */
@Entry
@Component
struct Index {
  @State notebooks: NotebookItemData[] = INITIAL_NOTEBOOKS;
  @State focusedId: string = 'nb_crimson'; // 默认聚焦图 1 对应的复古砖红手账 '111'
  @State focusedIndex: number = 3; // 当前居中聚焦索引 (111 所在位置)
  @State openedId: string = ''; // 点击居中的书本后打开
  @State isLandscape: boolean = false; // 是否横屏显示

  private scroller: Scroller = new Scroller();
  private importingPhotos: boolean = false;

  private getOpenedNotebook(): NotebookItemData {
    const found = this.notebooks.find((item: NotebookItemData) => item.id === this.openedId);
    if (found) {
      return found;
    }
    return this.notebooks[this.focusedIndex] || this.notebooks[0];
  }

  async aboutToAppear(): Promise<void> {
    try {
      const context = this.getUIContext().getHostContext();
      if (!context) { return; }
      this.notebooks = loadNotebooks(context as common.UIAbilityContext);
      const win = await window.getLastWindow(context);
      const rect = win.getWindowProperties().windowRect;
      this.isLandscape = rect.width > rect.height;
      win.on('windowSizeChange', (size: window.Size) => {
        this.isLandscape = size.width > size.height;
      });
      setTimeout(() => {
        this.scroller.scrollToIndex(3, false, ScrollAlign.CENTER);
      }, 150);
    } catch (err) {
      console.error('Failed to get window properties: ' + JSON.stringify(err));
    }
  }

  async aboutToDisappear(): Promise<void> {
    try {
      const context = this.getUIContext().getHostContext();
      if (!context) { return; }
      const win = await window.getLastWindow(context);
      win.off('windowSizeChange');
    } catch (err) {
      console.error('Failed to unregister window listener: ' + JSON.stringify(err));
    }
  }

  // 切换横屏与竖屏
  private async handleToggleOrientation(): Promise<void> {
    try {
      const context = this.getUIContext().getHostContext();
      if (!context) { return; }
      const win = await window.getLastWindow(context);
      const target = this.isLandscape ? window.Orientation.PORTRAIT : window.Orientation.LANDSCAPE;
      await win.setPreferredOrientation(target);
      this.isLandscape = !this.isLandscape;
    } catch (err) {
      console.error('Failed to set orientation: ' + JSON.stringify(err));
    }
  }

  // 计算书本向心斜切透视率（两侧书本顶部向中间后仰收敛，中间书本垂直）
  private getSkewX(index: number): number {
    if (index < this.focusedIndex) {
      return -0.038;
    } else if (index > this.focusedIndex) {
      return 0.038;
    }
    return 0;
  }

  // 新建纯色笔记本
  private handleCreateNotebook(): void {
    const picked = NEW_NOTEBOOK_PRESETS[this.notebooks.length % NEW_NOTEBOOK_PRESETS.length];
    const newBook: NotebookItemData = {
      id: 'nb_' + Date.now(),
      title: '手账 ' + (this.notebooks.length + 1),
      coverBgColor: picked.bg,
      spineColor: picked.spine,
      paperCount: 0
    };
    this.notebooks.push(newBook);
    const context = this.getUIContext().getHostContext();
    if (context) {
      try {
        saveNotebooks(context as common.UIAbilityContext, this.notebooks);
      } catch (error) {
        console.error('Failed to save notebook: ' + JSON.stringify(error));
        this.showError('手账保存失败，请重试');
      }
    }
    this.focusedId = newBook.id;
    const targetIndex = this.notebooks.length - 1;
    this.focusedIndex = targetIndex;
    setTimeout(() => {
      this.scroller.scrollToIndex(targetIndex, true, ScrollAlign.CENTER);
    }, 150);
  }

  private async handleAddPhotos(): Promise<void> {
    if (this.importingPhotos || this.openedId === '') { return; }
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    if (!context) { return; }
    const notebookId = this.openedId;
    this.importingPhotos = true;
    try {
      const photos = await importNotebookPhotos(context);
      if (photos.length === 0) { return; }
      const updated = this.notebooks.map((item: NotebookItemData) =>
        item.id === notebookId ? appendNotebookPhotos(item, photos) : item);
      saveNotebooks(context, updated);
      this.notebooks = updated;
    } catch (error) {
      console.error('Failed to import photos: ' + JSON.stringify(error));
      this.showError('图片导入失败，请重试');
    } finally {
      this.importingPhotos = false;
    }
  }

  private showError(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message: message });
    } catch (error) {
      console.error('Failed to show message: ' + JSON.stringify(error));
    }
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      // -------------------------------------------------------------
      // 1. 拟物桌面背景层：经典 Paper 莫兰迪灰紫漫射桌面
      // -------------------------------------------------------------
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 180,
          colors: [
            ['#68667D', 0.0],
            ['#5F5D74', 0.5],
            ['#535167', 1.0]
          ]
        })

      // -------------------------------------------------------------
      // 2. 页面弹性垂直流（确保画廊在屏幕中轴线上舒展居中）
      // -------------------------------------------------------------
      Column() {
        // 顶部雅致微栏 (避让灵动岛与状态栏)
        Row() {
          Text('Paper')
            .fontSize(20)
            .fontWeight(FontWeight.Normal)
            .fontColor('rgba(255, 255, 255, 0.90)')
            .letterSpacing(2.0)

          Blank()

          // 右上角：极简横屏切换图标
          LandscapeIcon({
            isLandscape: this.isLandscape,
            onToggle: () => {
              this.handleToggleOrientation();
            }
          })
        }
        .width('100%')
        .padding({
          left: 28,
          right: 28,
          top: this.isLandscape ? 16 : 56,
          bottom: this.isLandscape ? 4 : 10
        })
        .zIndex(10)

        // -------------------------------------------------------------
        // 3. 核心：整齐平铺的横向连续书架画廊 (Horizontal Shelf Gallery)
        // 原版像素级：纯粹、无杂字、修长挺拔、纸质质感
        // -------------------------------------------------------------
        Column() {
          List({ scroller: this.scroller, space: this.isLandscape ? 14 : 18 }) {
            // 笔记本卡片流
            ForEach(this.notebooks, (item: NotebookItemData, index: number) => {
              ListItem() {
                Stack({ alignContent: Alignment.Bottom }) {
                  Stack({ alignContent: Alignment.Bottom }) {
                    NotebookCard({
                      item: item,
                      isFocused: this.focusedId === item.id,
                      isOpen: this.openedId === item.id,
                      onCardClick: () => {
                        if (this.focusedId !== item.id) {
                          this.focusedId = item.id;
                          this.focusedIndex = index;
                          this.scroller.scrollToIndex(index, true, ScrollAlign.CENTER);
                        } else {
                          this.getUIContext().animateTo({ duration: 450, curve: Curve.FastOutSlowIn }, () => {
                            this.openedId = this.openedId === item.id ? '' : item.id;
                          });
                        }
                      }
                    })
                  }
                  .rotate({
                    x: 1,
                    y: 0,
                    z: 0,
                    angle: this.focusedIndex === index ? 0 : -24,
                    centerX: index === this.focusedIndex - 1 ? '117%' :
                      (index === this.focusedIndex + 1 ? '-17%' :
                        (index < this.focusedIndex ? '251%' : (index > this.focusedIndex ? '-151%' : '50%'))),
                    centerY: '100%',
                    perspective: 32
                  })
                  .animation({ duration: 280, curve: Curve.FastOutSlowIn })
                }
                .scale({
                  x: (this.focusedIndex === index ? 1.0 : 0.92) * (this.isLandscape ? 0.72 : 1.0),
                  y: (this.focusedIndex === index ? 1.0 : 0.94) * (this.isLandscape ? 0.72 : 1.0),
                  centerX: '50%',
                  centerY: '100%'
                })
                .translate({ y: -18 })
                .animation({ duration: 280, curve: Curve.FastOutSlowIn })
              }
              .width(this.isLandscape ? 104 : 144)
            }, (item: NotebookItemData) => item.id)

            // 列表末尾：新建手账占位卡片
            ListItem() {
              Stack({ alignContent: Alignment.Bottom }) {
                Stack({ alignContent: Alignment.Bottom }) {
                  AddNotebookCard({
                    isFocused: this.focusedId === 'add',
                    onAddClick: () => {
                      this.handleCreateNotebook();
                    }
                  })
                }
                .rotate({
                  x: 1,
                  y: 0,
                  z: 0,
                  angle: this.focusedId === 'add' ? 0 : -24,
                  centerX: this.focusedId === 'add' ? '50%' :
                    (this.focusedIndex === this.notebooks.length - 1 ? '-17%' : '-151%'),
                  centerY: '100%',
                  perspective: 32
                })
                .animation({ duration: 280, curve: Curve.FastOutSlowIn })
              }
              .scale({
                x: (this.focusedId === 'add' ? 1.0 : 0.92) * (this.isLandscape ? 0.72 : 1.0),
                y: (this.focusedId === 'add' ? 1.0 : 0.94) * (this.isLandscape ? 0.72 : 1.0),
                centerX: '50%',
                centerY: '100%'
              })
              .translate({ y: -18 })
              .animation({ duration: 280, curve: Curve.FastOutSlowIn })
            }
            .width(this.isLandscape ? 104 : 144)
          }
          .listDirection(Axis.Horizontal)
          .edgeEffect(EdgeEffect.Spring)
          .scrollBar(BarState.Off)
          .alignListItem(ListItemAlign.Center)
          .scrollSnapAlign(ScrollSnapAlign.CENTER)
          .friction(1.8)
          .flingSpeedLimit(1200)
          .onScrollIndex((start: number, end: number, center: number) => {
            this.focusedIndex = center;
            if (center >= 0 && center < this.notebooks.length) {
              this.focusedId = this.notebooks[center].id;
            } else if (center === this.notebooks.length) {
              this.focusedId = 'add';
            }
          })
          .width('100%')
          .height(this.isLandscape ? 195 : 310)
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .margin({ bottom: this.isLandscape ? 20 : 0 })

        // 底部极简留白占位
        Row()
          .width('100%')
          .height(this.isLandscape ? 20 : 40)
      }
      .width('100%')
      .height('100%')

      // -------------------------------------------------------------
      // 3. 翻开状态下的 3D 手账跨页视图层 (Opened Notebook Spread Overlay)
      // -------------------------------------------------------------
      if (this.openedId !== '') {
        Column() {
          OpenedNotebookView({
            item: this.getOpenedNotebook(),
            isLandscape: this.isLandscape,
            onAddPage: () => {
              this.handleAddPhotos();
            },
            onClose: () => {
              this.getUIContext().animateTo({ duration: 400, curve: Curve.FastOutSlowIn }, () => {
                this.openedId = '';
              });
            },
            onToggleOrientation: () => {
              this.handleToggleOrientation();
            }
          })
        }
        .width('100%')
        .height('100%')
        .transition(TransitionEffect.OPACITY.combine(TransitionEffect.scale({ x: 0.90, y: 0.90 })))
        .zIndex(100)
      }
    }
    .width('100%')
    .height('100%')
  }
}
