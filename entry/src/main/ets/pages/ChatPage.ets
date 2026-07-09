import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { StorageUtil } from '../utils/StorageUtil';
import { Message } from '../model/Message';
import { MsgType } from '../model/Message';
import { User } from '../model/User';

export interface ChatPageParams {
  targetUserId: string;
  targetUserName: string;
  goodsId: string;
}

@Entry
@Component
struct ChatPage {
  @State currentUser: User | null = null;
  @State targetUserId: string = '';
  @State targetUserName: string = '';
  @State goodsId: string = '';
  @State goodsTitle: string = '';

  @State messageList: Message[] = [];
  @State inputText: string = '';
  scroller: Scroller = new Scroller();

  aboutToAppear(): void {
    this.currentUser = StorageUtil.getCurrentUserSync();
    const params = router.getParams() as ChatPageParams;

    this.targetUserId = params?.targetUserId || '';
    this.targetUserName = params?.targetUserName || '';
    this.goodsId = params?.goodsId || '';

    this.loadMessages();
  }

  private loadMessages(): void {
    if (!this.currentUser) return;
    StorageUtil.getMessages().then((allMsgs: Message[]) => {
      this.messageList = allMsgs
        .filter(m =>
        (m.fromUserId === this.currentUser!.id && m.toUserId === this.targetUserId) ||
          (m.fromUserId === this.targetUserId && m.toUserId === this.currentUser!.id)
        )
        .sort((a, b) => a.time - b.time);

      // ✅ 修复：显式声明返回类型为 void
      setTimeout((): void => {
        this.scroller.scrollEdge(Edge.Bottom);
      }, 100);
    });
  }

  private send(): void {
    if (!this.inputText.trim() || !this.currentUser) return;

    const msg = new Message();
    msg.id = `msg_${Date.now()}_${Math.random().toString(36).substring(2, 9)}`;
    msg.fromUserId = this.currentUser.id;
    msg.fromUserName = this.currentUser.username;
    msg.toUserId = this.targetUserId;
    msg.toUserName = this.targetUserName;
    msg.content = this.inputText;
    msg.time = Date.now();
    msg.read = false;
    msg.type = MsgType.CHAT;
    msg.relatedGoodsId = this.goodsId;

    StorageUtil.addMessage(msg).then(() => {
      this.inputText = '';
      this.loadMessages();
    });
  }

  // ✅ 修复：将逻辑内联到 UI 组件中，不使用 const 声明
  @Builder
  MessageItem(msg: Message) {
    Row() {
      // ✅ 内联判断：如果不是自己发的，显示左侧头像
      if (msg.fromUserId !== this.currentUser?.id) {
        Image($r('app.media.ic_default_avatar'))
          .width(36)
          .height(36)
          .borderRadius(18)
          .margin({ right: 10 });
      }

      Column() {
        Text(msg.content)
          .fontSize(16)
          // ✅ 内联三元表达式判断背景色
          .backgroundColor(msg.fromUserId === this.currentUser?.id ? '#95EC69' : Color.White)
          .padding(10)
          .borderRadius(8)
          .constraintSize({ maxWidth: '70%' });
      }

      // ✅ 内联判断：如果是自己发的，显示右侧头像
      if (msg.fromUserId === this.currentUser?.id) {
        Image($r('app.media.ic_default_avatar'))
          .width(36)
          .height(36)
          .borderRadius(18)
          .margin({ left: 10 });
      }
    }
    .width('100%')
    // ✅ 内联三元表达式判断对齐方式
    .justifyContent(msg.fromUserId === this.currentUser?.id ? FlexAlign.End : FlexAlign.Start)
    .margin({ bottom: 10 });
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.ic_back')).width(24).onClick(() => router.back());
        Text(this.targetUserName).fontSize(18).layoutWeight(1).textAlign(TextAlign.Center);
        Blank().width(24);
      }.width('100%').padding(15).backgroundColor('#F1F1F1');

      Scroll(this.scroller) {
        Column({ space: 10 }) {
          ForEach(this.messageList, (msg: Message) => {
            this.MessageItem(msg);
          }, (msg: Message) => msg.id);
        }.padding(15);
      }.layoutWeight(1).backgroundColor('#EDEDED');

      Row() {
        TextInput({ placeholder: '输入消息...', text: this.inputText })
          .layoutWeight(1)
          .onChange(v => this.inputText = v)
          .onSubmit(() => this.send());

        Button('发送')
          .onClick(() => this.send())
          .margin({ left: 10 });
      }
      .width('100%')
      .padding(10)
      .backgroundColor(Color.White);
    }
    .width('100%')
    .height('100%')
  }
}

export { ChatPage };