export interface NotebookItemData {
  id: string;
  title?: string;       // 手账标题（例如图 1 中的 '111'）
  coverBgColor: string; // 封面纯色
  spineColor: string;   // 装订书脊包边色
  coverImage?: string | Resource; // 用户上传的封面或图片资源
  paperCount: number;   // 初始内页数为 0，显示页数以 pages 为准
  pages?: string[];     // 每张已上传照片对应一张完整展开的跨页纸张
}

// 严格对齐图 2（原版 Paper）高雅纯色手账色系
export const INITIAL_NOTEBOOKS: NotebookItemData[] = [
  {
    id: 'nb_black',
    title: '黑色手账',
    coverBgColor: '#282828', // 经典石墨黑
    spineColor: '#ECE7DD',
    paperCount: 0
  },
  {
    id: 'nb_ivory',
    title: '日常随笔',
    coverBgColor: '#FAF8F0', // 经典象牙暖白
    spineColor: '#FFFFFF',
    paperCount: 0
  },
  {
    id: 'nb_sage',
    title: '灵感画集',
    coverBgColor: '#BDC6CB', // 图 2 原版采样莫兰迪灰雾青
    spineColor: '#FFFFFF',   // 纯白雅致书脊
    paperCount: 0
  },
  {
    id: 'nb_crimson',
    title: '111',
    coverBgColor: '#C43A3A', // 复古砖红
    spineColor: '#9C2525',
    paperCount: 0
  },
  {
    id: 'nb_navy',
    title: '旅行日记',
    coverBgColor: '#24384A', // 深海沉靛蓝
    spineColor: '#ECE7DD',
    paperCount: 0
  },
  {
    id: 'nb_oatmeal',
    title: '素描集',
    coverBgColor: '#D5C9B8', // 燕麦暖咖
    spineColor: '#8C7765',
    paperCount: 0
  }
];

export interface ColorPreset {
  bg: string;
  spine: string;
}

export const NEW_NOTEBOOK_PRESETS: ColorPreset[] = [
  { bg: '#586A5A', spine: '#ECE7DD' },
  { bg: '#887766', spine: '#ECE7DD' },
  { bg: '#3D4D5E', spine: '#E2E8F0' },
  { bg: '#9A7D74', spine: '#F7FAFC' }
];
