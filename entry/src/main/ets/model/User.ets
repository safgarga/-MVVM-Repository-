export enum UserRole {
  NORMAL = 'normal', // 普通用户
  ADMIN = 'admin'    // 管理员
}

export enum Campus {
  NORTH = '北校区',
  SOUTH = '南校区'
}

export class User {
  id: string = '';
  username: string = '';
  password: string = '';
  role: UserRole = UserRole.NORMAL;
  campus: Campus = Campus.NORTH;
}