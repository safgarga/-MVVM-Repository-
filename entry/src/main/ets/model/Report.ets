export enum ReportStatus {
  PENDING = 'pending',   // 待处理
  PROCESSED = 'processed',// 已处理
  REJECTED = 'rejected'  // 已驳回
}

export class Report {
  id: string = '';
  goodsId: string = '';
  goodsTitle: string = '';
  reporterId: string = '';
  reporterName: string = '';
  reason: string = '';
  status: ReportStatus = ReportStatus.PENDING;
  handlerId?: string; // 处理人ID
  handleTime?: number; // 处理时间
}