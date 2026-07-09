/**
 * 消息类型枚举
 */

export enum MsgType {
  CHAT = 'chat',           // 用户私信
  SYSTEM = 'system',       // 系统通知
  REPORT_REPLY = 'report_reply' // 举报处理结果通知
}

/**
 * 消息数据模型
 */
export class Message {
  id: string = '';
  fromUserId: string = '';
  fromUserName: string = '';
  toUserId: string = '';
  toUserName: string = '';
  content: string = '';
  time: number = Date.now();
  read: boolean = false;
  type: MsgType = MsgType.CHAT;
  relatedGoodsId?: string;
}
