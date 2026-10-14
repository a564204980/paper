export type PaperMatrix = [number, number, number, number, number, number, number, number,
  number, number, number, number, number, number, number, number];

const SPREAD_FAN_SPACING: number = 0.18;

// 翻动时适度拉远相机，保留纸页立起时的轻微增高，避免外角过度突出。
// 24° / 156° 的静止纸面保留原有相机距离，中途平滑过渡。
export function getFoldCameraDistanceFactor(angle: number): number {
  const progress = Math.min(1, Math.max(0, (Math.abs(angle) - 24) / 132));
  return 1 + 0.4 * Math.sin(Math.PI * progress);
}

// 以中缝为铰链投影纸页，摄像机对准纸张中央。
// 显式投影使页顶、页底同时形成 V 形；尺寸必须使用矩阵所需的 px。
export function getPaperMatrix(width: number, height: number, angle: number, left: boolean): PaperMatrix {
  const radians = angle * Math.PI / 180;
  const cosine = Math.cos(radians);
  const perspective = Math.sin(radians) / (width * 10);
  // ArkUI 的 transform 以组件中心为原点，两页铰链分别在 +width/2 和 -width/2。
  const hinge = left ? width / 2 : -width / 2;
  return [cosine + hinge * perspective, 0, 0, perspective,
    0, 1, 0, 0, 0, 0, 1, 0,
    hinge * (1 - cosine - hinge * perspective), 0,
    0, 1 - perspective * hinge];
}

export function getSpreadFoldAngle(relative: number, left: boolean, opening: number): number {
  if (left) {
    const fold = Math.min(1, Math.max(0, relative, 1 - opening));
    // 两组折线错开时，下一组左页提前露出，覆盖上一组右页退去后的间隙。
    const overlap = opening >= 1 ? Math.asin(SPREAD_FAN_SPACING) * 180 / Math.PI *
      Math.sin(Math.PI * fold) : 0;
    return 24 + 132 * fold - overlap;
  }
  return -24 - 132 * Math.min(1, Math.max(0, -relative));
}

// 硬纸页保持平面，正反面绕同一书脊旋转，输出相对于书脊中心的投影坐标。
export function getTurningPaperPoint(width: number, height: number, x: number, y: number,
  angle: number, left: boolean): [number, number] {
  const radians = angle * Math.PI / 180;
  const hinge = left ? width : 0;
  const distance = x - hinge;
  const projectedX = distance * Math.cos(radians);
  const depth = -distance * Math.sin(radians);
  const perspective = 1 - depth / (width * 10);
  return [projectedX / perspective, (y - height / 2) / perspective];
}

// 每组跨页保留自己的折线，随相对位置连续移入左右页叠。
export function getSpreadFanOffset(relative: number, pageWidth: number, opening: number = 1): number {
  return relative * pageWidth * SPREAD_FAN_SPACING * opening;
}

// 展开时保留页叠高低，合上时封面与内页一起收拢到同一尺寸。
export function getSpreadStackScale(relative: number, opening: number): number {
  return 1 - Math.min(4, Math.abs(relative * opening)) * 0.035;
}
