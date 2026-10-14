import { NotebookItemData } from '../model/NotebookModel';

export function getNotebookPageCount(item: NotebookItemData): number {
  return item.pages ? item.pages.length : 0;
}

export function getNotebookSpreadCount(item: NotebookItemData): number {
  return getNotebookPageCount(item);
}

export function appendNotebookPhotos(item: NotebookItemData, photos: string[]): NotebookItemData {
  const pages = [...(item.pages || []), ...photos];
  return {
    id: item.id, title: item.title, coverBgColor: item.coverBgColor,
    spineColor: item.spineColor, coverImage: item.coverImage,
    paperCount: pages.length, pages: pages
  };
}

export function clampSpreadIndex(index: number, item: NotebookItemData): number {
  return Math.max(0, Math.min(getNotebookSpreadCount(item) - 1, index));
}

// 同时保留当前跨页及其两侧页叠，让每组跨页在拖动中连续折叠。
export function getVisibleSpreadIndices(position: number, count: number): number[] {
  const indices: number[] = [];
  for (let index = Math.max(0, Math.floor(position) - 4);
    index <= Math.min(count - 1, Math.ceil(position) + 4); index++) {
    indices.push(index);
  }
  return indices;
}
