import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { StorageUtil } from '../utils/StorageUtil';
import { Goods } from '../model/Goods';
import { GoodsStatus } from '../model/Goods';
import { Campus } from '../model/User';
import { GoodsCategory } from '../model/Goods';
import { GoodsCard } from '../components/GoodsCard';

@Entry
@Component
struct HomePage {
  @State goodsList: Goods[] = [];
  @State currentCampus: Campus = Campus.NORTH;
  @State currentCategory: GoodsCategory = GoodsCategory.OTHER;
  @State keyword: string = '';
  @State isRefreshing: boolean = false;

  aboutToAppear(): void {
    this.loadGoods();
  }

  private loadGoods(): void {
    const filter = new Map<string, Object>();
    filter.set('status', GoodsStatus.ON_SALE);
    filter.set('campus', this.currentCampus);

    if (this.currentCategory !== GoodsCategory.OTHER) {
      filter.set('category', this.currentCategory);
    }
    if (this.keyword) {
      filter.set('keyword', this.keyword);
    }

    StorageUtil.getGoods(filter).then((goodsList: Goods[]) => {
      this.goodsList = goodsList;
    });
  }

  private onRefresh(): void {
    this.isRefreshing = true;
    setTimeout((): void => {
      this.loadGoods();
      this.isRefreshing = false;
    }, 1000);
  }

  @Builder
  CategoryBar(): void {
    // ✅ 修改 1：外层加一个 Column 并限制宽度为 90%，让分类卡片变窄
    Column() {
      Row({ space: 20 }) {
        this.CategoryItem('全部', GoodsCategory.OTHER);
        this.CategoryItem('数码', GoodsCategory.DIGITAL);
        this.CategoryItem('教材', GoodsCategory.BOOK);
        this.CategoryItem('运动', GoodsCategory.SPORT);
        this.CategoryItem('日用', GoodsCategory.DAILY);
      }
      .padding({ left: 15, bottom: 15 });
    }
    .width('90%') // 限制整体宽度
    .backgroundColor(Color.White)
    .borderRadius(12)
    .padding({ top: 15 });
  }

  @Builder
  CategoryItem(name: string, category: GoodsCategory): void {
    Column({ space: 6 }) {
      Image($r('app.media.ic_category_placeholder')) // 假设你有个分类图标
        .width(40)
        .height(40)
        .margin({ bottom: 4 });
      Text(name)
        .fontSize(12)
        .fontColor(this.currentCategory === category ? '#FF5000' : '#666');
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      this.currentCategory = category;
      this.loadGoods();
    });
  }

  build() {
    Column() {
      // 搜索栏
      Row() {
        Image($r('app.media.ic_search')).width(24).height(24).margin({ left: 15 });
        TextInput({ placeholder: '搜索商品' })
          .layoutWeight(1)
          .onChange((value: string): void => {
            this.keyword = value;
          });
        Button('搜索')
          .backgroundColor('#FF5000')
          .fontColor(Color.White)
          .margin({ right: 15 })
          .onClick((): void => this.loadGoods());
      }
      .height(48)
      .backgroundColor(Color.White)
      .borderRadius(24)
      .margin(15);

      // 校区筛选
      Row() {
        Text('校区：').margin({ left: 15 });
        Radio({ value: 'north', group: 'campus' })
          .onChange((value: boolean): void => {
            if (value) {
              this.currentCampus = Campus.NORTH;
              this.loadGoods();
            }
          });
        Text('北校区').margin({ right: 16 });
        Radio({ value: 'south', group: 'campus' })
          .onChange((value: boolean): void => {
            if (value) {
              this.currentCampus = Campus.SOUTH;
              this.loadGoods();
            }
          });
        Text('南校区');
      }
      .margin({ bottom: 8 });

      // 分类栏 (已变窄)
      this.CategoryBar();

      // ✅ 修改 2：删除了“推荐好物”这一整块代码，只保留“最新发布”

      // 最新发布标题
      Text('最新发布')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ left: 15, top: 10, bottom: 10 });

      // 商品列表
      Refresh({ refreshing: $$this.isRefreshing }) {
        List() {
          ForEach(this.goodsList, (goods: Goods) => {
            ListItem() {
              GoodsCard({ goods: goods });
            }
            .margin({ left: 12, right: 12, bottom: 8 });
          }, (goods: Goods) => goods.id);
        }
        .width('100%')
        .layoutWeight(1); // 让列表自己撑开剩余空间
      }
      .onRefreshing(() => this.onRefresh())
      .width('100%');
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5');
  }
}

export { HomePage };