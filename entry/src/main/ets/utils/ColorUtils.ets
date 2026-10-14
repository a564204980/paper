/**
 * ColorUtils.ets
 * 颜色动态计算纯函数工具
 * 用于根据装订布条本色 (spineColor) 同色系动态计算折压凹槽的加深色与凸棱提亮色
 */

/**
 * 将 HEX 颜色按指定比例同色系加深
 * @param hex 基础颜色 (如 '#FFFFFF' 或 '#9C2525')
 * @param ratio 加深比例 (0.0 ~ 1.0)
 */
export function darkenHex(hex: string, ratio: number): string {
  const clean = hex.replace('#', '');
  if (clean.length !== 6) {
    return hex;
  }
  const r = parseInt(clean.substring(0, 2), 16);
  const g = parseInt(clean.substring(2, 4), 16);
  const b = parseInt(clean.substring(4, 6), 16);

  const factor = Math.max(0, Math.min(1, 1 - ratio));
  const nr = Math.round(r * factor);
  const ng = Math.round(g * factor);
  const nb = Math.round(b * factor);

  return '#' + toHex2(nr) + toHex2(ng) + toHex2(nb);
}

/**
 * 将 HEX 颜色按指定比例同色系提亮
 * @param hex 基础颜色 (如 '#FFFFFF' 或 '#9C2525')
 * @param ratio 提亮比例 (0.0 ~ 1.0)
 */
export function lightenHex(hex: string, ratio: number): string {
  const clean = hex.replace('#', '');
  if (clean.length !== 6) {
    return hex;
  }
  const r = parseInt(clean.substring(0, 2), 16);
  const g = parseInt(clean.substring(2, 4), 16);
  const b = parseInt(clean.substring(4, 6), 16);

  const clamped = Math.max(0, Math.min(1, ratio));
  const nr = Math.round(r + (255 - r) * clamped);
  const ng = Math.round(g + (255 - g) * clamped);
  const nb = Math.round(b + (255 - b) * clamped);

  return '#' + toHex2(nr) + toHex2(ng) + toHex2(nb);
}

function toHex2(value: number): string {
  const clamped = Math.max(0, Math.min(255, value));
  const str = clamped.toString(16).toUpperCase();
  return str.length === 1 ? '0' + str : str;
}

/**
 * 生成同色系指定透明度的 #AARRGGBB 颜色字符串，避免 rgba(0,0,0,0) 插值出黑灰脏边
 */
export function alphaHex(hex: string, alpha: number): string {
  const clean = hex.replace('#', '');
  if (clean.length !== 6) {
    return hex;
  }
  const a = Math.round(Math.max(0, Math.min(1, alpha)) * 255);
  return '#' + toHex2(a) + clean.toUpperCase();
}

