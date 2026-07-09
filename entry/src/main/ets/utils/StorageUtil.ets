import { preferences } from '@kit.ArkData';
import { Goods, GoodsStatus, GoodsCategory } from '../model/Goods';
import { User, UserRole, Campus } from '../model/User';
import { Order, OrderStatus } from '../model/Order';
import { Report, ReportStatus } from '../model/Report';
import { Message, MsgType } from '../model/Message';

const PREF_NAME = 'campus_trade_db';
let _uiContext: Context | null = null;
// 在现有接口后面添加这两个接口
interface GoodsFilter {
  status?: GoodsStatus;
  campus?: Campus;
  category?: GoodsCategory;
  sellerId?: string;
  keyword?: string;
}

interface OrderFilter {
  buyerId?: string;
  sellerId?: string;
  status?: OrderStatus;
}
// 定义存储用的接口类型
interface GoodsRecord {
  id: string;
  title: string;
  price: number;
  description: string;
  images: string[];
  category: GoodsCategory;
  location: Campus;
  sellerId: string;
  sellerName: string;
  status: GoodsStatus;
  publishTime: number;
  collectCount: number;
}

interface UserRecord {
  id: string;
  username: string;
  password: string;
  role: UserRole;
  campus: Campus;
}

interface OrderRecord {
  id: string;
  goodsId: string;
  goodsTitle: string;
  buyerId: string;
  buyerName: string;
  sellerId: string;
  price: number;
  status: OrderStatus;
  createTime: number;
}

interface ReportRecord {
  id: string;
  goodsId: string;
  goodsTitle: string;
  reporterId: string;
  reporterName: string;
  reason: string;
  status: ReportStatus;
}

interface MessageRecord {
  id: string;
  fromUserId: string;
  fromUserName: string;
  toUserId: string;
  toUserName: string;
  content: string;
  time: number;
  read: boolean;
  type: MsgType;
  relatedGoodsId?: string;
}

// 收藏记录接口
interface CollectRecord {
  userId: string;
  goodsIds: string[];
}

/**
 * 获取 Preferences 实例
 */
async function getPreferencesInstance(): Promise<preferences.Preferences> {
  const context = getContext();
  return await preferences.getPreferences(context, PREF_NAME);
}

/**
 * 安全地从 preferences 中获取字符串值
 */
async function getStringValue(pref: preferences.Preferences, key: string, defaultValue: string): Promise<string> {
  return await pref.get(key, defaultValue) as string;
}

/**
 * 将存储记录转换为 Goods 实例
 */
function recordToGoods(record: GoodsRecord): Goods {
  const goods = new Goods();
  goods.id = record.id;
  goods.title = record.title;
  goods.price = record.price;
  goods.description = record.description;
  goods.images = record.images;
  goods.category = record.category;
  goods.location = record.location;
  goods.sellerId = record.sellerId;
  goods.sellerName = record.sellerName;
  goods.status = record.status;
  goods.publishTime = record.publishTime;
  goods.collectCount = record.collectCount;
  return goods;
}

/**
 * 将存储记录转换为 User 实例
 */
function recordToUser(record: UserRecord): User {
  const user = new User();
  user.id = record.id;
  user.username = record.username;
  user.password = record.password;
  user.role = record.role;
  user.campus = record.campus;
  return user;
}

/**
 * 将存储记录转换为 Order 实例
 */
function recordToOrder(record: OrderRecord): Order {
  const order = new Order();
  order.id = record.id;
  order.goodsId = record.goodsId;
  order.goodsTitle = record.goodsTitle;
  order.buyerId = record.buyerId;
  order.buyerName = record.buyerName;
  order.sellerId = record.sellerId;
  order.price = record.price;
  order.status = record.status;
  order.createTime = record.createTime;
  return order;
}

/**
 * 将存储记录转换为 Report 实例
 */
function recordToReport(record: ReportRecord): Report {
  const report = new Report();
  report.id = record.id;
  report.goodsId = record.goodsId;
  report.goodsTitle = record.goodsTitle;
  report.reporterId = record.reporterId;
  report.reporterName = record.reporterName;
  report.reason = record.reason;
  report.status = record.status;
  return report;
}

/**
 * 将存储记录转换为 Message 实例
 */
