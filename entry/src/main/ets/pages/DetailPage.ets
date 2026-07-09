import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { StorageUtil } from '../utils/StorageUtil';
import { Goods } from '../model/Goods';
import { GoodsStatus } from '../model/Goods';
import { Message } from '../model/Message';
import { MsgType } from '../model/Message';
import { Report } from '../model/Report';
import { ReportStatus } from '../model/Report';
import { OrderStatus } from '../model/Order';
import { Order } from '../model/Order';

// ✅ 定义路由参数接口
interface DetailPageParams {
  goodsId?: string;
}

@Entry
@Component
struct DetailPage {
  @State goods: Goods | null = null;
  @State isCollected: boolean = false;
  @State reportReason: string = '';
  @State showReportDialog: boolean = false;

  aboutToAppear(): void {
    // ✅ 使用接口类型断言
    const params = router.getParams() as DetailPageParams;
    if (params?.goodsId) {
      StorageUtil.getGoodsById(params.goodsId).then((goods: Goods | undefined) => {
        if (goods) {
          this.goods = goods;
          this.checkCollectStatus();
        }
      });
    }
  }

  private checkCollectStatus(): void {
    const user = StorageUtil.getCurrentUserSync();
    if (user && this.goods) {
      const collects: string[] = StorageUtil.getCollectsSync(user.id);
      this.isCollected = collects.includes(this.goods.id);
    }
  }

  private toggleCollect(): void {
    const user = StorageUtil.getCurrentUserSync();
    if (!user) {
      promptAction.showToast({ message: '请先登录' });
      router.pushUrl({ url: 'pages/LoginPage' });
      return;
    }
    if (!this.goods) return;

    StorageUtil.toggleCollect(user.id, this.goods.id).then((isCollected: boolean) => {
      this.isCollected = isCollected;
      promptAction.showToast({ message: isCollected ? '收藏成功' : '取消收藏' });

      const collectsCount: number = StorageUtil.getCollectsSync(user.id).length;
      const updatedGoods: Goods = this.goods!.clone();
      updatedGoods.collectCount = collectsCount;
      StorageUtil.saveGoods(updatedGoods).then(() => {
        this.goods = updatedGoods;
      });
    });
  }

  private sendMessage(): void {
    const user = StorageUtil.getCurrentUserSync();
    if (!user) {
      promptAction.showToast({ message: '请先登录' });
      router.pushUrl({ url: 'pages/LoginPage' });
      return;
    }
    if (!this.goods || user.id === this.goods.sellerId) {
      promptAction.showToast({ message: '不能给自己发消息' });
      return;
    }

    // ✅ 核心改动：不再直接发消息，而是跳转到 ChatPage
    // 把对方的信息和商品ID作为参数传过去
    router.pushUrl({
      url: 'pages/ChatPage', // 新建的页面
      params: {
        targetUserId: this.goods.sellerId,
        targetUserName: this.goods.sellerName,
        goodsId: this.goods.id,
        goodsTitle: this.goods.title
      }
    });
  }
  private submitReport(): void {
    if (!this.reportReason.trim()) {
      promptAction.showToast({ message: '请填写举报原因' });
      return;
    }
    const user = StorageUtil.getCurrentUserSync();
    if (!user || !this.goods) return;

    const report = new Report();
    report.id = `report_${Date.now()}_${Math.random().toString(36).substring(2, 11)}`;
    report.goodsId = this.goods.id;
    report.goodsTitle = this.goods.title;
    report.reporterId = user.id;
    report.reporterName = user.username;
    report.reason = this.reportReason;
    report.status = ReportStatus.PENDING;

    StorageUtil.addReport(report).then(() => {
      this.showReportDialog = false;
      this.reportReason = '';
      promptAction.showToast({ message: '举报已提交，管理员会尽快处理' });
    });
  }

  @Builder
  ActionButton(icon: Resource, text: string, onClick: () => void) {
    Column({ space: 4 }) {
      Image(icon).width(24).height(24);
      Text(text).fontSize(12).fontColor('#666');
    }.onClick(onClick);
  }

