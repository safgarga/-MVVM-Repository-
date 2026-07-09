import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { StorageUtil } from '../utils/StorageUtil';
import { PermissionUtil } from '../utils/PermissionUtil';
import { Goods } from '../model/Goods';
import { User, UserRole } from '../model/User';
import { GoodsStatus } from '../model/Goods';
import { Campus } from '../model/User';
import { Order } from '../model/Order';

@Entry
// ✅ 关键：必须是 export struct，不能是 @Entry
@Component
export struct MinePage {
  @State user: User | null = null;
  @State myGoods: Goods[] = [];
  @State collectedGoods: Goods[] = [];
  @State orderCount: number = 0;
  aboutToAppear(): void {
    this.user = StorageUtil.getCurrentUserSync();
    this.loadData();
  }

  private loadData(): void {
    if (!this.user) return;

    const myFilter = new Map<string, Object>();
    myFilter.set('sellerId', this.user.id);
    StorageUtil.getGoods(myFilter).then((goodsList: Goods[]) => {
      this.myGoods = goodsList;
    });

    const collects: string[] = StorageUtil.getCollectsSync(this.user.id);
    StorageUtil.getGoods().then((allGoods: Goods[]) => {
      this.collectedGoods = allGoods.filter(g => collects.includes(g.id));
    });
    StorageUtil.getOrders().then((allOrders: Order[]) => {
      // 只统计当前用户作为买家的订单
      this.orderCount = allOrders.filter(order => order.buyerId === this.user?.id).length;
    });
  }

  private logout(): void {
    StorageUtil.setCurrentUser(null);
    promptAction.showToast({
      message: '已退出登录',
      duration: 2000
    });
    router.replaceUrl({ url: 'pages/LoginPage' });
  }

  @Builder
  MenuItem(icon: Resource, title: string, onClick: () => void): void {
    Row() {
      Image(icon)
        .width(24)
        .height(24)
        .fillColor('#007DFF')
        .margin({ right: 15 });

      Text(title)
        .fontSize(16)
        .layoutWeight(1)
        .fontColor('#333333');

      Image($r('app.media.ic_arrow_right'))
        .width(16)
        .height(16)
        .fillColor('#CCCCCC');
    }
    .width('100%')
    .height(52)
    .padding({ left: 15, right: 15 })
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ bottom: 10 })
    .onClick(onClick);
  }

  build() {
    Column() {
      // ===== 用户信息卡片 =====
      Column() {
        Row() {
          // 头像
          Image($r('app.media.ic_default_avatar'))
            .width(64)
            .height(64)
            .borderRadius(32)
            .backgroundColor('#F0F0F0');

          Column() {
            Text(this.user?.username ?? '未登录')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.Black);

            Text(this.user ? `校区：${this.user.campus}` : '点击登录/注册')
              .fontSize(14)
              .fontColor('#666666')
              .margin({ top: 6 });
          }
          .margin({ left: 15 })
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start);

          if (this.user) {
            Button('退出', { type: ButtonType.Capsule })
              .backgroundColor('#F5F5F5')
              .fontColor('#333333')
              .onClick(() => this.logout());
          } else {
            Button('登录', { type: ButtonType.Capsule })
              .backgroundColor('#FF5000')
              .fontColor(Color.White)
              .onClick(() => {
                router.pushUrl({ url: 'pages/LoginPage' });
              });
          }
        }
        .width('100%')
        .padding(20);
      }
      .width('100%')
      .backgroundColor(Color.White)
      .borderRadius({ bottomLeft: 20, bottomRight: 20 })
      .margin({ bottom: 15 });

      // ===== 数据统计栏 =====
      if (this.user) {
        Row() {
          this.StatItem(this.myGoods.length.toString(), '我的发布');
          Divider().vertical(true).height(40).color('#EEEEEE');
          this.StatItem(this.collectedGoods.length.toString(), '我的收藏');
          Divider().vertical(true).height(40).color('#EEEEEE');
          this.StatItem(this.orderCount.toString(), '我的订单');
        }
        .width('100%')
        .padding(15)
        .backgroundColor(Color.White)
        .borderRadius(12)
        .margin({ left: 15, right: 15, bottom: 15 });
      }

      // ===== 菜单列表 =====
      Scroll() {
        Column({ space: 12 }) {
          this.MenuItem($r('app.media.ic_publish'), '我的发布', () => {
            if (!this.user) {
              router.pushUrl({ url: 'pages/LoginPage' });
              return;
            }
            router.pushUrl({
              url: 'pages/SearchResultPage',
              params: { type: 'my' }
            });
          });

          this.MenuItem($r('app.media.ic_collect'), '我的收藏', () => {
            if (!this.user) {
              router.pushUrl({ url: 'pages/LoginPage' });
              return;
            }
            router.pushUrl({
              url: 'pages/SearchResultPage',
              params: { type: 'collect' }
            });
          });

          this.MenuItem($r('app.media.ic_message'), '我的消息', () => {
            if (!this.user) {
              router.pushUrl({ url: 'pages/LoginPage' });
              return;
            }
            router.pushUrl({ url: 'pages/MessagePage' });
          });

          if (PermissionUtil.isAdmin()) {
            this.MenuItem($r('app.media.ic_admin'), '管理员后台', () => {
              router.pushUrl({ url: 'pages/AdminPage' });
            });
          }

          this.MenuItem($r('app.media.ic_settings'), '设置', () => {
            promptAction.showToast({
              message: '设置功能开发中',
              duration: 2000
            });
          });

          this.MenuItem($r('app.media.ic_feedback'), '帮助与反馈', () => {
            promptAction.showToast({
              message: '帮助功能开发中',
              duration: 2000
            });
          });
        }
        .padding({ left: 15, right: 15 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5');
  }

  @Builder
  StatItem(num: string, label: string) {
    Column() {
      Text(num)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333');
      Text(label)
        .fontSize(13)
        .fontColor('#999999')
        .margin({ top: 4 });
    }
    .layoutWeight(1)
    .onClick(() => {
      if (label === '我的发布') {
        router.pushUrl({
          url: 'pages/SearchResultPage',
          params: { type: 'my' }
        });
      } else if (label === '我的收藏') {
        router.pushUrl({
          url: 'pages/SearchResultPage',
          params: { type: 'collect' }
        });
      } else {
        promptAction.showToast({
          message: '订单功能开发中',
          duration: 2000
        });
      }
    });
  }
}