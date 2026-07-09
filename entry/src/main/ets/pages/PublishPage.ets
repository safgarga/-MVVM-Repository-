import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { StorageUtil } from '../utils/StorageUtil';
import { PermissionUtil } from '../utils/PermissionUtil';
import { Goods } from '../model/Goods';
import { GoodsStatus } from '../model/Goods';
import { GoodsCategory } from '../model/Goods';
import { Campus } from '../model/User';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileIo } from '@kit.CoreFileKit';

interface CategoryItem {
  name: string;
  value: GoodsCategory;
}

@Entry
@Component
export struct PublishPage {
  @State title: string = '';
  @State price: string = '';
  @State description: string = '';
  @State category: GoodsCategory = GoodsCategory.OTHER;
  @State campus: Campus = Campus.NORTH;
  @State imageUri: string = ''; // ✅ 改成真实图片路径

  private readonly categories: CategoryItem[] = [
    { name: '数码', value: GoodsCategory.DIGITAL },
    { name: '教材', value: GoodsCategory.BOOK },
    { name: '运动', value: GoodsCategory.SPORT },
    { name: '日用', value: GoodsCategory.DAILY },
    { name: '其他', value: GoodsCategory.OTHER }
  ];

  aboutToAppear(): void {
    if (!PermissionUtil.canPublish()) {
      promptAction.showToast({ message: '请先登录' });
      router.back();
    }
  }

  /** ✅ 选择图片（模拟器可用） */
  private async pickImage(): Promise<void> {
    try {
      const photoPicker = new photoAccessHelper.PhotoViewPicker();
      const result = await photoPicker.select({
        MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE,
        maxSelectNumber: 1
      });

      if (result.photoUris.length > 0) {
        this.imageUri = result.photoUris[0];
        promptAction.showToast({ message: '图片已选择' });
      }
    } catch (e) {
      promptAction.showToast({ message: '选择图片失败' });
    }
  }

  private publish(): void {
    if (!this.title || !this.price) {
      promptAction.showToast({ message: '请填写商品标题和价格' });
      return;
    }

    const user = StorageUtil.getCurrentUserSync();
    if (!user) {
      promptAction.showToast({ message: '用户状态异常，请重新登录' });
      router.pushUrl({ url: 'pages/LoginPage' });
      return;
    }

    const goods = new Goods();
    goods.id = `goods_${Date.now()}_${Math.random().toString(36).substring(2, 11)}`;
    goods.title = this.title;
    goods.price = Number(this.price) || 0;
    goods.description = this.description;
    goods.images = this.imageUri ? [this.imageUri] : ['img_default_goods']; // ✅ 使用真实路径
    goods.category = this.category;
    goods.location = this.campus;
    goods.sellerId = user.id;
    goods.sellerName = user.username;
    goods.status = GoodsStatus.PENDING;
    goods.publishTime = Date.now();
    goods.collectCount = 0;

    StorageUtil.saveGoods(goods).then(() => {
      promptAction.showDialog({
        title: '发布成功',
        message: '商品已进入审核队列，请耐心等待管理员审核。',
        buttons: [{ text: '确定', color: '#007DFF' }]
      });
      setTimeout(() => router.back(), 1500);
    });
  }

  @Builder
  CategorySelector(): void {
    Column() {
      Text('商品分类').fontSize(16).fontWeight(500).margin({ bottom: 10, left: 15 });
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.categories, (cat: CategoryItem) => {
          Text(cat.name)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .backgroundColor(this.category === cat.value ? '#FF5000' : '#F0F0F0')
            .fontColor(this.category === cat.value ? Color.White : '#333333')
            .borderRadius(16)
            .margin({ right: 8, bottom: 8 })
            .onClick(() => this.category = cat.value);
        }, (cat: CategoryItem) => cat.name);
      }.padding({ left: 15, right: 15 });
    }
  }

  @Builder
  CampusSelector(): void {
    Row() {
      Text('所在校区：').fontSize(16).fontWeight(500).margin({ left: 15 });
      Radio({ value: 'north', group: 'campus' })
        .onChange((v: boolean) => v && (this.campus = Campus.NORTH));
      Text('北校区').margin({ right: 16 });
      Radio({ value: 'south', group: 'campus' })
        .onChange((v: boolean) => v && (this.campus = Campus.SOUTH));
      Text('南校区');
    }.margin({ top: 15, bottom: 15, left: 15, right: 15 });
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Image($r('app.media.ic_back')).width(24).height(24).onClick(() => router.back());
        Text('发布商品').fontSize(20).fontWeight(700).layoutWeight(1).textAlign(TextAlign.Center);
        Blank().width(24);
      }.width('100%').padding(15);

      Scroll() {
        Column({ space: 15 }) {
          // ✅ 图片上传区域（可点击 + 尺寸合理）
          Column() {
            Text('商品图片').fontSize(16).fontWeight(500).alignSelf(ItemAlign.Start);

            Stack() {
              // 图片预览
              Image(this.imageUri ? this.imageUri : $r('app.media.img_default_goods'))
                .width(120)
                .height(120)
                .objectFit(ImageFit.Cover)
                .borderRadius(12)
                .backgroundColor('#F8F8F8');

              // 右上角提示
              if (!this.imageUri) {
                Text('点击上传')
                  .fontSize(12)
                  .fontColor('#999999')
                  .backgroundColor('rgba(255,255,255,0.8)')
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .borderRadius(4)
                  .position({ x: 10, y: 10 });
              }
            }
            .width(120)
            .height(120)
            .onClick(() => this.pickImage())
            .margin({ top: 10 });

            Text('支持 JPG/PNG，单张不超过 5MB')
              .fontSize(12)
              .fontColor('#999999')
              .margin({ top: 8 });
          }
          .width('100%')
          .padding({ left: 15, right: 15 });

          // 表单区域
          Column({ space: 15 }) {
            TextInput({ placeholder: '商品标题（如：九成新 iPad Pro）' })
              .width('100%')
              .onChange(v => this.title = v);
            TextInput({ placeholder: '价格（元）' })
              .type(InputType.Number)
              .width('100%')
              .onChange(v => this.price = v);
            TextArea({ placeholder: '商品描述（新旧程度、使用情况、交易方式等）' })
              .width('100%')
              .height(100)
              .onChange(v => this.description = v);
          }.padding({ left: 15, right: 15 });

          this.CategorySelector();
          this.CampusSelector();
        }.width('100%');
      }.layoutWeight(1);

      // 提交按钮
      Button('提交审核')
        .width('90%')
        .height(44)
        .backgroundColor('#FF5000')
        .fontColor(Color.White)
        .borderRadius(22)
        .margin({ bottom: 20 })
        .onClick(() => this.publish());
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5');
  }
}