  // ✅ 商品不存在时的UI
  @Builder
  EmptyView() {
    Column() {
      Text('商品不存在或已下架').fontSize(18).fontColor('#999');
      Button('返回').margin({ top: 20 }).onClick(() => router.back());
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#F5F5F5');
  }

  // ✅ 商品详情UI
  @Builder
  GoodsDetailView() {
    Column() {
      // 头部导航
      Row() {
        Image($r('app.media.ic_back')).width(24).height(24).onClick(() => router.back());
        Text('商品详情').fontSize(20).fontWeight(700).layoutWeight(1).textAlign(TextAlign.Center);
        Blank();
      }.width('100%').padding(15);

      Scroll() {
        Column({ space: 15 }) {
          // 商品图片轮播
          Swiper() {
            if (this.goods!.images.length > 0) {
              ForEach(this.goods!.images, (imgUrl: string) => {
                Image(imgUrl)
                  .width('100%')
                  .height(300)
                  .objectFit(ImageFit.Cover);
              });
            } else {
              Image('https://picsum.photos/300/300')
                .width('100%')
                .height(300)
                .objectFit(ImageFit.Cover);
            }
          }
          .autoPlay(true)
          .interval(3000)
          .indicator(true)
          .width('100%')
          .height(300);

          // 商品核心信息
          Column({ space: 10 }) {
            Text(this.goods!.title).fontSize(22).fontWeight(700);
            Row() {
              Text(`¥${this.goods!.price}`).fontSize(24).fontColor('#FF5000').fontWeight(700);
              Blank();
              Text(this.goods!.location).fontSize(14).fontColor('#999')
                .backgroundColor('#F0F0F0').padding(6).borderRadius(4);
            }.width('100%');

            Text(this.goods!.description).fontSize(16).lineHeight(24);

            Row() {
              Text(`分类：${this.goods!.category}`).fontSize(14).fontColor('#666');
              Blank();
              Text(`发布时间：${new Date(this.goods!.publishTime).toLocaleDateString()}`)
                .fontSize(14).fontColor('#999');
            }.width('100%').margin({ top: 10 });

            Text(`卖家：${this.goods!.sellerName}`).fontSize(14).fontColor('#666');
            Text(`收藏数：${this.goods!.collectCount}`).fontSize(14).fontColor('#666');
          }
          .padding(15)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .margin(15);

          // 操作按钮
          Row({ space: 20 }) {
            this.ActionButton(
              this.isCollected ? $r('app.media.startIcon') : $r('app.media.startIcon'),
              this.isCollected ? '已收藏' : '收藏',
              () => this.toggleCollect()
            );
            this.ActionButton($r('app.media.ic_chat'), '私信', () => this.sendMessage());
            this.ActionButton($r('app.media.ic_report'), '举报', () => this.showReportDialog = true);
          }
          .justifyContent(FlexAlign.SpaceAround)
          .width('100%')
          .padding(15)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .margin({ left:15, right:15, bottom:15 });
        }.width('100%');
      }.layoutWeight(1);

      // 底部购买按钮
      // 底部购买按钮（真实购买逻辑）
      if (this.goods!.status === GoodsStatus.ON_SALE) {
        Button('立即购买')
          .width('90%')
          .height(48)
          .backgroundColor('#FF5000')
          .fontColor(Color.White)
          .borderRadius(24)
          .margin({ bottom: 20 })
          .onClick(async () => {
            // 1. 校验登录
            const user = StorageUtil.getCurrentUserSync();
            if (!user) {
              promptAction.showToast({ message: '请先登录', duration: 2000 });
              router.pushUrl({ url: 'pages/LoginPage' });
              return;
            }

            // 2. 校验不能买自己的商品
            if (user.id === this.goods!.sellerId) {
              promptAction.showToast({ message: '不能购买自己的商品', duration: 2000 });
              return;
            }

            // 3. 生成订单（使用你已有的 Order 模型）
            const order = new Order();
            order.id = `o_${Date.now()}`;
            order.goodsId = this.goods!.id;
            order.goodsTitle = this.goods!.title;
            order.buyerId = user.id;
            order.buyerName = user.username;
            order.sellerId = this.goods!.sellerId;
            order.price = this.goods!.price;
            order.status = OrderStatus.PENDING; // 待发货
            order.createTime = Date.now();

            try {
              // 4. 保存订单
              await StorageUtil.saveOrder(order);
              // 5. 更新商品状态为“已售出”
              this.goods!.status = GoodsStatus.SOLD_OUT;
              await StorageUtil.saveGoods(this.goods!);

              // 6. 反馈并退出
              promptAction.showToast({ message: '购买成功！', duration: 2000 });
              setTimeout(() => {
                router.back(); // 返回首页
              }, 500);
            } catch (err) {
              promptAction.showToast({ message: '购买失败，请重试', duration: 2000 });
            }
          });
      } else if (this.goods!.status === GoodsStatus.PENDING) {
        Text('审核中')
          .width('90%')
          .height(48)
          .textAlign(TextAlign.Center)
          .backgroundColor('#EEE')
          .fontColor('#999')
          .borderRadius(24)
          .margin({ bottom: 20 });
      } else {
        Text('已下架')
          .width('90%')
          .height(48)
          .textAlign(TextAlign.Center)
          .backgroundColor('#EEE')
          .fontColor('#999')
          .borderRadius(24)
          .margin({ bottom: 20 });
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5');
  }

  // ✅ 举报对话框
  @Builder
  ReportDialog() {
    Column() {
      Column({ space: 15 }) {
        Text('举报商品').fontSize(18).fontWeight(700);
        TextArea({ placeholder: '请填写举报原因（如虚假信息、违禁品等）' })
          .height(120)
          .onChange((v: string) => this.reportReason = v);
        Row({ space: 20 }) {
          Button('取消')
            .backgroundColor('#EEE')
            .fontColor('#333')
            .onClick(() => {
              this.showReportDialog = false;
              this.reportReason = '';
            });
          Button('提交')
            .backgroundColor('#FF5000')
            .fontColor(Color.White)
            .onClick(() => this.submitReport());
        }.width('100%').justifyContent(FlexAlign.End);
      }
      .padding(20)
      .backgroundColor(Color.White)
      .borderRadius(12)
      .width('90%');
    }
    .width('100%')
    .height('100%')
    .backgroundColor('rgba(0,0,0,0.5)')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.showReportDialog = false;
      this.reportReason = '';
    });
  }

  build() {
    // ✅ 只有一个根节点 Stack
    Stack() {
      if (!this.goods) {
        this.EmptyView();
      } else {
        this.GoodsDetailView();
      }

      // 举报对话框（条件渲染）
      if (this.showReportDialog) {
        this.ReportDialog();
      }
    }
    .width('100%')
    .height('100%');
  }
}

export { DetailPage };