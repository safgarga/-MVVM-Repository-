import { UIAbility } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { StorageUtil } from '../utils/StorageUtil';

export default class EntryAbility extends UIAbility {
  onWindowStageCreate(windowStage: window.WindowStage): void {
    // ✅ 正确：使用 this.context
    const context = this.context;
    console.log('【数据库路径】', context.preferencesDir);

    // ✅ 初始化 StorageUtil
    StorageUtil.init(context);
    StorageUtil.initDefaultData();

    windowStage.loadContent('pages/LoginPage', (err: BusinessError) => {
      if (err.code) {
        console.error(`加载失败: ${err.message}`);
      }
    });
  }
}