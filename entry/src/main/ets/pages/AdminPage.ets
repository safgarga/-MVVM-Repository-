import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { StorageUtil } from '../utils/StorageUtil';
import { PermissionUtil } from '../utils/PermissionUtil';
import { Goods } from '../model/Goods';
import { GoodsStatus } from '../model/Goods';
import { Report, ReportStatus } from '../model/Report';
import { User } from '../model/User';
import { UserRole } from '../model/User';

@Entry
@Component
struct AdminPage {
  @State pendingGoods: Goods[] = [];
  @State reports: Report[] = [];
  @State users: User[] = [];
  @State currentTab: number = 0;

  @Builder
  TabBarItem(title: string, index: number) {
    Text(title)
      .fontSize(16)
      .fontWeight(this.currentTab === index ? 700 : 400)
      .fontColor(this.currentTab === index ? '#FF5000' : '#333')
      .padding({ left: 15, right: 15, top: 10, bottom: 10 });
  }

  aboutToAppear(): void {
    if (!PermissionUtil.isAdmin()) {
      // ✅ 修正：使用新 API
      this.getUIContext().getPromptAction().showToast({ message: '无管理员权限' });
      router.back(); // ✅ 修正：替代 router.back()
      return;
    }
    this.loadData();
  }

  private loadData(): void {
    // ✅ 待审商品：PENDING
    StorageUtil.getGoods(
      new Map([['status', GoodsStatus.PENDING]])
    ).then((goods: Goods[]) => {
      this.pendingGoods = goods;
    });

    // ✅ 举报列表
    StorageUtil.getReports().then((reports: Report[]) => {
      this.reports = reports;
    });

    // ✅ 用户列表
    StorageUtil.getUsers().then((users: User[]) => {
      this.users = users;
    });
  }

  private auditGoods(goods: Goods, approve: boolean): void {
    goods.status = approve ? GoodsStatus.ON_SALE : GoodsStatus.BANNED;

    StorageUtil.saveGoods(goods).then(() => {
      this.loadData();
      // ✅ 修正：使用新 API
      this.getUIContext().getPromptAction().showToast({ message: approve ? '审核通过' : '已下架' });
    });
  }

  private handleReport(report: Report, approve: boolean): void {
    report.status = approve ? ReportStatus.PROCESSED : ReportStatus.REJECTED;

    StorageUtil.getReports().then((reports: Report[]) => {
      const idx = reports.findIndex(r => r.id === report.id);
      if (idx >= 0) {
        reports[idx] = report;
        StorageUtil.saveReports(reports).then(() => {
          this.loadData();
          // ✅ 修正：使用新 API
          this.getUIContext().getPromptAction().showToast({ message: approve ? '举报已处理' : '举报已驳回' });
        });
      }
    });
  }

  @Builder
  GoodsAuditItem(goods: Goods) {
    Column({ space: 8 }) {
      Text(goods.title).fontSize(16).fontWeight(500).maxLines(1);
      Text(`价格：¥${goods.price} | 分类：${goods.category}`).fontSize(14).fontColor('#666');
      Text(`卖家：${goods.sellerName} | 校区：${goods.location}`).fontSize(14).fontColor('#666');
      Text(`发布时间：${new Date(goods.publishTime).toLocaleString()}`).fontSize(12).fontColor('#999');
      Row({ space: 15 }) {
        Button('通过')
          .backgroundColor('#07C160')
          .fontColor(Color.White)
          .onClick(() => this.auditGoods(goods, true));
        Button('下架')
          .backgroundColor('#FF5000')
          .fontColor(Color.White)
          .onClick(() => this.auditGoods(goods, false));
      }.margin({ top: 10 });
    }
    .padding(15)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .margin({ bottom: 10 });
  }

