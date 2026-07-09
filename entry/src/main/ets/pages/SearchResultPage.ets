import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { StorageUtil } from '../utils/StorageUtil';
import { Goods } from '../model/Goods';
import { GoodsCard } from '../components/GoodsCard';
import { GoodsCategory } from '../model/Goods';
import { Campus } from '../model/User';

// ✅ 定义路由参数接口
interface SearchResultParams {
  type?: string;
  category?: string;
  keyword?: string;
}

@Entry
@Component
struct SearchResultPage {
  @State goodsList: Goods[] = [];
  @State title: string = '';

  aboutToAppear(): void {
    const params = router.getParams() as SearchResultParams;
    const user = StorageUtil.getCurrentUserSync();

    if (!user && params?.type) {
      promptAction.showToast({ message: '请先登录' });
      router.back();
      return;
    }

    // ✅ 使用 Map 构建筛选条件
    const filter = new Map<string, Object>();

    if (params?.type === 'my' && user) {
      this.title = '我的发布';
      filter.set('sellerId', user.id);
    } else if (params?.type === 'collect' && user) {
      this.title = '我的收藏';
      // ✅ 获取收藏的商品ID列表
      const collects: string[] = StorageUtil.getCollectsSync(user.id);
      if (collects.length === 0) {
        this.goodsList = [];
        return;
      }
      // ✅ 获取所有商品并过滤收藏的
      StorageUtil.getGoods().then((allGoods: Goods[]) => {
        this.goodsList = allGoods.filter(g => collects.includes(g.id));
      });
      return; // 提前返回，避免重复调用 getGoods
    } else if (params?.category) {
      this.title = this.getCategoryName(params.category);
      filter.set('category', params.category as GoodsCategory);
    } else if (params?.keyword) {
      this.title = `搜索"${params.keyword}"`;
      filter.set('keyword', params.keyword);
    }

    // ✅ 异步获取商品列表
    StorageUtil.getGoods(filter).then((goodsList: Goods[]) => {
      this.goodsList = goodsList;
    });
  }

  /**
   * ✅ 根据分类值获取分类名称
   */
  private getCategoryName(category: string): string {
    switch (category) {
      case GoodsCategory.DIGITAL: return '数码电子';
      case GoodsCategory.BOOK: return '教材书籍';
      case GoodsCategory.SPORT: return '运动户外';
      case GoodsCategory.DAILY: return '日用百货';
      default: return '其他分类';
    }
  }

  @Builder
  EmptyView(): void {
    Column() {
      Image($r('app.media.ic_back'))
        .width(120)
        .height(120)
        .opacity(0.5);
      Text('暂无数据')
        .fontSize(18)
        .fontColor('#999')
        .margin({ top: 20 });
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center);
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Image($r('app.media.ic_empty')).width(24).height(24).onClick(() => router.back());
        Text(this.title)
          .fontSize(20)
          .fontWeight(700)
          .layoutWeight(1)
          .textAlign(TextAlign.Center);
        Blank().width(24);
      }.width('100%').padding(15);

      if (this.goodsList.length === 0) {
        this.EmptyView();
      } else {
        List() {
          ForEach(this.goodsList, (goods: Goods) => {
            ListItem() {
              GoodsCard({ goods: goods });
            }
            .margin({ left: 15, right: 15, bottom: 10 });
          }, (goods: Goods) => goods.id);
        }
        .width('100%')
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring) // ✅ 添加弹性效果
        .sticky(StickyStyle.Header)   // ✅ 粘性头部
        .scrollBar(BarState.Auto);    // ✅ 自动显示滚动条
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5');
  }
}

export { SearchResultPage };