function recordToMessage(record: MessageRecord): Message {
  const message = new Message();
  message.id = record.id;
  message.fromUserId = record.fromUserId;
  message.fromUserName = record.fromUserName;
  message.toUserId = record.toUserId;
  message.toUserName = record.toUserName;
  message.content = record.content;
  message.time = record.time;
  message.read = record.read;
  message.type = record.type;
  message.relatedGoodsId = record.relatedGoodsId;
  return message;
}

/**
 * 存储工具类 - 完全符合 ArkTS 严格模式
 */
interface GeneratedTypeLiteralInterface_1 {
  status?: GoodsStatus;
  campus?: Campus;
  category?: GoodsCategory;
  sellerId?: string;
  keyword?: string;
}

export class StorageUtil {
  /**
   * 初始化默认数据
   */

  static init(ctx: Context): void { // ✅ 显式类型，解决两个报错
    _uiContext = ctx;
    console.log('【StorageUtil】Context 初始化成功');
  }
  static async initDefaultData(): Promise<void> {
    const pref = await getPreferencesInstance();

    // 检查用户数据
    const usersStr = await getStringValue(pref, 'users', '[]');
    const users: User[] = StorageUtil.parseUsersFromJson(usersStr);

    // 如果已有用户，只确保默认商品存在，不覆盖现有商品
    if (users.length > 0) {
      const goodsStr = await getStringValue(pref, 'goodsList', '[]');
      const goodsList: Goods[] = StorageUtil.parseGoodsFromJson(goodsStr);

      // 如果没有任何商品，创建一个示例商品
      if (goodsList.length === 0) {
        const defaultUser = users.find(u => u.role === UserRole.NORMAL) || users[0];
        const goods: GoodsRecord = {
          id: `g_${Date.now()}`,
          title: 'iPhone 14 256G 自用（示例）',
          price: 3200,
          description: '无拆无修，电池92%，配件齐全',
          category: GoodsCategory.DIGITAL,
          location: Campus.NORTH,
          sellerId: defaultUser.id,
          sellerName: defaultUser.username,
          status: GoodsStatus.PENDING,
          images: ['https://picsum.photos/seed/iphone14/300/300'],
          publishTime: Date.now(),
          collectCount: 0
        };
        await pref.put('goodsList', JSON.stringify([goods]));
        await pref.flush();
        console.log('【StorageUtil】Default goods created');
      }
      return;
    }

    // 首次安装：创建默认用户和商品
    const admin: UserRecord = {
      id: `u_${Date.now()}`,
      username: 'admin',
      password: '123456',
      role: UserRole.ADMIN,
      campus: Campus.NORTH
    };

    const user: UserRecord = {
      id: `u_${Date.now() + 1}`,
      username: 'user',
      password: '123456',
      role: UserRole.NORMAL,
      campus: Campus.NORTH
    };

    const newUsers: UserRecord[] = [admin, user];
    await pref.put('users', JSON.stringify(newUsers));
    await pref.flush();

    const goods: GoodsRecord = {
      id: `g_${Date.now()}`,
      title: 'iPhone 14 256G 自用',
      price: 3200,
      description: '无拆无修，电池92%，配件齐全',
      category: GoodsCategory.DIGITAL,
      location: Campus.NORTH,
      sellerId: user.id,
      sellerName: user.username,
      status: GoodsStatus.PENDING,
      images: ['https://picsum.photos/seed/iphone14/300/300'],
      publishTime: Date.now(),
      collectCount: 0
    };

    await pref.put('goodsList', JSON.stringify([goods]));
    await pref.flush();
    console.log('【StorageUtil】Default data initialized');
  }


  private static currentUserCache: User | null = null;
  private static collectsCache: CollectRecord[] = [];
  static async loadCollectsCache(): Promise<void> {
    const pref = await getPreferencesInstance();
    const collectsStr = await getStringValue(pref, 'collects', '[]');
    StorageUtil.collectsCache = JSON.parse(collectsStr) as CollectRecord[];
  }
  /**
   * 获取当前登录用户
   */


  /**
   * 设置当前登录用户
   */
  static async getCurrentUser(): Promise<User | null> {
    // ❌ 错误：if (this.currentUserCache)
    // ✅ 正确：用类名访问
    if (StorageUtil.currentUserCache) {
      return StorageUtil.currentUserCache;
    }
    const pref = await getPreferencesInstance();
    const userStr = await getStringValue(pref, 'currentUser', '');
    if (!userStr) {
      return null;
    }
    const record: UserRecord = JSON.parse(userStr) as UserRecord;
    const user = recordToUser(record);
    StorageUtil.currentUserCache = user; // ✅ 用类名
    return user;
  }

