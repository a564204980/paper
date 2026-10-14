import common from '@ohos.app.ability.common';
import fs from '@ohos.file.fs';
import { INITIAL_NOTEBOOKS, NotebookItemData } from '../model/NotebookModel';

/** 保存手账及本地照片路径，重启后仍可读取已导入内页。 */
export function loadNotebooks(context: common.UIAbilityContext): NotebookItemData[] {
  const path = context.filesDir + '/notebooks.json';
  try {
    if (!fs.accessSync(path)) { return INITIAL_NOTEBOOKS; }
    const notebooks = JSON.parse(fs.readTextSync(path)) as NotebookItemData[];
    return notebooks.length > 0 ? notebooks : INITIAL_NOTEBOOKS;
  } catch (error) {
    console.error('Failed to load notebooks: ' + JSON.stringify(error));
    return INITIAL_NOTEBOOKS;
  }
}

export function saveNotebooks(context: common.UIAbilityContext, notebooks: NotebookItemData[]): void {
  const path = context.filesDir + '/notebooks.json';
  try {
    const file = fs.openSync(path + '.tmp', fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY | fs.OpenMode.TRUNC);
    try {
      fs.writeSync(file.fd, JSON.stringify(notebooks));
    } finally {
      fs.closeSync(file);
    }
    fs.renameSync(path + '.tmp', path);
  } catch (error) {
    throw new Error('Notebook save failed: ' + JSON.stringify(error));
  }
}
