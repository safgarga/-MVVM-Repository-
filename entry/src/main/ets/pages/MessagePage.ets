import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { StorageUtil } from '../utils/StorageUtil';
import { Message } from '../model/Message';
import { Goods } from '../model/Goods';
import { User } from '../model/User';
// ✅ 引入 ChatPage 的参数接口，确保类型一致
import { ChatPageParams } from './ChatPage';

@Entry
@Component
struct MessagePage {
  @State messages: Message[] = [];
  @State unreadCount: number = 0;
  // ✅ 缓存当前用户，避免在 Builder 中频繁读取
  private currentUser: User | null = StorageUtil.getCurrentUserSync();

  aboutToAppear(): void {
    if (!this.currentUser) {
      promptAction.showToast({ message: '请先登录' });
      router.back();
      return;
    }
    this.loadMessages();
  }

  private loadMessages(): void {
    if (!this.currentUser) return;

    StorageUtil.getMessages().then((allMessages: Message[]) => {
      this.messages = allMessages
        .filter(m => m.toUserId === this.currentUser!.id || m.fromUserId === this.currentUser!.id)
        .sort((a, b) => b.time - a.time);

      this.unreadCount = this.messages.filter(
        m => !m.read && m.toUserId === this.currentUser!.id
      ).length;

      // 标记已读
      const updated: Message[] = [];
      for (let i = 0; i < allMessages.length; i++) {
        const m = allMessages[i];
        if (m.toUserId === this.currentUser!.id && !m.read) {
          const copied = new Message();
          copied.id = m.id;
          copied.fromUserId = m.fromUserId;
          copied.fromUserName = m.fromUserName;
          copied.toUserId = m.toUserId;
          copied.toUserName = m.toUserName;
          copied.content = m.content;
          copied.time = m.time;
          copied.read = true;
          copied.type = m.type;
          copied.relatedGoodsId = m.relatedGoodsId;
          updated.push(copied);
        } else {
          updated.push(m);
        }
      }
      StorageUtil.saveMessages(updated);
    });
  }

  // ✅ 关键修复：接收 currentUser 作为参数
  @Builder
  MessageItem(msg: Message, currentUser: User | null): void {
    Row() {
      Stack() {
        Image($r('app.media.ic_default_avatar')).width(48).height(48).borderRadius(24).backgroundColor('#EEE');
        if (!msg.read && msg.toUserId === currentUser?.id) {
          Circle({ width: 12, height: 12 }).fill('#FF5000').position({ x: 36, y: 0 });
        }
      }.margin({ right: 15 });

      Column() {
        Row() {
          Text(msg.fromUserName).fontSize(16).fontWeight(500).layoutWeight(1);
          Text(new Date(msg.time).toLocaleTimeString()).fontSize(12).fontColor('#999');
        }.width('100%');

        Text(msg.content).fontSize(14).fontColor('#666').maxLines(1).margin({ top: 5 });

        if (msg.relatedGoodsId) {
          Text(`关联商品`)
            .fontSize(12)
            .fontColor('#007DFF')
            .margin({ top: 3 })
            .onClick(() => {
              router.pushUrl({
                url: 'pages/DetailPage',
                params: { goodsId: msg.relatedGoodsId }
              });
            });
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);
    }
    .padding(15)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .margin({ bottom: 10 })
    .onClick(() => {
      // ✅ 使用导入的接口类型，替代 any
      const params: ChatPageParams = {
        targetUserId: msg.fromUserId,
        targetUserName: msg.fromUserName,
        goodsId: msg.relatedGoodsId ?? ''
      };

      // ✅ 使用传入的 currentUser 参数
      if (msg.fromUserId === currentUser?.id) {
        params.targetUserId = msg.toUserId;
        params.targetUserName = msg.toUserName;
      }

      router.pushUrl({
        url: 'pages/ChatPage',
        params: params
      });
    });
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.ic_empty')).width(24).height(24).onClick(() => router.back());
        Text('消息').fontSize(20).fontWeight(700).layoutWeight(1).textAlign(TextAlign.Center);

        if (this.unreadCount > 0) {
          Badge({
            count: this.unreadCount,
            position: BadgePosition.RightTop,
            style: { badgeSize: 16, badgeColor: '#FF5000' }
          }) {
            Text('').width(0);
          }
          .width(24)
          .height(24)
          .margin({ right: 15 });
        } else {
          Blank().width(24);
        }
      }
      .width('100%')
      .padding(15);

      if (this.messages.length === 0) {
        Column() {
          Image($r('app.media.ic_back')).width(120).height(120).opacity(0.5);
          Text('暂无消息').fontSize(18).fontColor('#999').margin({ top: 20 });
          Text('有人咨询你的商品时会收到消息')
            .fontSize(14)
            .fontColor('#AAA')
            .margin({ top: 10 });
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center);
      } else {
        Scroll() {
          Column({ space: 10 }) {
            // ✅ 关键修复：调用 Builder 时传入 currentUser
            ForEach(this.messages, (msg: Message) => {
              this.MessageItem(msg, this.currentUser);
            }, (msg: Message) => msg.id);
          }
          .padding(15)
          .width('100%');
        }
        .layoutWeight(1);
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5');
  }
}

export { MessagePage };