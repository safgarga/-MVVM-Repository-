import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { StorageUtil } from '../utils/StorageUtil';
import { Goods } from '../model/Goods';

@Component
export struct GoodsCard {
  @Prop goods!: Goods;
  @State isCollected: boolean = false;

  aboutToAppear(): void {
    const currentUser = StorageUtil.getCurrentUserSync();
    if (currentUser) {
      const userCollects: string[] = StorageUtil.getCollectsSync(currentUser.id);
      this.isCollected = userCollects.includes(this.goods.id);
    }
  }

  private toggleCollect(): void {
    const currentUser = StorageUtil.getCurrentUserSync();
    if (!currentUser) {
      promptAction.showToast({ message: '请先登录' });
      router.pushUrl({ url: 'pages/LoginPage' });
      return;
    }

    StorageUtil.toggleCollect(currentUser.id, this.goods.id).then((isCollected: boolean) => {
      this.isCollected = isCollected;

      const collectsCount: number = StorageUtil.getCollectsSync(currentUser.id).length;

      // ✅ 使用 clone() 方法（推荐）
      const updatedGoods: Goods = this.goods.clone();
      updatedGoods.collectCount = collectsCount;

      StorageUtil.saveGoods(updatedGoods).then(() => {
        promptAction.showToast({
          message: isCollected ? '收藏成功' : '取消收藏',
          duration: 1000
        });
      });
    });
  }

  // 在GoodsCard.ets中找到build()方法，修改商品卡片样式
  build() {
  Row() {
    // 商品图片
    Image(this.goods.images.length > 0 ? this.goods.images[0] : $r('app.media.img_default_goods'))
      .width(90)  // 稍微放大
      .height(90)
      .backgroundColor('#F8F8F8')
      .borderRadius(10)  // 圆角更大
      .objectFit(ImageFit.Cover)
      .margin({ right: 12 });

    Column() {
      Text(this.goods.title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .maxLines(2)  // 允许两行
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%');

      Text(`¥${this.goods.price}`)
        .fontSize(18)
        .fontColor('#FF5000')
        .fontWeight(FontWeight.Bold)
        .margin({ top: 8 });

      Row() {
        Text(this.goods.location)
          .fontSize(12)
          .fontColor('#999999')
          .backgroundColor('#F0F0F0')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .borderRadius(4);

        Blank();

        Text(`收藏 ${this.goods.collectCount}`)
          .fontSize(12)
          .fontColor('#999999');
      }
      .margin({ top: 8 })
      .width('100%');
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start);
  }
  .width('100%')
  .padding(12)
  .backgroundColor(Color.White)
  .borderRadius(12)
  .shadow({
    radius: 6,
    color: 'rgba(0, 0, 0, 0.04)',
    offsetX: 0,
    offsetY: 2
  })
  .onClick(() => {
    router.pushUrl({
      url: 'pages/DetailPage',
      params: { goodsId: this.goods.id }
    });
  })
}
}