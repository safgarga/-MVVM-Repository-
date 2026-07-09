import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { StorageUtil } from '../utils/StorageUtil';
import { Order } from '../model/Order';
import { OrderStatus } from '../model/Order';
import { User } from '../model/User';

@Entry
@Component
struct OrderPage {
  @State orders: Order[] = [];

  aboutToAppear(): void {
    this.loadOrders();
  }

  // 加载当前用户的订单（买/卖都显示）
  private loadOrders(): void {
    const currentUser: User | null = StorageUtil.getCurrentUserSync();
    if (!currentUser) {
      promptAction.showToast({ message: '请先登录', duration: 2000 });
      router.back();
      return;
    }
    StorageUtil.getOrders().then((allOrders: Order[]) => {
      this.orders = allOrders
        .filter((order: Order) => order.buyerId === currentUser.id || order.sellerId === currentUser.id)
        .sort((a: Order, b: Order) => b.createTime - a.createTime); // 最新的订单放最前
    });
  }

  // 订单状态转文字（和你已有的枚举对应）
  private getStatusText(status: OrderStatus): string {
    switch (status) {
      case OrderStatus.PENDING: return '待发货';
      case OrderStatus.SHIPPED: return '已发货';
      case OrderStatus.COMPLETED: return '已完成';
      default: return '未知状态';
    }
  }

  build() {
    Column() {
      // 顶部导航栏（和你现有风格统一）
      Row() {
        Image($r('app.media.ic_arrow_left'))
          .width(24)
          .height(24)
          .onClick(() => router.back());
        Text('我的订单')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center);
        Blank().width(24); // 占位，让标题居中
      }
      .width('100%')
      .padding(15)
      .backgroundColor(Color.White);

      // 订单列表
      if (this.orders.length === 0) {
        Column() {
          Text('暂无订单')
            .fontSize(16)
            .fontColor('#999');
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List({ space: 12 }) {
          ForEach(
            this.orders,
            (order: Order) => {
              ListItem() {
                Column({ space: 8 }) {
                  Text(order.goodsTitle)
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis });
                  Row() {
                    Text(`￥${order.price}`)
                      .fontSize(16)
                      .fontColor('#FF5000')
                      .fontWeight(FontWeight.Bold);
                    Blank();
                    Text(this.getStatusText(order.status))
                      .fontSize(14)
                      .fontColor(order.status === OrderStatus.PENDING ? '#FF5000' : '#666');
                  }
                  Text(`下单时间：${new Date(order.createTime).toLocaleString()}`)
                    .fontSize(12)
                    .fontColor('#999');
                }
                .padding(15)
                .backgroundColor(Color.White)
                .borderRadius(12)
              }
            },
            (item: Order) => item.id // ✅ 显式类型声明，解决之前的报错
          )
        }
        .width('100%')
        .layoutWeight(1)
        .padding(15)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5');
  }
}