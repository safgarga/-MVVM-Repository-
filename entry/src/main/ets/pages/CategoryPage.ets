import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { StorageUtil } from '../utils/StorageUtil';
import { GoodsCategory, GoodsStatus } from '../model/Goods';
import { Goods } from '../model/Goods';
import { Campus } from '../model/User';
import { GoodsCard } from '../components/GoodsCard';

// ✅ 定义分类项接口
interface CategoryItem {
  name: string;
  icon: Resource;
  value: GoodsCategory;
}

@Entry
@Component
struct CategoryPage {
  @State categories: CategoryItem[] = [
    { name: '数码电子', icon: $r('app.media.ic_digital'), value: GoodsCategory.DIGITAL },
    { name: '教材书籍', icon: $r('app.media.ic_book'), value: GoodsCategory.BOOK },
    { name: '运动户外', icon: $r('app.media.ic_sport'), value: GoodsCategory.SPORT },
    { name: '日用百货', icon: $r('app.media.ic_daily'), value: GoodsCategory.DAILY },
    { name: '其他', icon: $r('app.media.ic_other'), value: GoodsCategory.OTHER }
  ];
  @State selectedCategory: GoodsCategory = GoodsCategory.OTHER;
  @State goodsList: Goods[] = [];
  @State currentCampus: Campus = Campus.NORTH;

  aboutToAppear(): void {
    this.loadGoods();
  }

  private loadGoods(): void {
    const filter = new Map<string, Object>();
    filter.set('status', GoodsStatus.ON_SALE);
    filter.set('campus', this.currentCampus);

    if (this.selectedCategory !== GoodsCategory.OTHER) {
      filter.set('category', this.selectedCategory);
    }

    StorageUtil.getGoods(filter).then((goodsList: Goods[]) => {
      this.goodsList = goodsList;
    });
  }

  @Builder
  CategoryGrid() {
    Grid() {
      ForEach(this.categories,
        (cat: CategoryItem) => {
          GridItem() {
            Column({ space: 8 }) {
              Image(cat.icon)
                .width(48)
                .height(48);
              Text(cat.name)
                .fontSize(14)
                .fontColor('#333');
            }
            .backgroundColor(this.selectedCategory === cat.value ? '#FFF0E6' : Color.White)
            .borderRadius(12)
            .border({
              width: this.selectedCategory === cat.value ? 2 : 0,
              color: '#FF5000'
            })
            .onClick(() => {
              this.selectedCategory = cat.value;
              this.loadGoods();
            });
          }
        },
        (cat: CategoryItem) => cat.name
      );
    }
    .columnsTemplate('repeat(3, 1fr)')
    .rowsTemplate('repeat(2, 1fr)')
    .columnsGap(15)
    .rowsGap(15)
    .width('100%')
    .height(200);
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Image($r('app.media.ic_back')).width(24).height(24).onClick(() => router.back());
        Text('商品分类').fontSize(20).fontWeight(700).layoutWeight(1).textAlign(TextAlign.Center);
        Blank().width(24);
      }.width('100%').padding(15);

      Scroll() {
        Column({ space: 20 }) {
          // 校区筛选
          Row() {
            Text('校区筛选：').fontSize(16).fontWeight(500);
            Radio({ value: 'north', group: 'cam' })
              .onChange((v: boolean) => {
                if (v) {
                  this.currentCampus = Campus.NORTH;
                  this.loadGoods();
                }
              });
            Text('北校区').margin({ right: 16 });
            Radio({ value: 'south', group: 'cam' })
              .onChange((v: boolean) => {
                if (v) {
                  this.currentCampus = Campus.SOUTH;
                  this.loadGoods();
                }
              });
            Text('南校区');
          }
          .padding(15)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .margin({ left: 15, right: 15 });

          // 分类网格
          Text('全部分类').fontSize(18).fontWeight(700).margin({ left: 15 });

          Column() {
            this.CategoryGrid();
          }
          .padding(15)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .margin({ left: 15, right: 15 });

          // 分类商品列表
          if (this.selectedCategory !== GoodsCategory.OTHER) {
            Text(`${this.categories.find(c => c.value === this.selectedCategory)?.name}商品`)
              .fontSize(18)
              .fontWeight(700)
              .margin({ left: 15, top: 10 });

            if (this.goodsList.length === 0) {
              Text('暂无该类商品').fontSize(16).fontColor('#999').margin(30);
            } else {
              List() {
                ForEach(this.goodsList, (goods: Goods) => {
                  ListItem() {
                    GoodsCard({ goods: goods });
                  }
                }, (goods: Goods) => goods.id);
              }
              .width('100%')
              .layoutWeight(1)
              .margin({ left: 15, right: 15 });
            }
          }
        }.width('100%');
      }.layoutWeight(1);
    }.width('100%').height('100%').backgroundColor('#F5F5F5');
  }
}

export { CategoryPage };