  /**
   * 获取所有用户
   */
  static async getUsers(): Promise<User[]> {
    const pref = await getPreferencesInstance();
    const usersStr = await getStringValue(pref, 'users', '[]');
    return StorageUtil.parseUsersFromJson(usersStr);
  }

  /**
   * 保存用户
   */
  static async saveUser(user: User): Promise<void> {
    const users = await StorageUtil.getUsers();
    const index = users.findIndex(u => u.id === user.id);

    if (index >= 0) {
      users[index] = user;
    } else {
      users.push(user);
    }

    const pref = await getPreferencesInstance();

    // ✅ 关键修复：显式类型标注
    const records: UserRecord[] = users.map((u: User): UserRecord => {
      const record: UserRecord = {
        id: u.id,
        username: u.username,
        password: u.password,
        role: u.role,
        campus: u.campus
      };
      return record;
    });

    await pref.put('users', JSON.stringify(records));
    await pref.flush();
  }

  static async setCurrentUser(user: User | null): Promise<void> {
    const pref = await getPreferencesInstance();
    if (user) {
      const record: UserRecord = {
        id: user.id,
        username: user.username,
        password: user.password,
        role: user.role,
        campus: user.campus
      };
      await pref.put('currentUser', JSON.stringify(record));
    } else {
      await pref.put('currentUser', '');
    }
    await pref.flush();
    StorageUtil.currentUserCache = user; // ✅ 用类名，不是 this
  }


  static getCurrentUserSync(): User | null {
    return StorageUtil.currentUserCache;
  }

  /**
   * 同步获取用户收藏列表（从缓存读取）
   */
  static getCollectsSync(userId: string): string[] {
    const records = StorageUtil.collectsCache;
    for (let i = 0; i < records.length; i++) {
      if (records[i].userId === userId) {
        return records[i].goodsIds;
      }
    }
    return [];
  }



  /**
   * 同步获取所有收藏记录
   */
  private static getAllCollectRecordsSync(): CollectRecord[] {
    // 这里需要从缓存读取，但为了简单，我们直接从preferences同步读取
    // 注意：ArkTS中preferences没有同步API，所以我们用一个变通方法
    // 实际上我们已经在toggleCollect中维护了内存缓存，可以直接用
    // 但为了简化，我们暂时返回空数组，稍后完善
    return [];
  }
  /**
   * 用户登录
   */
  static async login(username: string, password: string): Promise<User | null> {
    const users = await StorageUtil.getUsers();
    const user = users.find(u => u.username === username && u.password === password);

    if (user) {
      await StorageUtil.setCurrentUser(user);
      return user;
    }
    return null;
  }

  /**
   * 获取商品列表（支持筛选）
   */
  static async getGoods(filter?: Map<string, Object>): Promise<Goods[]> {
    const pref = await getPreferencesInstance();
    const goodsStr = await getStringValue(pref, 'goodsList', '[]');
    let list: Goods[] = StorageUtil.parseGoodsFromJson(goodsStr);

    if (filter) {
      if (filter.has('status')) {
        list = list.filter(g => g.status === filter.get('status'));
      }
      if (filter.has('campus')) {
        list = list.filter(g => g.location === filter.get('campus'));
      }
      if (filter.has('category')) {
        list = list.filter(g => g.category === filter.get('category'));
      }
      if (filter.has('sellerId')) {
        list = list.filter(g => g.sellerId === filter.get('sellerId'));
      }
      if (filter.has('keyword')) {
        const kw = filter.get('keyword') as string;
        if (kw?.trim()) {
          const k = kw.toLowerCase();
          list = list.filter(g =>
          g.title.toLowerCase().includes(k) ||
            g.description.toLowerCase().includes(k)
          );
        }
      }
    }

    return list.sort((a, b) => b.publishTime - a.publishTime);
  }
  /**
   * 保存商品
   */

