import { Campus } from './User';


export enum GoodsStatus {
  PENDING = 'pending',
  ON_SALE = 'on_sale',
  SOLD = 'sold',
  BANNED = 'banned' // 违规下架
  ,
  SOLD_OUT = "SOLD_OUT"
}

export enum GoodsCategory {
  DIGITAL = '数码',
  BOOK = '教材',
  SPORT = '运动',
  DAILY = '日用',
  OTHER = '其他'
}

export class Goods {
  clone(): Goods {
    throw new Error('Method not implemented.');
  }
  id: string = '';
  title: string = '';
  price: number = 0;
  description: string = '';
  images: string[] = [];
  category: GoodsCategory = GoodsCategory.OTHER;
  location: Campus = Campus.NORTH;
  sellerId: string = '';
  sellerName: string = '';
  status: GoodsStatus = GoodsStatus.PENDING;
  publishTime: number = new Date().getTime();
  collectCount: number = 0;
}