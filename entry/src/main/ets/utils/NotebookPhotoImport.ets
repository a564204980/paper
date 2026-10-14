import common from '@ohos.app.ability.common';
import photoAccessHelper from '@ohos.file.photoAccessHelper';
import fs from '@ohos.file.fs';
import fileUri from '@ohos.file.fileuri';

/** 通过系统选择器导入照片，并保存到应用目录以免临时授权失效。 */
export async function importNotebookPhotos(context: common.UIAbilityContext): Promise<string[]> {
  const paths: string[] = [];
  const sources: string[] = [];
  const timestamp = Date.now();
  try {
    const picker = new photoAccessHelper.PhotoViewPicker();
    const result = await picker.select({
      MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE,
      maxSelectNumber: 50
    });
    if (result.photoUris.length === 0) { return []; }
    const directory = context.filesDir + '/notebook_photos';
    if (!fs.accessSync(directory)) { fs.mkdirSync(directory); }
    for (let index = 0; index < result.photoUris.length; index++) {
      const destination = `${directory}/${timestamp}_${index}.img`;
      const source = await fs.open(result.photoUris[index], fs.OpenMode.READ_ONLY);
      try {
        paths.push(destination);
        await fs.copyFile(source.fd, destination);
        sources.push(fileUri.getUriFromPath(destination));
      } finally {
        await fs.close(source);
      }
    }
    return sources;
  } catch (error) {
    for (const path of paths) {
      try {
        if (fs.accessSync(path)) { fs.unlinkSync(path); }
      } catch (cleanupError) {
        console.error('Failed to remove incomplete photo: ' + JSON.stringify(cleanupError));
      }
    }
    throw new Error('Photo import failed: ' + JSON.stringify(error));
  }
}