  static async saveGoods(goods: Goods): Promise<void> {
    const goodsList = await StorageUtil.getGoods();
    const index = goodsList.findIndex(g => g.id === goods.id);

    if (index >= 0) {
      goodsList[index] = goods;
    } else {
      goodsList.push(goods);
    }

    const pref = await getPreferencesInstance();

    // ✅ 关键修复：显式类型标注
    const records: GoodsRecord[] = goodsList.map((g: Goods): GoodsRecord => {
      const record: GoodsRecord = {
        id: g.id,
        title: g.title,
        price: g.price,
        description: g.description,
        images: g.images,
        category: g.category,
        location: g.location,
        sellerId: g.sellerId,
        sellerName: g.sellerName,
        status: g.status,
        publishTime: g.publishTime,
        collectCount: g.collectCount
      };
      return record;
    });

    await pref.put('goodsList', JSON.stringify(records));
    await pref.flush();
  }

  /**
   * 根据ID获取商品
   */
  static async getGoodsById(id: string): Promise<Goods | undefined> {
    const goodsList = await StorageUtil.getGoods();
    return goodsList.find(g => g.id === id);
  }



  /**
   * 获取订单列表
   */
  static async getOrders(filter?: OrderFilter): Promise<Order[]> {
    const pref = await getPreferencesInstance();
    const ordersStr = await getStringValue(pref, 'orders', '[]');
    let orders: Order[] = StorageUtil.parseOrdersFromJson(ordersStr);

    if (filter) {
      if (filter.buyerId !== undefined) {
        orders = orders.filter(o => o.buyerId === filter.buyerId);
      }
      if (filter.sellerId !== undefined) {
        orders = orders.filter(o => o.sellerId === filter.sellerId);
      }
      if (filter.status !== undefined) {
        orders = orders.filter(o => o.status === filter.status);
      }
    }

    return orders.sort((a, b) => b.createTime - a.createTime);
  }

  /**
   * 保存订单
   */
  static async saveOrder(order: Order): Promise<void> {
    const orders = await StorageUtil.getOrders();
    const index = orders.findIndex(o => o.id === order.id);

    if (index >= 0) {
      orders[index] = order;
    } else {
      orders.push(order);
    }

    const pref = await getPreferencesInstance();

    // ✅ 关键修复：显式类型标注
    const records: OrderRecord[] = orders.map((o: Order): OrderRecord => {
      const record: OrderRecord = {
        id: o.id,
        goodsId: o.goodsId,
        goodsTitle: o.goodsTitle,
        buyerId: o.buyerId,
        buyerName: o.buyerName,
        sellerId: o.sellerId,
        price: o.price,
        status: o.status,
        createTime: o.createTime
      };
      return record;
    });

    await pref.put('orders', JSON.stringify(records));
    await pref.flush();
  }

  /**
   * 获取举报列表
   */
  static async getReports(): Promise<Report[]> {
    const pref = await getPreferencesInstance();
    const reportsStr = await getStringValue(pref, 'reports', '[]');
    return StorageUtil.parseReportsFromJson(reportsStr);
  }

  /**
   * 保存举报列表
   */
  static async saveReports(reports: Report[]): Promise<void> {
    const pref = await getPreferencesInstance();

    // ✅ 关键修复：显式类型标注
    const records: ReportRecord[] = reports.map((r: Report): ReportRecord => {
      const record: ReportRecord = {
        id: r.id,
        goodsId: r.goodsId,
        goodsTitle: r.goodsTitle,
        reporterId: r.reporterId,
        reporterName: r.reporterName,
        reason: r.reason,
        status: r.status
      };
      return record;
    });

    await pref.put('reports', JSON.stringify(records));
    await pref.flush();
  }

  /**
   * 添加举报
   */
  static async addReport(report: Report): Promise<void> {
    const reports = await StorageUtil.getReports();
    reports.push(report);
    await StorageUtil.saveReports(reports);
  }

  /**
   * 获取消息列表
   */
  static async getMessages(): Promise<Message[]> {
    const pref = await getPreferencesInstance();
    const messagesStr = await getStringValue(pref, 'messages', '[]');
    return StorageUtil.parseMessagesFromJson(messagesStr);
  }

  /**
   * 保存消息列表
   */
  static async saveMessages(messages: Message[]): Promise<void> {
    const pref = await getPreferencesInstance();

    // ✅ 关键修复：显式类型标注
    const records: MessageRecord[] = messages.map((m: Message): MessageRecord => {
      const record: MessageRecord = {
        id: m.id,
        fromUserId: m.fromUserId,
        fromUserName: m.fromUserName,
        toUserId: m.toUserId,
        toUserName: m.toUserName,
        content: m.content,
        time: m.time,
        read: m.read,
        type: m.type
      };
      if (m.relatedGoodsId !== undefined) {
        record.relatedGoodsId = m.relatedGoodsId;
      }
      return record;
    });

    await pref.put('messages', JSON.stringify(records));
    await pref.flush();
  }

