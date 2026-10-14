import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, 'PaperApp', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'PaperApp', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, 'PaperApp', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'PaperApp', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'PaperApp', 'Succeeded in loading content.');

      windowStage.getMainWindow().then((win) => {
        if (win) {
          // 沉浸式全屏
          win.setWindowLayoutFullScreen(true);
          win.setWindowBackgroundColor('#716C82');
        }
      });
    });
  }

  onWindowStageDestroy(): void {
    hilog.info(DOMAIN, 'PaperApp', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    hilog.info(DOMAIN, 'PaperApp', 'Ability onForeground');
  }

  onBackground(): void {
    hilog.info(DOMAIN, 'PaperApp', 'Ability onBackground');
  }
}
