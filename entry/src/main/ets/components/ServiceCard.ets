import { router } from '@kit.ArkUI';
import { Goods } from '../model/Goods';

@Component
export struct ServiceCard {
  @Prop goods!: Goods;

  build() {
    Column() {
      Stack() {
        Text('推荐').fontSize(12).fontColor(Color.White).backgroundColor('#FF5000')
          .padding({ left:6, right:6, top:2, bottom:2 }).borderRadius({ topLeft:8, bottomRight:8 }).position({ x:0, y:0 });
        Text('图').fontColor(Color.White);
      }.width('100%').height(120).backgroundColor('#CCC').borderRadius(8);
      Text(this.goods.title).fontSize(14).fontWeight(500).maxLines(1).margin({ top:8 });
      Text(`¥${this.goods.price}`).fontSize(16).fontColor('#FF5000').margin({ top:4 });
    }.width(160).onClick(() => router.pushUrl({ url: 'pages/DetailPage', params: { goodsId: this.goods.id } }));
  }
}