  /**
   * 添加消息
   */
  static async addMessage(message: Message): Promise<void> {
    const messages = await StorageUtil.getMessages();
    messages.push(message);
    await StorageUtil.saveMessages(messages);
  }

  /**
   * 获取用户相关消息
   */
  static async getMessagesByUser(userId: string): Promise<Message[]> {
    const messages = await StorageUtil.getMessages();
    return messages
      .filter(m => m.toUserId === userId || m.fromUserId === userId)
      .sort((a, b) => b.time - a.time);
  }

  /**
   * 获取所有收藏记录
   */
  static async getAllCollectRecords(): Promise<CollectRecord[]> {
    const pref = await getPreferencesInstance();
    const collectsStr = await getStringValue(pref, 'collects', '[]');
    return JSON.parse(collectsStr) as CollectRecord[];
  }

  /**
   * 保存所有收藏记录
   */
  static async saveAllCollectRecords(records: CollectRecord[]): Promise<void> {
    const pref = await getPreferencesInstance();
    await pref.put('collects', JSON.stringify(records));
    await pref.flush();
  }

  /**
   * 获取用户收藏列表
   */
  static async getCollects(userId: string): Promise<string[]> {
    const records = await StorageUtil.getAllCollectRecords();

    for (let i = 0; i < records.length; i++) {
      if (records[i].userId === userId) {
        return records[i].goodsIds;
      }
    }
    return [];
  }

  /**
   * 切换收藏状态
   * @returns true 表示新增收藏，false 表示取消收藏
   */
  static async toggleCollect(userId: string, goodsId: string): Promise<boolean> {
    // 先从磁盘读取最新数据，而不是只用内存缓存
    const records = await StorageUtil.getAllCollectRecords();
    let userRecord: CollectRecord | null = null;
    let recordIndex = -1;

    for (let i = 0; i < records.length; i++) {
      if (records[i].userId === userId) {
        userRecord = records[i];
        recordIndex = i;
        break;
      }
    }

    if (!userRecord) {
      userRecord = { userId: userId, goodsIds: [] };
      records.push(userRecord);
      recordIndex = records.length - 1;
    }

    const goodsIds = userRecord.goodsIds;
    let isCollected = false;
    const foundIndex = goodsIds.indexOf(goodsId);

    if (foundIndex >= 0) {
      goodsIds.splice(foundIndex, 1);
      isCollected = false;
    } else {
      goodsIds.push(goodsId);
      isCollected = true;
    }

    records[recordIndex] = { userId: userId, goodsIds: goodsIds };

    try {
      // 更新内存缓存
      StorageUtil.collectsCache = records;
      // 持久化到磁盘
      await StorageUtil.saveAllCollectRecords(records);
      console.log(`【StorageUtil】toggleCollect: ${userId} -> ${goodsId}, isCollected: ${isCollected}`);
      return isCollected;
    } catch (error) {
      console.error(`【StorageUtil】toggleCollect failed`, error);
      // 回滚内存缓存
      StorageUtil.collectsCache = await StorageUtil.getAllCollectRecords();
      throw new Error("错误信息");
    }
  }
  // ==================== JSON 解析辅助方法 ====================

  private static parseGoodsFromJson(jsonStr: string): Goods[] {
    const records = JSON.parse(jsonStr) as GoodsRecord[];
    return records.map(record => recordToGoods(record));
  }

  private static parseUsersFromJson(jsonStr: string): User[] {
    const records = JSON.parse(jsonStr) as UserRecord[];
    return records.map(record => recordToUser(record));
  }

  private static parseOrdersFromJson(jsonStr: string): Order[] {
    const records = JSON.parse(jsonStr) as OrderRecord[];
    return records.map(record => recordToOrder(record));
  }

  private static parseReportsFromJson(jsonStr: string): Report[] {
    const records = JSON.parse(jsonStr) as ReportRecord[];
    return records.map(record => recordToReport(record));
  }

  private static parseMessagesFromJson(jsonStr: string): Message[] {
    const records = JSON.parse(jsonStr) as MessageRecord[];
    return records.map(record => recordToMessage(record));
  }
}