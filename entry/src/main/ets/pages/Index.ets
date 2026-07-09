import { router } from '@kit.ArkUI';
import { HomePage } from './HomePage';
import { CategoryPage } from './CategoryPage';
import { PublishPage } from './PublishPage';
import { MessagePage } from './MessagePage';
import { MinePage } from './MinePage';
import { PermissionUtil } from '../utils/PermissionUtil';
import { promptAction } from '@kit.ArkUI';
import { Position } from '@kit.ArkUI'; // ✅ 改成 Position
@Entry
@Component
struct Index {
  @State currentTab: number = 0;
  private tabsController: TabsController = new TabsController();

  build() {
    Column() {
      // ✅ 内容区占满剩余空间，把 TabBar 顶到底部
      Tabs({ controller: this.tabsController, index: this.currentTab }) {
        TabContent() { HomePage() }.tabBar('首页');
        TabContent() { CategoryPage() }.tabBar('分类');
        TabContent() { PublishPage() }.tabBar('发布');
        TabContent() { MessagePage() }.tabBar('消息');
        TabContent() { MinePage() }.tabBar('我的');
      }
      .width('100%')
      .layoutWeight(1)
      .onChange((idx: number): void => {
        this.currentTab = idx;
        if (idx === 2 && !PermissionUtil.canPublish()) {
          promptAction.showToast({ message: '请先登录' });
          this.tabsController.changeIndex(0);
          router.pushUrl({ url: 'pages/LoginPage' });
        }
      });
    }
    .width('100%')
    .height('100%');
  }
}