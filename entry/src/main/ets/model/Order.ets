export enum OrderStatus {
  PENDING = 'pending',   // 待付款
  PAID = 'paid',         // 已付款
  SHIPPED = 'shipped',   // 已发货
  COMPLETED = 'completed',// 已完成
  CANCELLED = 'cancelled' // 已取消
}

export class Order {
  id: string = '';
  goodsId: string = '';
  goodsTitle: string = '';
  buyerId: string = '';
  buyerName: string = '';
  sellerId: string = '';
  sellerName: string = '';
  price: number = 0;
  createTime: number = new Date().getTime();
  status: OrderStatus = OrderStatus.PENDING;

}