  @Builder
  ReportItem(report: Report) {
    Column({ space: 8 }) {
      Text(`举报商品：${report.goodsTitle}`).fontSize(16).fontWeight(500);
      Text(`举报人：${report.reporterName}`).fontSize(14).fontColor('#666');
      Text(`原因：${report.reason}`).fontSize(14).fontColor('#666').maxLines(2);
      Text(`状态：${report.status === ReportStatus.PENDING ? '待处理' : report.status === ReportStatus.PROCESSED ? '已处理' : '已驳回'}`)
        .fontSize(12)
        .fontColor(report.status === ReportStatus.PENDING ? '#FF5000' : '#07C160')
        .backgroundColor('#F0F0F0')
        .padding(4)
        .borderRadius(4);

      if (report.status === ReportStatus.PENDING) {
        Row({ space: 15 }) {
          Button('通过')
            .backgroundColor('#07C160')
            .fontColor(Color.White)
            .onClick(() => this.handleReport(report, true));
          Button('驳回')
            .backgroundColor('#FF5000')
            .fontColor(Color.White)
            .onClick(() => this.handleReport(report, false));
        }.margin({ top: 10 });
      }
    }
    .padding(15)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .margin({ bottom: 10 });
  }

  @Builder
  UserItem(user: User) {
    Row() {
      Column() {
        Text(user.username).fontSize(16).fontWeight(500);
        Text(`角色：${user.role === UserRole.ADMIN ? '管理员' : '普通用户'} | 校区：${user.campus}`)
          .fontSize(14)
          .fontColor('#666');
      }.layoutWeight(1);

      if (user.role !== UserRole.ADMIN) {
        Button('设为管理员')
          .backgroundColor('#007DFF')
          .fontColor(Color.White)
          .onClick(() => {
            user.role = UserRole.ADMIN;
            StorageUtil.saveUser(user).then(() => {
              this.loadData();
              // ✅ 修正：使用新 API
              this.getUIContext().getPromptAction().showToast({ message: '已设为管理员' });
            });
          });
      }
    }
    .padding(15)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .margin({ bottom: 10 });
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          // ✅ 修正：使用 router.pop()
          .onClick(() => router.back());
        Text('管理员后台').fontSize(20).fontWeight(700).layoutWeight(1).textAlign(TextAlign.Center);
        Blank();
      }.width('100%').padding(15);

      Tabs({ index: this.currentTab, barPosition: BarPosition.Start }) {
        // Tab1: 待审商品
        TabContent() {
          Scroll() {
            Column({ space: 15 }) {
              Text(`待审核商品（${this.pendingGoods.length}件）`)
                .fontSize(18)
                .fontWeight(700)
                .margin({ top: 15, left: 15 });

              if (this.pendingGoods.length === 0) {
                Text('暂无待审核商品').fontSize(16).fontColor('#999').margin(30);
              } else {
                ForEach(this.pendingGoods,
                  (goods: Goods) => this.GoodsAuditItem(goods),
                  (goods: Goods) => goods.id
                );
              }
            }.padding(15).width('100%');
          }.layoutWeight(1);
        }.tabBar(this.TabBarItem('待审商品', 0))

        // Tab2: 举报处理
        TabContent() {
          Scroll() {
            Column({ space: 15 }) {
              Text(`举报处理（${this.reports.filter(r => r.status === ReportStatus.PENDING).length}件待处理）`)
                .fontSize(18)
                .fontWeight(700)
                .margin({ top: 15, left: 15 });

              if (this.reports.length === 0) {
                Text('暂无举报记录').fontSize(16).fontColor('#999').margin(30);
              } else {
                ForEach(this.reports,
                  (report: Report) => this.ReportItem(report),
                  (report: Report) => report.id
                );
              }
            }.padding(15).width('100%');
          }.layoutWeight(1);
        }.tabBar(this.TabBarItem('举报处理', 1))

        // Tab3: 用户管理
        TabContent() {
          Scroll() {
            Column({ space: 15 }) {
              Text(`用户管理（${this.users.length}人）`)
                .fontSize(18)
                .fontWeight(700)
                .margin({ top: 15, left: 15 });

              ForEach(this.users,
                (user: User) => this.UserItem(user),
                (user: User) => user.id
              );
            }.padding(15).width('100%');
          }.layoutWeight(1);
        }.tabBar(this.TabBarItem('用户管理', 2))
      }
    }
  }
}

export { AdminPage };